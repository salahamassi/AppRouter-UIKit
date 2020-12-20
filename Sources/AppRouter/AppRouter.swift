//
//  AppRouter.swift
//
//
//  Created by Salah Amassi on 17/12/2020.
//

import UIKit

public class AppRouter{
    
    public let window: UIWindow
    
    var navigationController: UINavigationController{
        get{
            guard let rootViewController = window.rootViewController else { fatalError("rootViewController cann't be nil") }
            if let rootViewController = rootViewController as? UINavigationController{
                return rootViewController
            }else if let rootViewController = window.rootViewController?.children.last as? UINavigationController{
                return rootViewController
            }else{
                fatalError("there are no navigation controller")
            }
        }
    }
    
    var presentedViewController: UIViewController{
        get{
            guard let rootViewController = window.rootViewController else { fatalError("rootViewController cann't be nil") }
            return rootViewController.presentedViewController == nil ? rootViewController : rootViewController.presentedViewController!
        }
    }
        
    public init(window: UIWindow, rootViewController: UIViewController? = nil) {
        self.window = window
        if let rootViewController = rootViewController{
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
    }
    
    public func navigate(to route: Route, with params: [String: Any]?, completion: (() -> Void)?){
        let viewController = route.create(self, params)
        switch route.navigateType {
        case .present:
            presentViewController(viewController, presentationStyle: route.modalPresentationStyle, transitioningDelegate: route.animatedTransitioningDelegate, animated: route.animated, completion: completion)
        case .push:
            pushViewController(viewController, pushTransition: route.pushTransition, animated: route.animated)
        case .windowRoot:
            replaceWindowRoot(with: viewController)
        }
    }
    
    private func presentViewController(_ viewController: UIViewController, presentationStyle: UIModalPresentationStyle, transitioningDelegate: UIViewControllerTransitioningDelegate?, animated: Bool, completion: (() -> Void)?){
        viewController.modalPresentationStyle = presentationStyle
        viewController.transitioningDelegate = transitioningDelegate
        presentedViewController.present(viewController, animated: animated, completion: completion)
    }
    
    private func pushViewController(_ viewController: UIViewController, pushTransition: CATransition? = nil, animated: Bool = true){
        if let pushTransition = pushTransition{
            navigationController.view.layer.add(pushTransition, forKey: kCATransition)
        }
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    private func replaceWindowRoot(with viewController: UIViewController){
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    public func popViewController(popTransition: CATransition? = nil, animated: Bool = true){
        if let popTransition = popTransition{
            navigationController.view.layer.add(popTransition, forKey: kCATransition)
        }
        navigationController.popViewController(animated: animated)
    }
    
    public func popToRootViewController(popTransition: CATransition? = nil, animated: Bool = true){
        if let popTransition = popTransition{
            navigationController.view.layer.add(popTransition, forKey: kCATransition)
        }
        navigationController.popToRootViewController(animated: animated)
    }
    
    public func pop(numberOfScreens: Int, popTransition: CATransition? = nil, animated: Bool = true){
        precondition(numberOfScreens + 1 <= navigationController.viewControllers.count)
        if let popTransition = popTransition{
            navigationController.view.layer.add(popTransition, forKey: kCATransition)
        }
        navigationController.popToViewController(navigationController.viewControllers[navigationController.viewControllers.count - (numberOfScreens + 1)], animated: animated)
    }
    
    public func remove(numberOfScreens: Int){
        precondition(numberOfScreens + 1 <= navigationController.viewControllers.count)
        navigationController.viewControllers.removeSubrange(1...numberOfScreens)
    }
    
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil){
       presentedViewController.dismiss(animated: animated, completion: completion)
    }
    
    public func removeAllAndKeep(types: [AnyClass], animated: Bool = true){
        var viewControllers = navigationController.viewControllers
        viewControllers.removeAll { (viewController) -> Bool in
            let viewControllerType = type(of: viewController)
            return !types.contains(where: { $0 == viewControllerType })
        }
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
    
    public func remove(types: [AnyClass], animated: Bool = true){
        var viewControllers = navigationController.viewControllers
        viewControllers.removeAll { (viewController) -> Bool in
            let viewControllerType = type(of: viewController)
            return types.contains(where: { $0 == viewControllerType })
        }
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
    
}
