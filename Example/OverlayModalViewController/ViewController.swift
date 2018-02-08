//
//  ViewController.swift
//  OverlayModalViewController
//
//  Created by William Wang on 02/08/2018.
//  Copyright (c) 2018 William Wang. All rights reserved.
//

import UIKit
import OverlayModalViewController

enum BackgroundType {
	case blackMask, blurScalScreen
}

class ViewController: UIViewController {
	
	private var background:BackgroundType = .blackMask
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let preButton = initTestNormalViewController()
		initTestPanableNavigationTableViewButton(preButton)
	}
	
	private func initTestNormalViewController() -> UIButton{
		let button = UIButton()
		self.view.addSubview(button)
		button.setTitle("Panable ViewController", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 11.0, *) {
			NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 48).isActive = true
		} else {
			NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 48).isActive = true
		}
		NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
		button.addTarget(self, action: #selector(presentTestNormalPanableViewController), for: .touchUpInside)
		return button
	}
	
	private func initTestPanableNavigationTableViewButton(_ preButton:UIButton){
		let button = UIButton()
		self.view.addSubview(button)
		button.setTitle("Panable TableView with NavigationBar", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: preButton, attribute: .bottom, multiplier: 1, constant: 48).isActive = true
		NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
		button.addTarget(self, action: #selector(presentTestPanableTableViewController), for: .touchUpInside)
	}
	
	private func currentBackground(_ type:BackgroundType) -> UIView{
		switch type {
		case .blackMask:
			return OverlayMaskView()
		case .blurScalScreen:
			if let screenImage = self.view.imageOfCurrentContent() {
				return OverlayBackgroundScaleScreen(screenImage: screenImage)
			}
		}
		return UIView()
	}
	
	@objc func presentTestNormalPanableViewController() {
		let internalViewController = TestContentViewController()
		let panableViewController = OverlayPanableViewController(rootViewController: internalViewController, pinRatio: 0.8, expendRatio: 0.9, dismissRatio: 0.5)
		panableViewController.presentOverlay(background: currentBackground(background))
	}
	
	@objc func presentTestPanableTableViewController() {
		let panableViewController = PanableNavigationTableViewController()
		panableViewController.presentOverlay(background: currentBackground(background))
	}
	
}

extension UIView {
	func imageOfCurrentContent() -> UIImage? {
		if self.responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
			UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale);
			self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
			let image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			return image
		}
		return self.imageOfCurrentContentByCoreAnimation()
	}
	
	func imageOfCurrentContentByCoreAnimation() -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		self.layer.render(in: context)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}
