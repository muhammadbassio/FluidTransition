//
//  FluidAnimatedTransitioning.swift
//  Example
//
//  Created by Muhammad Bassio on 12/2/18.
//  Copyright © 2018 Muhammad Bassio. All rights reserved.
//

import UIKit

public protocol FluidAnimatedTransitioning {
  var appearenceStartFrame: CGRect { get }
  var appearenceEndFrame: CGRect { get }
  var disappearenceStartFrame: CGRect { get }
  var disappearenceEndFrame: CGRect { get }
  var isReverse: Bool { set get }
  var context: FluidContextTransitioning { get }
  
  func animateTransition(using transitionContext: FluidContextTransitioning)
  func animationEnded(_ transitionCompleted: Bool)
  func animationCancelled()
  func transitionDuration(using transitionContext: FluidContextTransitioning?) -> TimeInterval
}

public class BasicAnimator {
  
  private(set) public var context: FluidContextTransitioning
  public var isReverse: Bool = false
  public var isInteractive: Bool = false
  
  private var gesture: UIPanGestureRecognizer?
  private var startY:CGFloat = 0
  private var totalY:CGFloat = 1
  
  public init(context:FluidContextTransitioning) {
    self.context = context
    self.gesture = UIPanGestureRecognizer(target: self, action: #selector(BasicAnimator.handleGesture(recognizer:)))
    self.context.viewController(forKey: .to)?.view.addGestureRecognizer(self.gesture!)
  }
  
  @objc private func handleGesture(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      self.startY = recognizer.translation(in: recognizer.view).y
      self.totalY = (recognizer.view?.bounds.height ?? UIScreen.main.bounds.height) - self.startY
      self.isInteractive = true
      self.context.parent.dismiss(animated: true, completion: nil)
    case .changed:
      let percentage = (recognizer.translation(in: recognizer.view).y - self.startY) / (self.totalY)
      self.updateTransition(percentage: percentage)
    case .cancelled:
      self.animationCancelled()
    case .ended:
      let percentage = (recognizer.translation(in: recognizer.view).y - self.startY) / (self.totalY)
      if (percentage > 0.5) || (recognizer.velocity(in: recognizer.view).y > 300) {
        self.animationEnded(true)
      } else {
        self.animationCancelled()
      }
    default:
      break
    }
  }
  
  func frame(for viewController: FluidViewController) -> CGRect {
    var x:CGFloat = 0, y:CGFloat = 0, width:CGFloat = self.context.containerView.bounds.width, height:CGFloat = self.context.containerView.bounds.height
    if viewController.constraints.width > 0 {
      width = min(viewController.constraints.width, self.context.containerView.bounds.width)
    }
    if viewController.constraints.height > 0 {
      height = min(viewController.constraints.height, self.context.containerView.bounds.height)
    }
    if viewController.cornerRadius > 0 {
      viewController.view.layer.cornerRadius = viewController.cornerRadius
      viewController.view.clipsToBounds = true
    }
    switch viewController.modalPresentationStyle {
    case .formSheet:
      width = min(width, self.context.containerView.bounds.width - (self.context.containerView.safeAreaInsets.left + self.context.containerView.safeAreaInsets.right))
      x = ((self.context.containerView.bounds.width - (width + self.context.containerView.safeAreaInsets.left + self.context.containerView.safeAreaInsets.right)) / 2) + self.context.containerView.safeAreaInsets.left
      height = min(height, self.context.containerView.bounds.height - (self.context.containerView.safeAreaInsets.top + self.context.containerView.safeAreaInsets.bottom))
      y = ((self.context.containerView.bounds.height - (height + self.context.containerView.safeAreaInsets.top + self.context.containerView.safeAreaInsets.bottom)) / 2) + self.context.containerView.safeAreaInsets.top
    case .pageSheet:
      width = min(width, self.context.containerView.bounds.width - (self.context.containerView.safeAreaInsets.left + self.context.containerView.safeAreaInsets.right + (2 * viewController.constraints.horizontalMargin)))
      x = ((self.context.containerView.bounds.width - width) / 2)
      height = min(height, self.context.containerView.bounds.height - (self.context.containerView.safeAreaInsets.top + self.context.containerView.safeAreaInsets.bottom + (2 * viewController.constraints.verticalMargin)))
      y = self.context.containerView.bounds.height - (height + self.context.containerView.safeAreaInsets.bottom + viewController.constraints.verticalMargin)
    case .overFullScreen:
      width = self.context.containerView.bounds.width
      height = self.context.containerView.bounds.height - self.context.containerView.safeAreaInsets.top
      y = self.context.containerView.safeAreaInsets.top
      viewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    case .overCurrentContext:
      width = self.context.containerView.bounds.width - (self.context.containerView.safeAreaInsets.right + self.context.containerView.safeAreaInsets.left + (viewController.constraints.horizontalMargin * 2))
      height = self.context.containerView.bounds.height - (self.context.containerView.safeAreaInsets.top + self.context.containerView.safeAreaInsets.bottom)
      y = self.context.containerView.safeAreaInsets.top
    default:
      width = self.context.containerView.bounds.width
      height = self.context.containerView.bounds.height
      viewController.view.layer.cornerRadius = 0
      viewController.view.clipsToBounds = false
      break
    }
    return CGRect(x: x, y: y, width: width, height: height)
  }
}


extension BasicAnimator: FluidAnimatedTransitioning {
  
  public var appearenceStartFrame: CGRect {
    return self.appearenceEndFrame.offsetBy(dx: 0, dy: (self.context.containerView.bounds.height - self.appearenceEndFrame.origin.y) + 10)
  }
  
  public var appearenceEndFrame: CGRect {
    if let toViewController = self.context.viewController(forKey: .to) {
      return self.frame(for: toViewController)
    }
    return CGRect.zero
  }
  
  public var disappearenceStartFrame: CGRect {
    if let fromViewController = self.context.viewController(forKey: .from) {
      return self.frame(for: fromViewController)
    }
    return CGRect.zero
  }
  
  public var disappearenceEndFrame: CGRect {
    if let fromViewController = self.context.viewController(forKey: .from) {
      return self.frame(for: fromViewController)
    }
    return CGRect.zero
  }
  
  public func animateTransition(using transitionContext: FluidContextTransitioning) {
    if self.isReverse {
      if let fromViewController = self.context.viewController(forKey: .to) {
        UIView.animate(withDuration: 0.5, animations: {
          fromViewController.view.frame = self.appearenceStartFrame
          fromViewController.updateOverlayAlpha(alpha: 0)
        }) { (finished) in
          transitionContext.completionBlock?(true)
          self.animationEnded(finished)
        }
      }
    } else {
      if let toViewController = self.context.viewController(forKey: .to) {
        if toViewController.showsOverlay {
          toViewController.updateOverlayAlpha(alpha: 0)
          toViewController.addOverlayToView(view: context.containerView)
        }
        toViewController.view.frame = self.appearenceStartFrame
        transitionContext.containerView.addSubview(toViewController.view)
        UIView.animate(withDuration: 0.5, animations: {
          toViewController.view.frame = self.appearenceEndFrame
          toViewController.updateOverlayAlpha(alpha: 1)
        }) { (finished) in
          toViewController.overlayEnabled = true
          transitionContext.completionBlock?(true)
          self.animationEnded(finished)
        }
      }
    }
  }
  
  
  
  public func animationEnded(_ transitionCompleted: Bool) {
    if self.isInteractive && self.isReverse {
      if let fromViewController = self.context.viewController(forKey: .to) {
        UIView.animate(withDuration: TimeInterval(self.completionSpeed), animations: {
          fromViewController.view.frame = self.appearenceStartFrame
          fromViewController.updateOverlayAlpha(alpha: 0)
        }) { (finished) in
          self.isInteractive = false
          self.context.completeTransition(true)
          //self.animationEnded(finished)
        }
      }
    }
    print("Animation Ended :))")
  }
  
  public func animationCancelled() {
    if self.isInteractive && self.isReverse {
      if let fromViewController = self.context.viewController(forKey: .to) {
        UIView.animate(withDuration: TimeInterval(self.completionSpeed), animations: {
          fromViewController.view.frame = self.appearenceEndFrame
          fromViewController.updateOverlayAlpha(alpha: 1)
        }) { (finished) in
          self.isInteractive = false
        }
      }
    }
  }
  
  public func transitionDuration(using transitionContext: FluidContextTransitioning?) -> TimeInterval {
    return 0.4
  }
  
  func updateTransition(percentage: CGFloat) {
    if self.isReverse {
      if let fromViewController = self.context.viewController(forKey: .to) {
        let finalPercentage = min(1, max(percentage, 0))
        let totalDiff = self.appearenceStartFrame.origin.y - self.appearenceEndFrame.origin.y
        fromViewController.view.frame = self.appearenceEndFrame.offsetBy(dx: 0, dy: (totalDiff * finalPercentage))
        fromViewController.updateOverlayAlpha(alpha: (1 - finalPercentage))
        if finalPercentage == 1 {
          self.context.completeTransition(true)
        }
      }
    }
  }
  
  
}


extension BasicAnimator: FluidInteractiveTransitioning {
  public func startInteractiveTransition() {
    self.updateTransition(percentage: 0)
  }
  
  public var wantsInteractiveStart: Bool {
    return self.isInteractive
  }
  
  public var completionCurve: UIView.AnimationCurve {
    return .easeInOut
  }
  
  public var completionSpeed: CGFloat {
    return 0.4
  }
  
  
}
