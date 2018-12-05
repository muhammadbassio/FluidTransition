//
//  Example
//
//  Copyright © 2018 Muhammad Bassio. All rights reserved.
//

import UIKit

/// The `PresentationViewController` is a replacement for the `PresentationStack`.
open class PresentationViewController: UIViewController {
  
  private var viewControllers:[FluidViewController] = []
  private(set) var isAnimating:Bool = false
  private var latestStatusBarStyle: Int = 0
  private var latestStatusBarHidden: Bool = false
  
  open override var prefersStatusBarHidden: Bool {
    return self.latestStatusBarHidden
  }
  
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle(rawValue: self.latestStatusBarStyle) ?? super.preferredStatusBarStyle
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.black
    self.updateLatestStatusBar()
  }
  
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    for viewController in self.viewControllers {
      self.layout(viewController: viewController)
    }
  }
  
  open func present(_ viewController: FluidViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    if let from = self.viewControllers.last {
      from.overlayEnabled = false
      let context = FluidContextTransitioning(parent: self, fromViewController: from, toViewController: viewController)
      context.completionBlock = { completed in
        self.viewControllers.append(viewController)
        viewController.overlayAction = { self.dismiss(animated: true) }
        self.updateLatestStatusBar()
        self.setNeedsStatusBarAppearanceUpdate()
        completion?()
      }
      context.animateTransition()
    }
    else {
      self.view.addSubview(viewController.view)
      self.viewControllers.append(viewController)
      viewController.overlayAction = { self.dismiss(animated: true) }
      self.updateLatestStatusBar()
      self.setNeedsStatusBarAppearanceUpdate()
      completion?()
    }
  }
  
  open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    // Make sure there is a viewController in the stack
    if let last = self.viewControllers.last {
      last.animator?.isReverse = true
      last.animator?.context.completionBlock = { completed in
        last.clearOverlay()
        last.view.removeFromSuperview()
        self.viewControllers.removeLast()
        if let newLast = self.viewControllers.last {
          newLast.overlayEnabled = true
        }
        self.updateLatestStatusBar()
        self.setNeedsStatusBarAppearanceUpdate()
        completion?()
      }
      if let interactive = last.interactiveAnimator, interactive.wantsInteractiveStart {
        interactive.startInteractiveTransition()
      } else {
        last.animator?.context.animateTransition()
      }
    }
  }
  
  private func updateLatestStatusBar() {
    // Propagate the `preferredStatusBarStyle` only if last viewController covers the statusBar area
    if self.viewControllers.count > 0 {
      if let last = viewControllers.last {
        switch last.modalPresentationStyle {
        case .fullScreen:
          self.latestStatusBarStyle = last.preferredStatusBarStyle.rawValue
          self.latestStatusBarHidden = last.prefersStatusBarHidden
        default:
          break
        }
      }
    } else {
      self.latestStatusBarHidden = super.prefersStatusBarHidden
      self.latestStatusBarStyle = super.preferredStatusBarStyle.rawValue
    }
  }
  
  private func layout(viewController: FluidViewController) {
    viewController.view.frame = viewController.animator?.appearenceEndFrame ?? self.view.bounds
  }
  
}
