//
//  Example
//
//  Copyright © 2018 Muhammad Bassio. All rights reserved.
//

import UIKit

public extension UIView {
  
  fileprivate struct AssociatedKeys {
    static var transitionID = "transitionID"
    static var transitionAnimation = "transitionAnimation"
  }
  
  public enum FluidAnimationType {
    case replace
    case fade
    case slide
    case none
  }
  
  public var transitionID: String {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.transitionID) as? String ?? "" }
    set { objc_setAssociatedObject(self, &AssociatedKeys.transitionID, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
  
  public var transitionAnimation: FluidAnimationType {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.transitionAnimation) as? FluidAnimationType ?? .none }
    set { objc_setAssociatedObject(self, &AssociatedKeys.transitionAnimation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
  
  public static func getSubviews(view:UIView) -> [UIView] {
    var subviews:[UIView] = []
    for subview in view.subviews {
      subviews += getSubviews(view: subview)
      subviews.append(subview)
    }
    return subviews
  }
  
  public static func allViews(view:UIView) -> [UIView] {
    var subviews:[UIView] = [view]
    for subview in view.subviews {
      subviews += getSubviews(view: subview)
      subviews.append(subview)
    }
    return subviews
  }
}
