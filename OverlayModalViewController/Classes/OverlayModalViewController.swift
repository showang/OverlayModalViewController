//
//  OverlayModalViewController.swift
//  OverlayModalViewController
//
//  Created by William Wang on 19/12/2017.
//

import Foundation
import UIKit

open class OverlayModalViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    fileprivate static let defaulDuration:Double = 0.3
    
    fileprivate weak var backgroundViewDelegate:OverlayBackgroundView?
    fileprivate weak var backgroundView:UIView?
	private var tabGestureDelegate:TapGestureDelegate?
    fileprivate var presentDuration = defaulDuration
	//For transitioningDelegate
	fileprivate var animatedTransition: AnimatedTransition?
	
	weak var delegate:KKOverlayPresentingViewControllerDelegate?
    
    fileprivate var tapGesture:UITapGestureRecognizer?
    public var isTapBackgroundToDismiss = false {
        didSet {
            if tapGesture == nil {
				tabGestureDelegate = TapGestureDelegate(parentViewController: self)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchEvent(gestureReconizer:)))
                tapGesture.numberOfTapsRequired = 1;
                tapGesture.delegate = tabGestureDelegate
                self.tapGesture = tapGesture
                self.view.isUserInteractionEnabled = true
            }
            if let tapGesture = tapGesture {
                if isTapBackgroundToDismiss {
                    self.view.addGestureRecognizer(tapGesture)
                } else {
                    self.view.removeGestureRecognizer(tapGesture)
                }
            }
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
	required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	public func gestureRecognizerShouldBegin(_ gr: UIGestureRecognizer) -> Bool {
        let location = gr.location(in: self.view!)
        for view in self.view.subviews {
            if view.frame.contains(location) {
                return false
            }
        }
        return true
    }
    
    @objc private func touchEvent(gestureReconizer: UIGestureRecognizer){
        dismiss(animated: true)
    }
    
	override open func dismiss(animated flag: Bool, completion: (() -> ())? = nil) {
        self.delegate?.overlayViewControllerWillDismiss?(self)
        self.backgroundViewDelegate?.overlayViewControllerWillDismiss?(self, out: presentDuration)
        super.dismiss(animated: flag, completion: {
            completion?()
            self.backgroundViewDelegate?.overlayViewControllerDidDismiss?(self)
            self.delegate?.overlayViewControllerDidDismiss?(self)
            self.backgroundView?.removeFromSuperview()
        })
    }
    
    @objc public func presentOverlay(background bgView:UIView?,  completion: (()->Void)? = nil) {
		var topPresentedViewController = UIApplication.shared.keyWindow?.rootViewController
		while topPresentedViewController?.presentedViewController != nil {
			topPresentedViewController = topPresentedViewController?.presentedViewController
		}
		guard let presentingViewController = topPresentedViewController else {
			return
		}
        presentOverlay(by: presentingViewController, background: bgView, completion: completion)
    }
    
    @objc public func presentOverlay(by presentingViewController:UIViewController, background bgView:UIView?,  completion: (()->Void)?) {
		prepareBackground(bgView, presentingVC: presentingViewController)
        presentingViewController.present(self, animated: true){
            completion?()
			self.accessibilityViewIsModal = true
            self.backgroundViewDelegate?.overlayViewControllerDidPresent?(self)
        }
    }
	
	private func prepareBackground(_ bgView:UIView?, presentingVC:UIViewController) {
		self.backgroundView = bgView
		guard let bgView = bgView else {
			return
		}
		bgView.translatesAutoresizingMaskIntoConstraints = false
		if let viewDelegate = bgView as? OverlayBackgroundView {
			backgroundViewDelegate = viewDelegate
			if backgroundViewDelegate?.requireTransparentBackground?() ?? true {
				if self.modalPresentationStyle == .fullScreen {
					self.modalPresentationStyle = .overCurrentContext
				}
				guard let rootView = presentingVC.view else {
					return
				}
				rootView.addSubview(bgView)
				NSLayoutConstraint(item: bgView, attribute: .top, relatedBy: .equal, toItem: rootView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
				NSLayoutConstraint(item: bgView, attribute: .bottom, relatedBy: .equal, toItem: rootView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
				NSLayoutConstraint(item: bgView, attribute: .leading, relatedBy: .equal, toItem: rootView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
				NSLayoutConstraint(item: bgView, attribute: .trailing, relatedBy: .equal, toItem: rootView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
			} else {
				self.transitioningDelegate = self
			}
		}
	}
	
	override open func viewWillAppear(_ animated: Bool) {
		self.backgroundViewDelegate?.overlayViewControllerWillPresent?(self, in: self.presentDuration)
	}
	
	private class TapGestureDelegate:NSObject, UIGestureRecognizerDelegate {
		
		private let parent:UIViewController
		init(parentViewController:UIViewController) {
			self.parent = parentViewController
		}
		
		public func gestureRecognizerShouldBegin(_ gr: UIGestureRecognizer) -> Bool {
			let location = gr.location(in: self.parent.view!)
			for view in self.parent.view.subviews {
				if view.frame.contains(location) {
					return false
				}
			}
			return true
		}
		
		@objc private func touchEvent(gestureReconizer: UIGestureRecognizer){
			self.parent.dismiss(animated: true)
		}
	}
    
}

@objc protocol OverlayBackgroundView {
	
	@objc optional func requireTransparentBackground() -> Bool
    
    @objc optional func overlayViewControllerWillDismiss(_ viewController:UIViewController, out duration:Double)
    
    @objc optional func overlayViewControllerDidDismiss(_ viewController:UIViewController)
    
    @objc optional func overlayViewControllerWillPresent(_ viewController:UIViewController, in duration:Double)
    
    @objc optional func overlayViewControllerDidPresent(_ viewController:UIViewController)
    
}

@objc protocol KKOverlayPresentingViewControllerDelegate {
    
    @objc optional func overlayViewControllerWillDismiss(_ viewController:UIViewController)
    
    @objc optional func overlayViewControllerDidDismiss(_ viewController:UIViewController)
    
}

extension OverlayModalViewController {
	
	public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		guard let backgroundView = self.backgroundView else {
			return nil
		}
		self.animatedTransition = AnimatedTransition(backgroundView: backgroundView)
		self.animatedTransition?.purpose = .present
		return self.animatedTransition
	}
	
	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.animatedTransition?.purpose = .dismiss
		return self.animatedTransition
	}
}

fileprivate class AnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
	enum Purpose {
		case present
		case dismiss
	}
	
	var purpose:Purpose = .present
	let backgroundView:UIView
	let animationTime: TimeInterval = 0.3
	var preSafeArea:CGFloat = 0
	
	init(backgroundView:UIView) {
		self.backgroundView = backgroundView
	}
	
	func animationEnded(_ transitionCompleted: Bool) {
		if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, let rootView = rootViewController.view {
			let statusBarHeight = UIApplication.shared.statusBarFrame.height
			var safeAreaTop:CGFloat = 0
			if #available(iOS 11.0, *) {
				safeAreaTop = rootView.safeAreaInsets.top
			}
			let marginTop:CGFloat = preSafeArea != 0 ? statusBarHeight - preSafeArea : 0
			rootView.frame.origin.y = marginTop
			self.preSafeArea = safeAreaTop
		}
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return animationTime
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerFrame = transitionContext.containerView.bounds
		let outFrame = CGRect(x: 0, y: containerFrame.height, width: containerFrame.width, height: containerFrame.height)
		if (self.purpose == .present) {
			if let toView = transitionContext.view(forKey: .to) {
				transitionContext.containerView.addSubview(self.backgroundView)
				self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
				NSLayoutConstraint(item: self.backgroundView, attribute: .top, relatedBy: .equal, toItem: transitionContext.containerView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
				NSLayoutConstraint(item: self.backgroundView, attribute: .bottom, relatedBy: .equal, toItem: transitionContext.containerView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
				NSLayoutConstraint(item: self.backgroundView, attribute: .leading, relatedBy: .equal, toItem: transitionContext.containerView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
				NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: transitionContext.containerView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
				
				transitionContext.containerView.addSubview(toView)
				toView.frame = outFrame
				UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseOut, animations:  {
					toView.frame = containerFrame
				}, completion: { (completion:Bool) -> Void in
					self.transitionComplete(transitionContext)
				})
			}
		} else {
			if let fromView = transitionContext.view(forKey: .from) {
				UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseIn, animations: {
					fromView.frame = outFrame
				}, completion: { completion in
					self.backgroundView.removeFromSuperview()
					self.transitionComplete(transitionContext)
				})
			}
		}
	}
	
	private func transitionComplete(_ transitionContext: UIViewControllerContextTransitioning) {
		if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
			// Fix layout bug in iOS 9+
			toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
		}
		transitionContext.completeTransition(true)
	}
}
