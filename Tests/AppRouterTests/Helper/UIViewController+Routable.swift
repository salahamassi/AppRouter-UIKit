//
//  UIViewController+Routable.swift
//  
//
//  Created by Salah Amassi on 26/12/2020.
//

@testable import AppRouter
import UIKit

extension UIViewController: @retroactive Routable {
    
    /// in normal case it must return appRouter instance from app delegate class
    weak public var router: AppRouter? {
        nil
    }
}
