//
//  Routable.swift
//  
//
//  Created by Salah Amassi on 21/12/2020.
//

import UIKit

public protocol Routable where Self: UIViewController {
    
    var router: AppRouter? { get }
}

public extension Routable {
    
    var innerRouter: AppRouter? {
        if let navigationController = navigationController {
            return router?.nestedRouters[navigationController]
        } else {
            return router?.nestedRouters[self]
        }
    }
}
