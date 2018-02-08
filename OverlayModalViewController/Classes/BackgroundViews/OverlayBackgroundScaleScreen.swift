//
//  KKOverlayAddPlaylistBgView.swift
//  KKBOX
//
//  Created by William Wang on 21/12/2017.
//

import Foundation
import UIKit

@objc open class OverlayBackgroundScaleScreen: UIView, KKOverlayBackgroundViewDelegate {
    
	let fullScreenImageView:UIImageView
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let scaleRatio:CGFloat
    
    public init(screenImage:UIImage, scaleRatio:CGFloat = 0.8) {
		let windowBounds = UIApplication.shared.keyWindow?.bounds ?? CGRect.zero
        self.scaleRatio = scaleRatio
		self.fullScreenImageView = UIImageView(frame: windowBounds)
        super.init(frame: windowBounds)
		self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		blurView.frame = windowBounds
        blurView.alpha = 0
        addSubview(fullScreenImageView)
        addSubview(blurView)
        backgroundColor = .black
        fullScreenImageView.image = screenImage
    }
    
	required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func overlayViewControllerWillPresent(_ viewController: UIViewController, in duration:Double) {
        UIView.animate(withDuration: duration) {
            let preW = self.fullScreenImageView.frame.width
            let preH = self.fullScreenImageView.frame.height
            let w = preW * self.scaleRatio
            let h = preH * self.scaleRatio
            let endFrame = CGRect(x: (preW - w) / 2, y: (preH - h) / 2, width: w, height: h)
            
            self.fullScreenImageView.frame = endFrame
            self.blurView.frame = endFrame
            self.blurView.alpha = 1
        }
    }
    
    func overlayViewControllerWillDismiss(_ viewController: UIViewController, out duration:Double) {
        UIView.animate(withDuration: duration) {
            self.fullScreenImageView.frame = self.bounds
            self.blurView.frame = self.bounds
            self.blurView.alpha = 0
        }
    }
	
	func requireTransparentBackground() -> Bool {
		return false
	}
    
}
