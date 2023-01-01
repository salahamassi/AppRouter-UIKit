//
//  Routable+UINavigationController.swift
//  AppRouter
//
//  Created by Salah Amassi on 01/01/2023.
//

import UIKit

public extension Routable where Self: UINavigationController {
    
    var innerRouter: AppRouter? {
        router?.nestedRouters[self]
    }
}
