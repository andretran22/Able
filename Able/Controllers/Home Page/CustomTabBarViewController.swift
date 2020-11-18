//
//  CustomTabBarViewController.swift
//  Able
//
//  Created by Tim Nguyen on 11/18/20.
//

import UIKit

class CustomTabBarViewController: UITabBarController {

    override func viewDidLoad() {
      super.viewDidLoad()
      delegate = self
    }
}

extension CustomTabBarViewController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false // Make sure you want this as false
        }

        if fromView != toView {
          UIView.transition(from: fromView, to: toView, duration: 0.2, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}
