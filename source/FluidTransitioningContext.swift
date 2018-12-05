//
//  FluidTransitioningContext.swift
//  Example
//
//  Created by Muhammad Bassio on 12/2/18.
//  Copyright © 2018 Muhammad Bassio. All rights reserved.
//

import UIKit

public class FluidContextTransitioning {
  public var containerView: UIView
  public var isAnimated: Bool = false
  public var isInteractive: Bool = false
  public var transitionWasCancelled: Bool = false
  public var presentationStyle: UIModalPresentationStyle = .fullScreen
  public var targetTransform: CGAffineTransform = CGAffineTransform()
  public var completionBlock: ((_ didComplete: Bool) -> ())?
  public var parent:PresentationViewController
  
  private var viewControllers:[UITransitionContextViewControllerKey:FluidViewController] = [:]
  private var views:[UITransitionContextViewKey:UIView] = [:]
  
  public init(parent: PresentationViewController, fromViewController: FluidViewController, toViewController: FluidViewController) {
    self.parent = parent
    self.containerView = parent.view
    self.targetTransform = CGAffineTransform()
    self.presentationStyle = .custom
    self.viewControllers = [.from: fromViewController, .to: toViewController]
    self.views = [.from: fromViewController.view, .to: toViewController.view]
  }
  
  public func animateTransition() {
    if let toVC = self.viewControllers[.to] {
      let animator = toVC.animator ?? BasicAnimator(context: self)
      if let interactive = animator as? FluidInteractiveTransitioning {
        toVC.interactiveAnimator = interactive
      }
      toVC.animator = animator
      animator.animateTransition(using: self)
    }
  }
  
  open func updateInteractiveTransition(_ percentComplete: CGFloat) {
    
  }
  
  open func finishInteractiveTransition() {
    self.transitionWasCancelled = false
  }
  
  open func cancelInteractiveTransition() {
    self.transitionWasCancelled = true
  }
  
  open func pauseInteractiveTransition() {
    
  }
  
  open func completeTransition(_ didComplete: Bool) {
    self.completionBlock?(didComplete)
  }
  
  public func viewController(forKey key: UITransitionContextViewControllerKey) -> FluidViewController? {
    return self.viewControllers[key]
  }
  
  public func view(forKey key: UITransitionContextViewKey) -> UIView? {
    return self.views[key]
  }
  
  open func initialFrame(for vc: FluidViewController) -> CGRect {
    if let animator = vc.animator {
      if vc == self.viewControllers[.from] {
        return animator.disappearenceStartFrame
      } else {
        return animator.appearenceStartFrame
      }
    }
    return CGRect.zero
  }
  
  open func finalFrame(for vc: FluidViewController) -> CGRect {
    if let animator = vc.animator {
      if vc == self.viewControllers[.from] {
        return animator.disappearenceEndFrame
      } else {
        return animator.appearenceEndFrame
      }
    }
    return CGRect.zero
  }
  
  
  func frame(for viewController: FluidViewController) -> CGRect {
    var x:CGFloat = 0, y:CGFloat = 0, width:CGFloat = self.containerView.bounds.width, height:CGFloat = self.containerView.bounds.height
    if viewController.constraints.width > 0 {
      width = min(viewController.constraints.width, self.containerView.bounds.width)
    }
    if viewController.constraints.height > 0 {
      height = min(viewController.constraints.height, self.containerView.bounds.height)
    }
    if viewController.cornerRadius > 0 {
      viewController.view.layer.cornerRadius = viewController.cornerRadius
      viewController.view.clipsToBounds = true
    }
    switch viewController.modalPresentationStyle {
    case .formSheet:
      width = min(width, self.containerView.bounds.width - (self.containerView.safeAreaInsets.left + self.containerView.safeAreaInsets.right))
      x = ((self.containerView.bounds.width - (width + self.containerView.safeAreaInsets.left + self.containerView.safeAreaInsets.right)) / 2) + self.containerView.safeAreaInsets.left
      height = min(height, self.containerView.bounds.height - (self.containerView.safeAreaInsets.top + self.containerView.safeAreaInsets.bottom))
      y = ((self.containerView.bounds.height - (height + self.containerView.safeAreaInsets.top + self.containerView.safeAreaInsets.bottom)) / 2) + self.containerView.safeAreaInsets.top
    case .pageSheet:
      width = min(width, self.containerView.bounds.width - (self.containerView.safeAreaInsets.left + self.containerView.safeAreaInsets.right + (2 * viewController.constraints.horizontalMargin)))
      x = ((self.containerView.bounds.width - width) / 2)
      height = min(height, self.containerView.bounds.height - (self.containerView.safeAreaInsets.top + self.containerView.safeAreaInsets.bottom + (2 * viewController.constraints.verticalMargin)))
      y = self.containerView.bounds.height - (height + self.containerView.safeAreaInsets.bottom + viewController.constraints.verticalMargin)
    case .overFullScreen:
      width = self.containerView.bounds.width
      height = self.containerView.bounds.height - self.containerView.safeAreaInsets.top
      y = self.containerView.safeAreaInsets.top
      viewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    case .overCurrentContext:
      width = self.containerView.bounds.width - (self.containerView.safeAreaInsets.right + self.containerView.safeAreaInsets.left + (viewController.constraints.horizontalMargin * 2))
      height = self.containerView.bounds.height - (self.containerView.safeAreaInsets.top + self.containerView.safeAreaInsets.bottom)
      y = self.containerView.safeAreaInsets.top
    default:
      width = self.containerView.bounds.width
      height = self.containerView.bounds.height
      viewController.view.layer.cornerRadius = 0
      viewController.view.clipsToBounds = false
      break
    }
    return CGRect(x: x, y: y, width: width, height: height)
  }
  
}
