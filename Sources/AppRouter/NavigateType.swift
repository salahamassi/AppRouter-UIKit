//
//  NavigateType.swift
//  
//
//  Created by Salah Amassi on 17/12/2020.
//

import UIKit

public enum NavigateType {
    case present, push, windowRoot, addChild(_ parent: UIViewController,
                                             view: UIView,
                                             safeArea: Bool = false,
                                             frame: CGRect? = nil)
}
