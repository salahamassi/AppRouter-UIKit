//
//  TestWindowRootRoute.swift
//  
//
//  Created by Salah Amassi on 21/12/2020.
//

import UIKit
import AppRouter

class TestWindowRootRoute: Route {
    
    var modalPresentationStyle: UIModalPresentationStyle {
        .none
    }
    
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate? {
        nil
    }
    
    var navigateType: NavigateType {
        .windowRoot
    }
    
    var pushTransition: CATransition? {
        nil
    }
    
    var animated: Bool {
        false
    }
    
    func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
        return MockViewController()
    }
}
