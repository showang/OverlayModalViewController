//
//  TestContentViewController.swift
//  OverlayModalViewController
//
//  Created by William Wang on 08/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import OverlayModalViewController

class ExampleViewController: OverlayModalViewController, PanedViewController {
	
	let message:String
	let frame:CGRect?
	let contentView = UIView()
	let messageLabel = UILabel()
	
	private var panControlManager: PanedControlManager?
	
	init(message:String, frame:CGRect? = nil) {
		self.frame = frame
		self.message = message
		super.init()
		self.isTapBackgroundToDismiss = true
		self.panControlManager = PanedControlManager(self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initContentView()
		initMessageLabel()
	}
	
	override func dismiss(animated flag: Bool, completion: (() -> ())?) {
		if let parent = self.parent {
			parent.dismiss(animated: flag, completion: completion)
			return
		}
		super.dismiss(animated: flag, completion: completion)
	}
	
	private func initContentView() {
		contentView.backgroundColor = .white
		contentView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(contentView)
		if let frame = self.frame {
			let width = frame.width
			let height = frame.height
			NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
			NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
			NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width).isActive = true
			NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height).isActive = true
		} else {
			if #available(iOS 11.0, *) {
				NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
				NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
			} else {
				NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
				NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
			}
			NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
			NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
			
		}
		
	}
	
	private func initMessageLabel() {
		self.contentView.addSubview(messageLabel)
		messageLabel.text = message
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 11.0, *), self.navigationController != nil {
			NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: contentView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 100).isActive = true
		} else {
			NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 100).isActive = true
		}
		NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
	}
	
}

//MARK: PanableViewController
extension ExampleViewController {
	public func install(panHandler: PanControlHandler) {
		self.panControlManager?.install(panHandler: panHandler)
	}
	
	public func didUpdatePanOffset(_ offset: CGFloat, isAttachTop: Bool, isDettachTop: Bool, isAnimation: Bool) {
		self.panControlManager?.didUpdatePanOffset(offset, isAttachTop: isAttachTop, isDettachTop: isDettachTop, isAnimation: isAnimation)
	}
}
