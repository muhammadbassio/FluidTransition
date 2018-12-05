//
//  Example
//
//  Copyright © 2018 Muhammad Bassio. All rights reserved.
//

import UIKit

open class FluidViewController: UIViewController {
  
  /// The `FluidConstraints` is responsible for positioning the `FluidViewController` on screen after being presented.
  /// Normal behaviour is to fill the screen, only values greater than `0` are taken into consideration.
  public class FluidConstraints {
    var horizontalMargin: CGFloat = 0
    var verticalMargin: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0
  }
  
  public var animator:FluidAnimatedTransitioning?
  public var interactiveAnimator:FluidInteractiveTransitioning?
  
  public var statusBarStyle:Int = 0
  private var overlay: UIButton = UIButton(frame: .zero)
  public var cornerRadius: CGFloat = 15
  public var constraints: FluidConstraints = FluidConstraints()
  public var overlayAction: (() -> Void) = {}
  public var showsOverlay: Bool = false
  public var hasActionableOverlay: Bool = false
  public var overlayEnabled: Bool = false {
    didSet {
      self.overlay.isUserInteractionEnabled = self.overlayEnabled
    }
  }
  
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle(rawValue: self.statusBarStyle) ?? .default
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    self.overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    self.overlay.addTarget(self, action: #selector(FluidViewController.overlayPressed), for: .touchUpInside)
  }
  
  public func addOverlayToView(view: UIView) {
    view.addSubview(self.overlay)
  }
  
  public func clearOverlay() {
    self.overlay.removeFromSuperview()
  }
  
  public func updateOverlayAlpha(alpha: CGFloat) {
    self.overlay.alpha = alpha
  }
  
  
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.overlay.frame = self.overlay.superview?.bounds ?? CGRect.zero
  }
  
  @objc private func overlayPressed() {
    if self.hasActionableOverlay {
      self.overlayAction()
    }
  }
  
}
