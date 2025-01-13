//
//  RouteFactory.swift
//  
//
//  Created by Salah Amassi on 26/12/2020.
//

import UIKit


public struct RouteFactory<T: Routable>: Route {
    
    public typealias StoryboardViewController = (storyBoardName: String, viewControllerIdentifier: String)
    
    private let mNavigateType: NavigateType
    private let mAnimated: Bool
    private let storyboardViewController: StoryboardViewController?
    private let nibName: String?
    
    private init(navigateType: NavigateType,
                 animated: Bool,
                 storyboardViewController: StoryboardViewController?,
                 nibName: String?) {
        self.mNavigateType = navigateType
        self.mAnimated = animated
        self.storyboardViewController = storyboardViewController
        self.nibName = nibName
    }
    
    public var navigateType: NavigateType {
        mNavigateType
    }
    
    public var animated: Bool {
        mAnimated
    }
    
    public func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
        let viewController: UIViewController
        if let storyboardViewController = storyboardViewController {
            let bundle = Bundle(for: T.self)
            let storyboard = UIStoryboard(name: storyboardViewController.storyBoardName, bundle: bundle)
            viewController = storyboard.instantiateViewController(withIdentifier: storyboardViewController.storyBoardName)
        }else if let nibName = nibName{
            let bundle = Bundle(for: T.self)
            viewController = T(nibName: nibName, bundle: bundle)
        }else{
            viewController = T()
        }
        return viewController
    }
    
    public static func createRoute(storyboardViewController: StoryboardViewController? = nil,
                                                nibName: String? = nil,
                                                navigateType: NavigateType,
                                                animated: Bool = false) -> RouteFactory<T> {
        RouteFactory<T>(navigateType: navigateType,
                        animated: animated,
                        storyboardViewController: storyboardViewController,
                        nibName: nibName)
    }
}
