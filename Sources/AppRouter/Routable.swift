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
        router?.nestedRouters[self]
    }
}
