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

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	
	private var background:BackgroundType = .blackMask
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initBackgroundViewImage()
		var preButton = initNormalOverlayViewController()
		preButton = initPanableNormalViewController(preButton)
		preButton = initPanableNavigationController(preButton)
		preButton = initPanableTableViewController(preButton)
		initPanableNavigationTableViewButton(preButton)
		initOverlayBackgroundStyleSelector()
	}
	
	private func initNormalOverlayViewController() -> UIButton {
		return initExampleButton(title: "Normal OverlayViewController", selector: #selector(presentOverlayViewController))
	}
	
	private func initPanableNormalViewController(_ preButton:UIButton) -> UIButton{
		return initExampleButton(title: "Panable OverlayViewController", selector: #selector(presentPanableViewController), preButton: preButton)
	}
	
	private func initPanableNavigationController(_ preButton:UIButton) -> UIButton {
		return initExampleButton(title: "Panable NavigationViewController", selector: #selector(presentPanableNavigationViewController), preButton: preButton)
	}
	
	private func initPanableTableViewController(_ preButton:UIButton) -> UIButton {
		return initExampleButton(title: "Panable TableView", selector: #selector(presentPanableTableViewController), preButton: preButton)
	}
	
	private func initPanableNavigationTableViewButton(_ preButton:UIButton){
		_ = initExampleButton(title: "Panable TableView with NavigationBar", selector: #selector(presentNavigationPanableTableViewController), preButton: preButton)
	}
	
	private func initExampleButton(title:String, selector:Selector, preButton:UIButton? = nil) -> UIButton{
		let button = UIButton()
		self.view.addSubview(button)
		button.setTitle(title, for: .normal)
		button.setTitleColor(UIColor.blue, for: .normal)
		appendButton(button, preButton: preButton)
		button.addTarget(self, action: selector, for: .touchUpInside)
		return button
	}
	
	@objc func presentOverlayViewController() {
		let frame = self.view.frame
		let overlayViewController = ExampleViewController(message: "Normal OverlayViewController", frame: CGRect(x: 20, y: 100, width: frame.width - 40, height: frame.height - 200))
		overlayViewController.presentOverlay(background: currentBackground(background))
	}
	
	@objc func presentPanableViewController() {
		let frame = self.view.frame
		let internalViewController = ExampleViewController(message: "Panable OverlayViewController", frame: CGRect(x: 20, y: 100, width: frame.width - 40, height: frame.height - 200))
		let panableViewController = OverlayPanGestureViewController(rootViewController: internalViewController, pinRatio: 1, expendRatio: 1, dismissRatio: 0.5)
		panableViewController.presentOverlay(background: currentBackground(background))
	}
	
	@objc func presentPanableNavigationViewController() {
		let internalViewController = ExampleViewController(message: "Panable with NavigationController")
		internalViewController.title = "NavigationBar"
		let navigationController = UINavigationController(rootViewController: internalViewController)
		let panableViewController = OverlayPanGestureViewController(rootViewController: navigationController, pinRatio: 0.8, expendRatio: 0.9, dismissRatio: 0.5)
		panableViewController.presentOverlay(background: currentBackground(background))
	}
	
	@objc func presentPanableTableViewController() {
		let panableTableViewController = ExampleTableViewController()
		let panableViewController = OverlayPanGestureViewController(rootViewController: panableTableViewController, pinRatio: 0.8, expendRatio: 0.9, dismissRatio: 0.5)
		panableViewController.presentOverlay(background: currentBackground(background))
	}
	
	@objc func presentNavigationPanableTableViewController() {
		let panableTableViewController = ExampleTableViewController()
		panableTableViewController.title = "NavigationBar + TableView"
		let navigationBar = UINavigationController(rootViewController: panableTableViewController)
		let panableViewController = OverlayPanGestureViewController(rootViewController: navigationBar, pinRatio: 0.8, expendRatio: 0.9, dismissRatio: 0.5)
		panableViewController.presentOverlay(background: currentBackground(background))
	}
	
}


// MARK: Boring layout methods
extension ViewController {
	private func initBackgroundViewImage() {
		let backgroundImageView = UIImageView()
		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.image = #imageLiteral(resourceName: "background")
		backgroundImageView.contentMode = .scaleAspectFill
		self.view.addSubview(backgroundImageView)
		NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
	}
	
	private func initOverlayBackgroundStyleSelector() {
		let picker = UIPickerView()
		self.view.addSubview(picker)
		picker.dataSource = self
		picker.delegate = self
		picker.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint(item: picker, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: picker, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
		if #available(iOS 11.0, *) {
			NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
		} else {
			NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 2
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch row {
		case 0:
			return "Dark mask fade in"
		case 1:
			return "Scale background and blur"
		default:
			return "None"
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch row {
		case 1:
			self.background = .blurScalScreen
		default:
			self.background = .blackMask
		}
	}
	
	private func appendButton(_ button:UIButton, preButton:UIButton?) {
		button.translatesAutoresizingMaskIntoConstraints = false
		if let preButton = preButton {
			NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: preButton, attribute: .bottom, multiplier: 1, constant: 40).isActive = true
		}
		else {
			if #available(iOS 11.0, *) {
				NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 48).isActive = true
			} else {
				NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 48).isActive = true
			}
		}
		NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
	}
	
	private func currentBackground(_ type:BackgroundType) -> UIView{
		switch type {
		case .blackMask:
			return OverlayMaskView()
		case .blurScalScreen:
			if let screenImage = UIApplication.shared.keyWindow?.imageOfCurrentContent() {
				return OverlayBackgroundScaleScreen(screenImage: screenImage)
			}
		}
		return UIView()
	}
}

extension UIView {
	func imageOfCurrentContent() -> UIImage? {
		if self.responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
			UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale);
			self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
			let image:UIImage? = UIGraphicsGetImageFromCurrentImageContext();
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
