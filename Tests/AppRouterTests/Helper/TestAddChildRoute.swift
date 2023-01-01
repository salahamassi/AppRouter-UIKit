//
//  TestAddChildRoute.swift
//  
//
//  Created by Salah Amassi on 21/12/2020.
//

import UIKit
import AppRouter

class TestAddChildRoute: Route {
    
    let parent: UIViewController
    
    init(parent: UIViewController) {
        self.parent = parent
    }
    
    var modalPresentationStyle: UIModalPresentationStyle {
        .none
    }
    
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate? {
        nil
    }
    
    var navigateType: NavigateType {
        .addChild(parent, view: parent.view)
    }
    
    var transition: CATransition? {
        nil
    }
    
    var animated: Bool {
        false
    }
    
    var captureChild: UIViewController?
    
    func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
        captureChild = UINavigationController(rootViewController: MockChildViewController())
        return captureChild!
    }
}
