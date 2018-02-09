//
//  KKOverlayShadowMaskView.swift
//  OverlayModalViewController
//
//  Created by William Wang on 19/12/2017.
//

import Foundation
import UIKit

@objc open class OverlayMaskView: UIView, KKOverlayBackgroundViewDelegate {

    private static let defaultEndAlpha:CGFloat = 0.5
    
    var endAlpha = defaultEndAlpha
    
    public convenience init() {
        self.init(withColor: .black, endAlpha: OverlayMaskView.defaultEndAlpha)
    }
    
    public init(withColor color:UIColor, endAlpha:CGFloat){
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = color
        self.alpha = 0
        self.endAlpha = endAlpha
    }
    
	required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func overlayViewControllerWillPresent(_ viewController: UIViewController, in duration:Double) {
        UIView.animate(withDuration: duration) {
            self.alpha = self.endAlpha
        }
    }
    
    func overlayViewControllerWillDismiss(_ viewController: UIViewController, out duration:Double) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0
        }
    }
    
}
