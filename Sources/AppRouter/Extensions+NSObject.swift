//
//  File.swift
//  
//
//  Created by Salah Amassi on 30/01/2021.
//

import Foundation

extension NSObject {
    var className: String {
        get {
            return NSStringFromClass(type(of: self))
        }
    }
}
