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
    var pushTransition: CATransition? { get }
    var animated: Bool { get }

    
    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController
    
}

extension Route{
    
    var modalPresentationStyle: UIModalPresentationStyle{
        .none
    }
    
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate?{
        nil
    }

    var pushTransition: CATransition?{
        nil
    }
    
    var animated: Bool{
        true
    }
    
}
