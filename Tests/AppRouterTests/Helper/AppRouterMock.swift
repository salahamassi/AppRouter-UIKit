//
//  AppRouterMock.swift
//  
//
//  Created by Salah Amassi on 21/12/2020.
//

@testable import AppRouter

class AppRouterMock: AppRouter {
    
    var params: [String : Any]? = nil
    var completion: (() -> Void)?
    var dismissCompletion: (() -> Void)?
    
    
    override func navigate(to route: Route, with params: [String : Any]?, completion: (() -> Void)?) {
        super.navigate(to: route, with: params, completion: completion)
        self.params = params
        self.completion = completion
    }
    
    override func dismiss(animated: Bool = true ,completion: (() -> Void)? = nil){
        super.dismiss(animated: animated, completion: completion)
        self.dismissCompletion = completion
    }
    
}
