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
    private var nestedViewController: UIViewController?
    
    private(set) public var nestedRouters: [UIViewController: AppRouter] = [:]
    private(set) public var liveRoutes: [UIViewController] = [] // Keeps track of live routes
    
    public var navigationController: UINavigationController? {
        get {
            if let navigationController = presentedViewController as? UINavigationController {
                return navigationController
            } else if let tabBarController = presentedViewController as? UITabBarController,
                      let navigationController = tabBarController.selectedViewController as? UINavigationController {
                return navigationController
            } else if let tabBarController = presentedViewController?.children.first(where: { $0 is UITabBarController }) as? UITabBarController,
                      let navigationController = tabBarController.selectedViewController as? UINavigationController {
                return navigationController
            } else if let navigationController = presentedViewController?.children.first(where: { $0 is UINavigationController  }) as? UINavigationController {
                return navigationController
            } else if let navigationController =  presentedViewController?.children.first?.children.first(where: { $0 is UINavigationController }) as? UINavigationController {
                return navigationController
            } else if let navigationController = window.rootViewController as? UINavigationController {
                return navigationController
            } else if let navigationController = window.rootViewController?.children.first(where: { $0 is UINavigationController }) as? UINavigationController {
                return navigationController
            } else {
                return nil
            }
        }
    }
    
    public var presentedViewController: UIViewController? {
        get {
            if let nestedViewController = nestedViewController {
                return nestedViewController
            } else {
                guard let rootViewController = window.rootViewController else { return nil }
                return presentedViewController(rootViewController)
            }
        }
    }
    
    public init(window: UIWindow, rootViewController: UIViewController? = nil, nestedRouter: Bool = false) {
        self.window = window
        if let rootViewController = rootViewController, !nestedRouter {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
        self.nestedViewController = rootViewController
    }
    
    public func navigate(to route: Route, with params: [String: Any]?, completion: (() -> Void)?) {
        let viewController = route.create(self, params)
        switch route.navigateType {
        case .present:
            presentViewController(viewController, presentationStyle: route.modalPresentationStyle, transitioningDelegate: route.animatedTransitioningDelegate, animated: route.animated, completion: completion)
        case .push:
            pushViewController(viewController, pushTransition: route.transition, animated: route.animated)
        case .windowRoot:
            replaceWindowRoot(with: viewController, transition: route.transition, completion: completion)
        case .addChild(let parent, let view, let safeArea, let frame):
            addViewController(viewController, to: parent, in: view, at: frame, safeArea)
        }
        liveRoutes.append(viewController) // Track the route
    }
    
    private func addViewController(_ child: UIViewController,
                                   to parent: UIViewController,
                                   in view: UIView,
                                   at frame: CGRect?,
                                   _ safeArea: Bool = false) {
        parent.addChild(child)
        view.addSubview(child.view)
        if let frame = frame {
            child.view.frame = frame
        } else {
            let superviewTopAnchor = safeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor
            let superviewBottomAnchor = safeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor
            let superviewLeadingAnchor = safeArea ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor
            let superviewTrailingAnchor = safeArea ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor
            
            NSLayoutConstraint.activate([
                child.view.topAnchor.constraint(equalTo: superviewTopAnchor),
                child.view.bottomAnchor.constraint(equalTo: superviewBottomAnchor),
                child.view.leadingAnchor.constraint(equalTo: superviewLeadingAnchor),
                child.view.trailingAnchor.constraint(equalTo: superviewTrailingAnchor),
            ])
        }
        child.didMove(toParent: parent)
        nestedRouters[child] = AppRouter(window: window, rootViewController: child, nestedRouter: true)
    }
    
    private func presentViewController(_ viewController: UIViewController, presentationStyle: UIModalPresentationStyle, transitioningDelegate: UIViewControllerTransitioningDelegate?, animated: Bool, completion: (() -> Void)?) {
        guard let presentedViewController = presentedViewController else { return }
        viewController.modalPresentationStyle = presentationStyle
        viewController.transitioningDelegate = transitioningDelegate
        presentedViewController.present(viewController, animated: animated, completion: completion)
    }
    
    private func pushViewController(_ viewController: UIViewController, pushTransition: CATransition? = nil, animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        if let pushTransition = pushTransition{
            navigationController.view.layer.add(pushTransition, forKey: kCATransition)
        }
        if canPushViewController(viewController) {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    private func replaceWindowRoot(with viewController: UIViewController,
                                   transition: CATransition? = nil,
                                   completion: (() -> Void)? = nil) {
        if let transition = transition {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                completion?()
            }
            window.layer.add(transition, forKey: kCATransition)
            CATransaction.commit()
        }
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.nestedViewController = viewController
        // If no transition, manually invoke the completion
        if transition == nil {
            completion?()
        }
    }
    
    public func popViewController(popTransition: CATransition? = nil, animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        if let topViewController = navigationController.topViewController {
            liveRoutes.removeAll { $0 == topViewController } // Remove from live routes
        }
        if let popTransition = popTransition{
            navigationController.view.layer.add(popTransition, forKey: kCATransition)
        }
        navigationController.popViewController(animated: animated)
    }
    
    public func popToRootViewController(popTransition: CATransition? = nil, animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        let rootViewController = navigationController.viewControllers.first
        liveRoutes.removeAll { $0 != rootViewController } // Keep only the root view controller
        if let popTransition = popTransition{
            navigationController.view.layer.add(popTransition, forKey: kCATransition)
        }
        navigationController.popToRootViewController(animated: animated)
    }
    
    public func pop(numberOfScreens: Int, popTransition: CATransition? = nil, animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        if numberOfScreens <= navigationController.viewControllers.count - 1 {
            if let popTransition = popTransition {
                navigationController.view.layer.add(popTransition, forKey: kCATransition)
            }
            
            let targetViewControllerIndex = navigationController.viewControllers.count - (numberOfScreens + 1)
            let targetViewController = navigationController.viewControllers[targetViewControllerIndex]
            
            // Remove popped view controllers from liveRoutes
            let poppedViewControllers = navigationController.viewControllers[(targetViewControllerIndex + 1)...]
            liveRoutes.removeAll { poppedViewControllers.contains($0) }
            
            navigationController.popToViewController(targetViewController, animated: animated)
        }
    }
    
    public func remove(numberOfScreens: Int) {
        guard let navigationController = navigationController else { return }
        if numberOfScreens <= navigationController.viewControllers.count - 1 {
            // Remove view controllers from the navigation stack
            let removedViewControllers = navigationController.viewControllers[1...numberOfScreens]
            liveRoutes.removeAll { removedViewControllers.contains($0) } // Remove from liveRoutes
            navigationController.viewControllers.removeSubrange(1...numberOfScreens)
        }
    }
    
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let presentedViewController = presentedViewController else { return }
        liveRoutes.removeAll { $0 == presentedViewController } // Remove from live routes
        presentedViewController.dismiss(animated: animated, completion: completion)
    }
    
    public func removeAllAndKeep(types: [AnyClass], animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        var viewControllers = navigationController.viewControllers
        viewControllers.removeAll { (viewController) -> Bool in
            let viewControllerType = type(of: viewController)
            return !types.contains(where: { $0 == viewControllerType })
        }
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
    
    public func remove(types: [AnyClass], animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        var viewControllers = navigationController.viewControllers
        let removedViewControllers = viewControllers.filter { viewController in
            types.contains { $0 == type(of: viewController) }
        }
        
        // Remove filtered view controllers from liveRoutes
        liveRoutes.removeAll { removedViewControllers.contains($0) }
        
        viewControllers.removeAll { viewController in
            types.contains { $0 == type(of: viewController) }
        }
        
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
    
    public func removeChild(_ childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
        nestedRouters[childViewController] = nil
        liveRoutes.removeAll { $0 == childViewController } // Remove from liveRoutes
    }
    
    private func presentedViewController(_ viewController: UIViewController) -> UIViewController {
        if let mPresentedViewController = viewController.presentedViewController {
            return presentedViewController(mPresentedViewController)
        } else {
            return viewController
        }
    }
    
    private func canPushViewController(_ viewController: UIViewController) -> Bool {
        guard let navigationController = navigationController else { return false }
        if !canDuplicateViewControllers {
            let children = navigationController.children.map(\.className)
            if children.last?.className == viewController.className {
                return false // view controller already in the stack
            } else if let lastPushedViewController = lastPushedViewController, type(of: lastPushedViewController) == type(of: viewController) {
                return false // in case the view controller not in the stack but lastPushedViewController type eqault to viewController type
            } else {
                lastPushedViewController = viewController
                return true // we can push the new viewController safely
            }
        }else{
            return true // i don't care about duplications just return true
        }
    }
}
