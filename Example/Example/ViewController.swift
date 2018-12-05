//
//  Example
//
//  Copyright © 2018 Muhammad Bassio. All rights reserved.
//

import UIKit

class ViewController: PresentationViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
      self.addBlue()
    })
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  func addBlue() {
    let f = FluidViewController()
    f.view.backgroundColor = UIColor.blue
    f.constraints.width = 300
    f.constraints.height = 500
    f.statusBarStyle = 1
    f.modalPresentationStyle = .fullScreen
    self.present(f, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
      self.addYellow()
      //self.addRed()
    })
  }

  func addYellow() {
    let f = FluidViewController()
    f.view.backgroundColor = UIColor.yellow
    f.constraints.width = 300
    f.constraints.height = 500
    f.modalPresentationStyle = .overFullScreen
    self.present(f, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
      self.addGreen()
    })
  }

  func addGreen() {
    let f = FluidViewController()
    f.view.backgroundColor = UIColor.green
    f.constraints.width = 300
    f.constraints.height = 500
    f.statusBarStyle = 0
    f.showsOverlay = true
    f.modalPresentationStyle = .formSheet
    self.present(f, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
      self.addRed()
    })
  }
  
  func addRed() {
    let f = FluidViewController()
    f.view.backgroundColor = UIColor.red
    f.constraints.width = 0
    f.constraints.height = 300
    f.constraints.verticalMargin = 20
    f.constraints.horizontalMargin = 20
    f.statusBarStyle = 1
    f.showsOverlay = true
    f.hasActionableOverlay = true
    f.modalPresentationStyle = .pageSheet
    //f.constraints.reference = .attachToSafeArea
    self.present(f, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
      //self.startDismiss()
    })
  }

  func startDismiss() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
      self.dismiss(animated: true)
      DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
        self.dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
          self.dismiss(animated: true)
          DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.dismiss(animated: true)
          })
        })
      })
    })
  }
  
}

