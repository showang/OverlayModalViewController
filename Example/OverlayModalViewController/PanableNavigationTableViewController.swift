//
//  PanableNavigationTestViewController.swift
//  OverlayModalViewController
//
//  Created by William Wang on 08/02/2018.
//  Copyright © 2018 William Wang. All rights reserved.
//

import Foundation
import UIKit
import OverlayModalViewController

class PanableNavigationTableViewController: OverlayPanableViewController {
	
	private let internalTableViewController = TestPanableTableViewController()
	
	init() {
		internalTableViewController.title = "NavigationBar + TableViewController"
		let navigationController = UINavigationController(rootViewController: internalTableViewController)
		super.init(rootViewController: navigationController, pinRatio: 0.8, expendRatio: 0.9, dismissRatio: 0.5)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
