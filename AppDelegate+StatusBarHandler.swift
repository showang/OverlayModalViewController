//
//  AppDelegate+StatusBarHandler.swift
//  OverlayModalViewController
//
//  Created by William Wang on 22/03/2018.
//

import Foundation

extension UIApplicationDelegate {
	
	func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
		UIView.animate(withDuration: 0.35, animations: {() -> Void in
			guard var windowFrame = application.keyWindow?.frame else {
				return
			}
			let changedHeight = newStatusBarFrame.size.height - UIApplication.shared.statusBarFrame.size.height
			if changedHeight > 0 {
				windowFrame.origin.y = changedHeight
			}
			else {
				windowFrame.origin.y = 0.0
			}
			application.keyWindow?.rootViewController?.view.frame = windowFrame
		})
	}
	
}
