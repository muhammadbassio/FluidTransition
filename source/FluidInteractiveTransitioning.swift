//
//  FluidInteractiveTransitioning.swift
//  Example
//
//  Created by Muhammad Bassio on 12/2/18.
//  Copyright © 2018 Muhammad Bassio. All rights reserved.
//

import UIKit

public protocol FluidInteractiveTransitioning {
  func startInteractiveTransition()
  var wantsInteractiveStart: Bool { get }
  var completionCurve: UIView.AnimationCurve { get }
  var completionSpeed: CGFloat { get }
}
