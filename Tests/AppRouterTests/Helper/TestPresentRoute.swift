//
//  File.swift
//  
//
//  Created by Salah Amassi on 21/12/2020.
//

import UIKit
import AppRouter

class TestPresentRoute: Route{
    
    var modalPresentationStyle: UIModalPresentationStyle{
        .custom
    }
    
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate?{
        MockAnimatedTransitioningDelegate()
    }
    
    var navigateType: NavigateType{
        .present
    }
    
    var pushTransition: CATransition?{
        nil
    }
    
    var animated: Bool{
        false
    }
    
    var params: [String: Any]? =  nil
    
    
    func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
        self.params = params
        return MockViewController(router: router)
    }
    
}
