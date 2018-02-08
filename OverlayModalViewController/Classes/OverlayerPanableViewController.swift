//
//  OverlayerPanableViewController.swift
//  KKBOX
//
//  Created by William Wang on 31/01/2018.
//

import Foundation
import UIKit

@objc public protocol PanableViewController {
	func install(panHandler:PanControlHandler)
	func didUpdatePanOffset(_ offset:CGFloat, isAttachTop:Bool, isDettachTop:Bool)
}

@objc public protocol PanControlHandler {
	func isAttachedTop() -> Bool
	func safeAreaTop() -> CGFloat
	func updatePanedOffset(_ y:CGFloat, isEndAnimation:Bool)
	func finishPanedOffset(_ y:CGFloat)
	func dismiss()
	
	func installPanControlHandler(_ viewController:UIViewController)
	func uninstallPanControllerHandler(_ panableViewController:PanableViewController)
}

@objc open class OverlayPanableViewController : OverlayModalViewController, PanControlHandler {
	private var pinOffset:CGFloat = 150
	private var expendOffset:CGFloat = 100
	private var dismissOffset:CGFloat = 450
	private var preTopOffset:CGFloat = 150
	private var isChangedBySelf = false // For workaround
	private var isDettachTop = false
	private var isAttachTop = false
	private let isInitByRatio:Bool
	private let pinRatio:CGFloat
	private let expendRatio:CGFloat
	private let dismissRatio:CGFloat
	private let rootViewController:UIViewController
	
	private var panBeginY:CGFloat = 0.0
	private var attachedTop = false
	private var panableViewController:PanableViewController?
	
	public init(rootViewController:UIViewController) {
		self.pinRatio = -1
		self.expendRatio = -1
		self.dismissRatio = -1
		self.isInitByRatio = false
		self.rootViewController = rootViewController
		super.init()
		installPanControlHandler(rootViewController)
	}
	
	public init(rootViewController:UIViewController, pinRatio:CGFloat, expendRatio:CGFloat, dismissRatio:CGFloat) {
		self.pinRatio = pinRatio
		self.expendRatio = expendRatio
		self.dismissRatio = dismissRatio
		self.isInitByRatio = true
		self.rootViewController = rootViewController
		super.init()
		installPanControlHandler(rootViewController)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override open func viewDidLoad() {
		let frameSize = view.frame.size
		self.updateOffsets()
		self.preTopOffset = pinOffset
		self.isTapBackgroundToDismiss = true
		self.addChildViewController(rootViewController)
		self.rootViewController.view.frame = CGRect(x: 0, y: pinOffset, width: frameSize.width, height: frameSize.height)
		self.view.addSubview(rootViewController.view)
		if self.modalPresentationStyle != .popover {
			let panGestureRcognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureUpdate(inPanGestureRecognizer:)))
			self.rootViewController.view.addGestureRecognizer(panGestureRcognizer)
		}
	}
	
	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateOffsets()
	}
	
	private func updateOffsets() {
		if !isInitByRatio {
			return
		}
		let viewControllerHeight = self.view.frame.size.height
		pinOffset = viewControllerHeight * (1 - pinRatio)
		expendOffset = viewControllerHeight * (1 - expendRatio)
		dismissOffset = viewControllerHeight * (1 - dismissRatio)
	}
	
	public func installPanControlHandler(_ viewController:UIViewController){
		if let panableVC = viewController as? PanableViewController {
			panableVC.install(panHandler: self)
			panableViewController = panableVC
		}else {
			for childVC in viewController.childViewControllers {
				installPanControlHandler(childVC)
			}
		}
	}
	
	public func uninstallPanControllerHandler(_ panableViewController: PanableViewController) {
		if let panableVC = self.panableViewController, panableVC === panableViewController {
			self.panableViewController = nil
		}
	}
	
	@objc func panGestureUpdate(inPanGestureRecognizer:UIPanGestureRecognizer) {
		let currentFrame = self.rootViewController.view.frame
		switch inPanGestureRecognizer.state {
		case .began:
			self.panBeginY = currentFrame.origin.y
			if self.rootViewController is UINavigationController {
				if attachedTop {
					self.panBeginY = safeAreaTop()
				}
			}
			isChangedBySelf = true
		case .changed:
			let changedY = self.panBeginY + inPanGestureRecognizer.translation(in: self.view).y
			var safeAreaOffset:CGFloat = 0
			if self.rootViewController is UINavigationController {
				safeAreaOffset = safeAreaTop()
			}
			let y = changedY <= safeAreaOffset ? 0 : changedY
			self.updatePanedOffset(y, isEndAnimation: false)
		case .ended, .cancelled:
			let currentY = currentFrame.origin.y
			finishPanedOffset(currentY)
			isChangedBySelf = false
		default:
			break;
		}
	}
	
	public func updatePanedOffset(_ changedY:CGFloat, isEndAnimation:Bool){
		let rootViewFrame = self.rootViewController.view.frame
		let viewSize = self.view.frame.size
		let x = rootViewFrame.origin.x
		var y:CGFloat
		let lastFrame:CGRect
		if self.rootViewController is UINavigationController {
			let safeAreaTop = self.safeAreaTop()
			let rootViewOffset = rootViewFrame.origin.y
			let isPanTop = (changedY < safeAreaTop && rootViewOffset > 0) || changedY < 0
			y = isPanTop ? 0 : changedY
			if rootViewOffset == 0 && changedY > 0 { // when attaching top to pan down
				y -= safeAreaTop
				if y < safeAreaTop { // workaround: Navigation bar offset will going wrong when y < 1
					y += safeAreaTop + safeAreaTop
				}
			}
			lastFrame = CGRect(x: x, y: y, width: viewSize.width, height: viewSize.height - y)
			self.attachedTop = y == 0
		} else {
			y = changedY
			lastFrame = CGRect(x: x, y: y, width: viewSize.width, height: viewSize.height)
		}
		self.attachedTop = y == 0
		if isEndAnimation {
			UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
				self.rootViewController.view.frame = lastFrame
			})
			self.updatePanableViewControllers(y)
		} else {
			self.rootViewController.view.frame = lastFrame
		}
		updatePanableViewControllers(y)
	}
	
	public func finishPanedOffset(_ y:CGFloat) {
		switch y {
		case ...expendOffset:
			self.updatePanedOffset(0, isEndAnimation: true)
		case expendOffset...dismissOffset:
			self.updatePanedOffset(self.pinOffset, isEndAnimation: true)
		default:
			self.dismiss()
		}
	}
	
	private func updatePanableViewControllers(_ topOffset:CGFloat) {
		if self.preTopOffset == 0 && topOffset == 0 {
			return
		}
		self.isDettachTop = self.preTopOffset == 0 && topOffset != 0
		self.isAttachTop = topOffset == 0 && self.preTopOffset != 0
		self.panableViewController?.didUpdatePanOffset(topOffset, isAttachTop: isAttachTop, isDettachTop: isDettachTop)
		self.preTopOffset = topOffset
	}
	
	public func isAttachedTop() -> Bool {
		return attachedTop
	}
	
	public func safeAreaTop() -> CGFloat {
		var safeAreaTop:CGFloat = 0
		if #available(iOS 11.0, *) {
			safeAreaTop = self.view.safeAreaInsets.top
		}
		return safeAreaTop
	}
	
	public func dismiss() {
		dismiss(animated: true)
	}
}
