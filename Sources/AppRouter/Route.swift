//
//  Route.swift
//  
//
//  Created by Salah Amassi on 17/12/2020.
//
import UIKit

public protocol Route {
    
    var modalPresentationStyle: UIModalPresentationStyle { get }
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate? { get }
    var navigateType: NavigateType { get }
    var transition: CATransition? { get }
    var animated: Bool { get }

    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController
}

public extension Route {
    
    var modalPresentationStyle: UIModalPresentationStyle{
        .none
    }
    
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate?{
        nil
    }

    var transition: CATransition?{
        nil
    }
    
    var animated: Bool{
        true
    }
}
