//
//  TestPushRoute.swift
//  
//
//  Created by Salah Amassi on 21/12/2020.
//

import UIKit
import AppRouter

class TestPushRoute: Route {
    
    var modalPresentationStyle: UIModalPresentationStyle {
        .none
    }
    
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate? {
        nil
    }
    
    var navigateType: NavigateType {
        .push
    }
    
    var transition: CATransition? {
        nil
    }
    
    var animated: Bool {
        false
    }
    
    func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
        MockViewController()
    }
}
