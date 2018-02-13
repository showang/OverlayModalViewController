//
//  ExampleTableViewComtroller.swift
//  OverlayModalViewController_Example
//
//  Created by William Wang on 13/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import OverlayModalViewController

class ExampleTableViewController: UITableViewController, PanedViewController {
	
	private var panControlManager: PanedControlManager?
	
	public init() {
		super.init(nibName: nil, bundle: nil)
		self.panControlManager = PanedControlManager(self)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override open func loadView() {
		super.loadView()
		self.panControlManager?.withScrollView(self.tableView)
	}
	
}

//MARK: TableViewDelegate
extension ExampleTableViewController {
	
	override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
	
	override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.textLabel?.text = "Item \(indexPath.row)"
	}
	
	override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
	}
	
}

//MARK: UIScrollViewDelegate
extension ExampleTableViewController {
	
	override open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.panControlManager?.scrollViewWillBeginDragging(scrollView)
	}
	
	override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.panControlManager?.scrollViewDidScroll(scrollView)
	}
	
	override open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		self.panControlManager?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
	}
}

//MARK: PanableViewController
extension ExampleTableViewController {
	public func install(panHandler: PanControlHandler) {
		self.panControlManager?.install(panHandler: panHandler)
	}
	
	public func didUpdatePanOffset(_ offset: CGFloat, isAttachTop: Bool, isDettachTop: Bool, isAnimation: Bool) {
		self.panControlManager?.didUpdatePanOffset(offset, isAttachTop: isAttachTop, isDettachTop: isDettachTop, isAnimation: isAnimation)
	}
}
