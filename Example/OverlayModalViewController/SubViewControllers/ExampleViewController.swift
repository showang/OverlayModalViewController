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
		
		contentView.backgroundColor = .white
		if let frame = self.frame {
			contentView.frame = frame
		} else {
			contentView.frame = self.view.frame
		}
		self.view.addSubview(contentView)
		
		contentView.addSubview(messageLabel)
		messageLabel.text = message
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 11.0, *), self.navigationController != nil {
			NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: contentView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 100).isActive = true
		} else {
			NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 100).isActive = true
		}
		NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
	}
	
	override func dismiss(animated flag: Bool, completion: (() -> ())?) {
		if let parent = self.parent {
			parent.dismiss(animated: flag, completion: completion)
			return
		}
		super.dismiss(animated: flag, completion: completion)
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
