//
//  PanableTableViewController.swift
//  OverlayModalViewController
//
//  Created by William Wang on 08/02/2018.
//  Copyright © 2018 William Wang. All rights reserved.
//

import Foundation
import UIKit

open class PanableTableViewController: UITableViewController, PanedViewController, UIGestureRecognizerDelegate {
	
	fileprivate var tableViewDefaultOffset:CGFloat = 0
	fileprivate var offsetYOfStartDragging:CGFloat = 0
	
	fileprivate var panHandler: PanControlHandler?
	
	public init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override open func loadView() {
		super.loadView()
		// You can control offset by your self.
		let navigationBarHeight:CGFloat = self.navigationController?.navigationBar.frame.height ?? 0
		self.tableViewDefaultOffset = -navigationBarHeight

		if #available(iOS 11.0, *) {
			let inset = UIEdgeInsetsMake(navigationBarHeight, 0, 0, 0)
			self.tableView.contentInset = inset
			self.tableView.scrollIndicatorInsets = inset
			self.tableView.contentInsetAdjustmentBehavior = .never
		}
	}
}

//MARK: TableViewDelegate
extension PanableTableViewController {
	
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
extension PanableTableViewController {
	
	override open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.offsetYOfStartDragging = scrollView.contentOffset.y
	}
	
	override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
			self.tableView.contentOffset = CGPoint(x: 0, y:self.tableViewDefaultOffset)
		}
	}
	
	override open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		self.panHandler?.finishPanedOffset(panContentFrame().origin.y)
	}
	
	private func panContentFrame() -> CGRect {
		if let navigationController = self.navigationController {
			return navigationController.view.frame
		}
		return self.view.frame
	}
}

//MARK: PanableViewController
extension PanableTableViewController {
	
	public func install(panHandler: PanControlHandler) {
		self.panHandler = panHandler
	}
	
	public func didUpdatePanOffset(_ offset: CGFloat, isAttachTop: Bool, isDettachTop: Bool) {
		let safeAreaTop = self.panHandler?.safeAreaTop() ?? 0
		let navigationBarHeight:CGFloat = self.navigationController?.navigationBar.frame.height ?? 0
		let navigationAndSafeAreaOffset = navigationBarHeight + safeAreaTop
		var tableViewOffset = self.tableViewDefaultOffset
		if isDettachTop {
			self.tableViewDefaultOffset = -navigationBarHeight
			self.offsetYOfStartDragging = -navigationBarHeight
			tableViewOffset = -navigationBarHeight
			if #available(iOS 11.0, *) {
				self.tableView.contentInset = UIEdgeInsetsMake(-tableViewOffset, 0, 0, 0)
				self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-tableViewOffset, 0, 0, 0)
			}
			else if #available(iOS 10.0, *) {
				if navigationBarHeight == 0 {
					let inset = UIEdgeInsetsMake(0, 0, 0, 0)
					self.tableView.contentInset = inset
					self.tableView.scrollIndicatorInsets = inset
				}
			}
			else {
				self.updateNavigationBarAtIOS9(isAttachedTop: false)
			}
		}
		else if isAttachTop {
			tableViewOffset = -navigationAndSafeAreaOffset
			self.tableViewDefaultOffset = -navigationAndSafeAreaOffset
			self.offsetYOfStartDragging = -navigationAndSafeAreaOffset
			if #available(iOS 11.0, *) {
				self.tableView.contentInset = UIEdgeInsetsMake(-tableViewOffset, 0, 0, 0)
				self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-tableViewOffset, 0, 0, 0)
			}
			else {
				let offset:CGFloat = navigationBarHeight == 0 ? safeAreaTop : navigationBarHeight
				tableViewOffset = -offset
				let inset = UIEdgeInsetsMake(offset, 0, 0, 0)
				self.tableView.contentInset = inset
				self.tableView.scrollIndicatorInsets = inset
				if #available(iOS 10.0, *) {} else {
					self.updateNavigationBarAtIOS9(isAttachedTop: true)
				}
			}
		}
		self.tableView.contentOffset = CGPoint(x: 0, y: tableViewOffset)
	}
	
	private func updateNavigationBarAtIOS9(isAttachedTop:Bool) {
		let safeAreaTop = self.panHandler?.safeAreaTop() ?? 0
		if let navigationBar = self.navigationController?.navigationBar {
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
