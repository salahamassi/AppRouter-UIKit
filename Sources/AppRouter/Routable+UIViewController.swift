//
//  Routable+UIViewController.swift
//  AppRouter
//
//  Created by Salah Amassi on 01/01/2023.
//

import UIKit

public extension Routable where Self: UIViewController {
    
    var innerRouter: AppRouter? {
        router?.nestedRouters[self]
    }
}
