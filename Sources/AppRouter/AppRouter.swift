//
//  AppRouter.swift
//
//
//  Created by Salah Amassi on 17/12/2020.
//

import UIKit

public class AppRouter {
    
    public let window: UIWindow
    public var canDuplicateViewControllers = true
    /// you must set this value in navigation controller delegate willShow viewController
    public var lastPushedViewController: UIViewController? = nil
    
    public var navigationController: UINavigationController {
        get{
            if let navigationController = presentedViewController as? UINavigationController{
                return navigationController
            }else if let tabBarController = presentedViewController as? UITabBarController,
                     let navigationController = tabBarController.selectedViewController as? UINavigationController{
                return navigationController
            }else if let tabBarController = presentedViewController.children.first(where: { $0 is UITabBarController }) as? UITabBarController,
                     let navigationController = tabBarController.selectedViewController as? UINavigationController{
                return navigationController
            }else if let navigationController = presentedViewController.children.first(where: { $0 is UINavigationController }) as? UINavigationController{
                return navigationController
            }else if let navigationController = window.rootViewController as? UINavigationController{
                return navigationController
            }else if let navigationController = window.rootViewController?.children.first(where: { $0 is UINavigationController }) as? UINavigationController{
                return navigationController
            }else{
                fatalError("there are no navigation controller")
            }
        }
    }
    
    public var presentedViewController: UIViewController {
        get{
            guard let rootViewController = window.rootViewController else { fatalError("rootViewController cann't be nil") }
            return presentedViewController(rootViewController)
        }
    }
    
    public init(window: UIWindow, rootViewController: UIViewController? = nil) {
        self.window = window
        if let rootViewController = rootViewController{
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
    }
    
    public func navigate(to route: Route, with params: [String: Any]?, completion: (() -> Void)?) {
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
    
    private func presentViewController(_ viewController: UIViewController, presentationStyle: UIModalPresentationStyle, transitioningDelegate: UIViewControllerTransitioningDelegate?, animated: Bool, completion: (() -> Void)?) {
        viewController.modalPresentationStyle = presentationStyle
        viewController.transitioningDelegate = transitioningDelegate
        presentedViewController.present(viewController, animated: animated, completion: completion)
    }
    
    private func pushViewController(_ viewController: UIViewController, pushTransition: CATransition? = nil, animated: Bool = true) {
        if let pushTransition = pushTransition{
            navigationController.view.layer.add(pushTransition, forKey: kCATransition)
        }
        if canPushViewController(viewController) {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    private func replaceWindowRoot(with viewController: UIViewController) {
        UIView.transition(with: window,
                        duration: 0.8,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.window.rootViewController = viewController
                            self.window.makeKeyAndVisible()
                        },
                        completion: { completed in })
    }
    
    public func popViewController(popTransition: CATransition? = nil, animated: Bool = true) {
        if let popTransition = popTransition{
            navigationController.view.layer.add(popTransition, forKey: kCATransition)
        }
        navigationController.popViewController(animated: animated)
    }
    
    public func popToRootViewController(popTransition: CATransition? = nil, animated: Bool = true) {
        if let popTransition = popTransition{
            navigationController.view.layer.add(popTransition, forKey: kCATransition)
        }
        navigationController.popToRootViewController(animated: animated)
    }
    
    public func pop(numberOfScreens: Int, popTransition: CATransition? = nil, animated: Bool = true) {
        if numberOfScreens <= navigationController.viewControllers.count - 1 {
            if let popTransition = popTransition{
                navigationController.view.layer.add(popTransition, forKey: kCATransition)
            }
            navigationController.popToViewController(navigationController.viewControllers[navigationController.viewControllers.count - (numberOfScreens + 1)], animated: animated)
        }
    }
    
    public func remove(numberOfScreens: Int){
        if numberOfScreens <= navigationController.viewControllers.count - 1 {
            navigationController.viewControllers.removeSubrange(1...numberOfScreens)
        }
    }
    
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        presentedViewController.dismiss(animated: animated, completion: completion)
    }
    
    public func removeAllAndKeep(types: [AnyClass], animated: Bool = true) {
        var viewControllers = navigationController.viewControllers
        viewControllers.removeAll { (viewController) -> Bool in
            let viewControllerType = type(of: viewController)
            return !types.contains(where: { $0 == viewControllerType })
        }
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
    
    public func remove(types: [AnyClass], animated: Bool = true) {
        var viewControllers = navigationController.viewControllers
        viewControllers.removeAll { (viewController) -> Bool in
            let viewControllerType = type(of: viewController)
            return types.contains(where: { $0 == viewControllerType })
        }
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
    
    private func presentedViewController(_ viewController: UIViewController) -> UIViewController {
        if let mPresentedViewController = viewController.presentedViewController{
            return presentedViewController(mPresentedViewController)
        }else{
            return viewController
        }
    }
    
    private func canPushViewController(_ viewController: UIViewController) -> Bool {
        if !canDuplicateViewControllers {
            let children = navigationController.children.map(\.className)
            if children.last?.className == viewController.className {
                return false // view controller already in the stack
            }else if let lastPushedViewController = lastPushedViewController, type(of: lastPushedViewController) == type(of: viewController){
                return false // in case the view controller not in the stack but lastPushedViewController type eqault to viewController type
            }else {
                lastPushedViewController = viewController
                return true // we can push the new viewController safely
            }
        }else{
            return true // i don't care about duplications just return true
        }
    }
}
