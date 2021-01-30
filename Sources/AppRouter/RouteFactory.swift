//
//  RouteFactory.swift
//  
//
//  Created by Salah Amassi on 26/12/2020.
//

import UIKit

public typealias StoryboardViewController = (storyBoardName: String, viewControllerIdentifier: String)

private struct RouteFactory<T: UIViewController>: Route where T: Routable {
    
    var navigateType: NavigateType {
        mNavigateType
    }
    
    let mNavigateType: NavigateType
    let storyboardViewController: StoryboardViewController?
    let nibName: String?
    
    init(navigateType: NavigateType, storyboardViewController: StoryboardViewController?, nibName: String?) {
        self.mNavigateType = navigateType
        self.storyboardViewController = storyboardViewController
        self.nibName = nibName
    }
    
    func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
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
}

public extension Route {

    static func createRoute<T: UIViewController>(_ type: T,
                                                   storyboardViewController: StoryboardViewController? = nil,
                                                   nibName: String? = nil,
                                                   navigateType: NavigateType) -> Route  where T: Routable {
        RouteFactory<T>(navigateType: navigateType, storyboardViewController: storyboardViewController, nibName: nibName)
    }
}

