//
//  PanableControlManager.swift
//  OverlayModalViewController
//
//  Created by William Wang on 13/02/2018.
//

import Foundation

@objc open class PanedControlManager: NSObject, UIScrollViewDelegate, PanedViewController{
	
	private var panHandler:PanControlHandler?
	private var scrollView:UIScrollView?
	
	fileprivate var tableViewDefaultOffset:CGFloat = 0
	fileprivate var offsetYOfStartDragging:CGFloat = 0
	fileprivate var safeAreaHandler:SafeAreaHandler?
	
	private let target:UIViewController
	
	public init(_ viewController:UIViewController) {
		self.target = viewController
		super.init()
		if #available(iOS 11, *) {
			safeAreaHandler = SafeAreaHandlerIOS11()
		}
		else if #available(iOS 10, *) {
			safeAreaHandler = SafeAreaHandlerIOS10()
		}
		else {
			safeAreaHandler = SafeAreaHandlerIOS9()
		}
	}
	
	public func withScrollView(_ scrollView:UIScrollView){
		self.scrollView = scrollView
	}
	
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.offsetYOfStartDragging = scrollView.contentOffset.y
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let panHandler = self.panHandler else {
			return
		}
		let offsetY = scrollView.contentOffset.y - self.offsetYOfStartDragging
		let isAttachTop = panHandler.isAttachedTop()
		let isScrollTop = self.offsetYOfStartDragging <= self.tableViewDefaultOffset
		if(isAttachTop && !isScrollTop) {
			return;
		}
		if scrollView.panGestureRecognizer.state == .changed {
			let newOffset = panContentFrame().origin.y - offsetY
			panHandler.updatePanedOffset(newOffset, isEndAnimation: false)
		} else if (!isAttachTop) {
			self.scrollView?.contentOffset = CGPoint(x: 0, y:self.tableViewDefaultOffset)
		}
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		self.panHandler?.finishPanedOffset(panContentFrame().origin.y)
	}
	
	private func panContentFrame() -> CGRect {
		if let navigationController = self.target.navigationController {
			return navigationController.view.frame
		}
		return self.target.view.frame
	}
	
	
	public func install(panHandler: PanControlHandler) {
		self.panHandler = panHandler
		let navigationBarHeight:CGFloat = self.target.navigationController?.navigationBar.frame.height ?? 0
		self.tableViewDefaultOffset = -navigationBarHeight
	}
	
	public func didUpdatePanOffset(_ offset: CGFloat, isAttachTop: Bool, isDettachTop: Bool, isAnimation: Bool) {
		let navigationBar = self.target.navigationController?.navigationBar
		let safeAreaTop = self.panHandler?.safeAreaTop() ?? 0
		let preDefaultOffset = self.tableViewDefaultOffset
		let navigationBarHeight:CGFloat = navigationBar?.frame.height ?? 0
		if isDettachTop {
			self.tableViewDefaultOffset = -navigationBarHeight
			self.offsetYOfStartDragging = -navigationBarHeight
		}
		else if isAttachTop {
			self.tableViewDefaultOffset = -navigationBarHeight - safeAreaTop
			self.offsetYOfStartDragging = -navigationBarHeight - safeAreaTop
		}
		self.safeAreaHandler?.handleNavigationBar(navigationBar, with: scrollView, defaultOffset: preDefaultOffset, safeAreaTop: safeAreaTop, isAttachTop: isAttachTop, isDettachTop: isDettachTop, isAnimation: isAnimation)
	}
	
	private func updateNavigationBarAtIOS9(isAttachedTop:Bool) {
		let safeAreaTop = self.panHandler?.safeAreaTop() ?? 0
		if let navigationBar = self.target.navigationController?.navigationBar {
			for subView in navigationBar.subviews {
				if NSStringFromClass(subView.classForCoder).contains("BarBackground") {
					var bgFrame = subView.frame
					bgFrame.size.height = navigationBar.frame.height + (isAttachedTop ? safeAreaTop : 0)
					bgFrame.origin.y = isAttachedTop ? -safeAreaTop : 0
					subView.frame = bgFrame
				}
			}
			var barFrame = navigationBar.frame
			barFrame.origin.y = isAttachedTop ? safeAreaTop : 0
			navigationBar.frame = barFrame
		}
	}
}

fileprivate protocol SafeAreaHandler {
	func handleNavigationBar(_ navigationBar:UINavigationBar?, with scrollView:UIScrollView?, defaultOffset:CGFloat, safeAreaTop:CGFloat, isAttachTop: Bool, isDettachTop: Bool, isAnimation: Bool)
}

fileprivate class SafeAreaHandlerIOS11: SafeAreaHandler {
	func handleNavigationBar(_ navigationBar: UINavigationBar?, with scrollView: UIScrollView?, defaultOffset:CGFloat, safeAreaTop:CGFloat, isAttachTop: Bool, isDettachTop: Bool, isAnimation: Bool) {
		let navigationBarHeight:CGFloat = navigationBar?.frame.height ?? 0
		let navigationAndSafeAreaOffset = navigationBarHeight + safeAreaTop
		var tableViewOffset = defaultOffset
		if isDettachTop {
			tableViewOffset = -navigationBarHeight
		}
		else if isAttachTop {
			tableViewOffset = -navigationAndSafeAreaOffset
			if  navigationBar != nil && (isAnimation || !(scrollView?.isDragging ?? true)){
				tableViewOffset = -navigationBarHeight
			}
		}
		scrollView?.contentOffset = CGPoint(x: 0, y: tableViewOffset)
	}
}

fileprivate class SafeAreaHandlerIOS10: SafeAreaHandler {
	func handleNavigationBar(_ navigationBar: UINavigationBar?, with scrollView: UIScrollView?, defaultOffset:CGFloat, safeAreaTop:CGFloat, isAttachTop: Bool, isDettachTop: Bool, isAnimation: Bool) {
		var tableViewOffset = defaultOffset
		if navigationBar != nil {
			if isDettachTop || isAttachTop {
				return
			}
		}
		else {
			let navigationBarHeight:CGFloat = 0
			if isDettachTop {
				tableViewOffset = -navigationBarHeight
				if navigationBarHeight == 0 {
					let inset = UIEdgeInsetsMake(0, 0, 0, 0)
					scrollView?.contentInset = inset
					scrollView?.scrollIndicatorInsets = inset
				}
			}
			else if isAttachTop {
				let offset:CGFloat = navigationBarHeight == 0 ? safeAreaTop : navigationBarHeight
				tableViewOffset = -offset
				let inset = UIEdgeInsetsMake(offset, 0, 0, 0)
				scrollView?.contentInset = inset
				scrollView?.scrollIndicatorInsets = inset
			}
		}
		scrollView?.contentOffset = CGPoint(x: 0, y: tableViewOffset)
	}
}

fileprivate class SafeAreaHandlerIOS9: SafeAreaHandler {
	func handleNavigationBar(_ navigationBar: UINavigationBar?, with scrollView: UIScrollView?, defaultOffset:CGFloat, safeAreaTop:CGFloat, isAttachTop: Bool, isDettachTop: Bool, isAnimation: Bool) {
		var tableViewOffset = defaultOffset
		if navigationBar != nil {
			if isDettachTop {
				self.updateNavigationBar(navigationBar, for: safeAreaTop, whenAttachedTop: false)
				return
			}
			else if isAttachTop {
				self.updateNavigationBar(navigationBar, for: safeAreaTop, whenAttachedTop: true)
				return
			}
		}
		else {
			if isDettachTop {
				tableViewOffset = 0
				updateNavigationBar(navigationBar, for: safeAreaTop, whenAttachedTop: false)
			}
			else if isAttachTop {
				let offset:CGFloat = safeAreaTop
				tableViewOffset = -offset
				let inset = UIEdgeInsetsMake(offset, 0, 0, 0)
				scrollView?.contentInset = inset
				scrollView?.scrollIndicatorInsets = inset
				updateNavigationBar(navigationBar, for: safeAreaTop, whenAttachedTop: true)
			}
		}
		scrollView?.contentOffset = CGPoint(x: 0, y: tableViewOffset)
	}
		
	private func updateNavigationBar(_ navigationBar:UINavigationBar?,for safeAreaTop:CGFloat, whenAttachedTop isAttachedTop:Bool) {
		if let navigationBar = navigationBar {
			for subView in navigationBar.subviews {
				if NSStringFromClass(subView.classForCoder).contains("BarBackground") {
					var bgFrame = subView.frame
					bgFrame.size.height = navigationBar.frame.height + (isAttachedTop ? safeAreaTop : 0)
					bgFrame.origin.y = isAttachedTop ? -safeAreaTop : 0
					subView.frame = bgFrame
				}
			}
			var barFrame = navigationBar.frame
			barFrame.origin.y = isAttachedTop ? safeAreaTop : 0
			navigationBar.frame = barFrame
		}
		
	}
}
