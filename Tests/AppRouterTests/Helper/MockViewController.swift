//
//  File.swift
//  
//
//  Created by Salah Amassi on 21/12/2020.
//

import UIKit
import AppRouter

class MockViewController: UIViewController {
    
    weak var router: AppRouter?
    
    init(router: AppRouter) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
