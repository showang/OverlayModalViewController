//
//  OverlayModalViewController.swift
//  OverlayModalViewController
//
//  Created by William Wang on 19/12/2017.
//

import Foundation
import UIKit

open class OverlayModalViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    private static let defaulDuration:Double = 0.3
    
    private weak var backgroundViewDelegate:KKOverlayBackgroundViewDelegate?
    fileprivate weak var backgroundView:UIView?
	private var tabGestureDelegate:TapGestureDelegate?
    weak var delegate:KKOverlayPresentingViewControllerDelegate?
    var presentDuration = defaulDuration
    
    private var tapGesture:UITapGestureRecognizer?
    var isTapBackgroundToDismiss = false {
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
    
    init() {
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
		if let viewDelegate = bgView as? KKOverlayBackgroundViewDelegate {
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

@objc protocol KKOverlayBackgroundViewDelegate {
	
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
		guard let bgView = self.backgroundView else {
			return nil
		}
		let animator = SwipeAnimator(backgroundView: bgView)
		animator.transitonTo = .present
		return animator
	}
	
	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		guard let bgView = self.backgroundView else {
			return nil
		}
		let animator = SwipeAnimator(backgroundView: bgView)
		animator.transitonTo = .dismiss
		return animator
	}
}

class SwipeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	enum SwipeTo {
		case present
		case dismiss
	}
	
	var transitonTo:SwipeTo = .present
	let backgroundView:UIView
	let animationTime: TimeInterval = 0.3
	
	init(backgroundView:UIView) {
		self.backgroundView = backgroundView
	}
	
	func animationEnded(_ transitionCompleted: Bool) {
		UIApplication.shared.keyWindow?.rootViewController?.view.setNeedsLayout()
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return animationTime
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerFrame = transitionContext.containerView.bounds
		let outFrame = CGRect(x: 0, y: containerFrame.height, width: containerFrame.width, height: containerFrame.height)
		if (self.transitonTo == .present) {
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
					transitionContext.completeTransition(true)
				})
			}
		} else {
			if let fromView = transitionContext.view(forKey: .from) {
				UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseIn, animations: {
					fromView.frame = outFrame
				}, completion: { completion in
					self.backgroundView.removeFromSuperview()
					transitionContext.completeTransition(true)
				})
			}
		}
	}
}
