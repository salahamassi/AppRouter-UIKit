# AppRouter

[![CI](https://github.com/salahamassi/AppRouter-UIKit/actions/workflows/CI.yml/badge.svg)](https://github.com/salahamassi/AppRouter-UIKit/actions/workflows/CI.yml)

# What is it? 

App Route makes it easy to manage navigation between screens, hide the complexity of composing a new screen, prevent duplicate code.

instead of 

```swift
let serviceLocationViewController = ServiceLocationViewController()
let presenter = ServiceLocationPresenter(output: WeakRef(serviceLocationViewController))
let dataSource = AppDataSource()
let useCase = ServiceLocationUseCase(dataSource: dataSource, output: presenter, selectedLocationType: selectedLocationType)
serviceLocationViewController.startLocationUpdate = useCase.startLocationUpdate
serviceLocationViewController.confirmLocateServiceAction = useCase.confirmLocateServiceAction
serviceLocationViewController.cancelLocateServiceAction = useCase.cancelLocateServiceAction
navigationController?.pushViewController(serviceLocationViewController, animated: true)
```

We will hide all these complex composition details inside the route file and just using this line to navigate to service location ViewController

```swift
router?.navigate(to: .serviceLocation(params: ["selectedLocationType": SelectedLocationType.loading]))
```

------ 

# How to use it? 

1- in app delegate define a instance of app router 
```swift
 var appRouter: AppRouter?
```

2- when windows is ready, assign the app router instance as follow
```swift
 router = AppRouter(window: window, rootViewController: nil)
```
or if you want to pass the rootViewController
```swift
 let navigationController = UINavigationController()
 router = AppRouter(window: window, rootViewController: navigationController)
```

3- make the View Controller confirm the Routable protocol to have a Router instance for all uiviewController subclasses in the app
```swift
extension UIViewController: Routable {

    var router: AppRouter? {
        appRouter
    }
  }
```

4- create a new route type for new screen as follow 

```swift

class ServiceReportRoute: Route {

   // required
    var navigateType: NavigateType {
        .push
    }
    
    // your composition logic
    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController { 
        guard let order = params?["order"] as? Order else { fatalError("cann't push ServiceReportViewController without order") }
        let hideBackButton = params?["hideBackButton"] as? Bool ?? false
        let loader = ServiceReportLoaderCustomerLoader()
        let serviceReportViewController = ServiceReportViewController(order: order, loader: loader, hideBackButton: hideBackButton)
        return serviceReportViewController
    }
}
```

5- you can create a helper enum to access the routes directly using enum and swift extension 

```swift

enum AuthRouts {
    case customerSignin
    case pinCode(params: [String: Any])
    case customerSignup
    case businessSectorSignin
    case businessSectorSignup
}

extension AppRouter {
    
    func navigate(to route: AuthRouts){
        let mRoute: Route
        var mParams: [String: Any]?
        switch route {
        case .customerSignin:
            mRoute = CustomerSigninRoute()
            mParams = nil
        case .pinCode(params: let params):
            mRoute = PinCodeRoute()
            mParams = params
        case .customerSignup:
            mRoute = CustomerSignupRoute()
            mParams = nil
        case .businessSectorSignin:
            mRoute = BusinessSectorSigninRoute()
            mParams = nil
        case .businessSectorSignup:
            mRoute = BusinessSectorSignupRoute()
            mParams = nil
        case .doneRegister:
            mRoute = DoneRegisterRoute()
            mParams = nil
        case .forgetPassword:
            mRoute = ForgetPasswordRoute()
            mParams = nil
        case .changePassword(params: let params):
            mRoute = ChangePasswordRoute()
            mParams = params
        }
        navigate(to: mRoute, with: mParams, completion: nil)
    }
  }
```
```swift
 router?.navigate(to: .customerSignin)
 router?.navigate(to: .businessSectorSignin)
 router?.navigate(to: .pinCode(params: ["mobile": mobile ,"wasRecentlyCreated": result.wasRecentlyCreated]))
```

or directly without enum

```swift
 router?.navigate(to: CustomerSignupRoute())
 router?.navigate(to: BusinessSectorSigninRoute())
 router?.navigate(to: PinCodeRoute(), with: ["mobile": mobile ,"wasRecentlyCreated": result.wasRecentlyCreated], completion: nil)
```

and just that's it!

------ 

# Installation

Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/salahamassi/AppRouter-UIKit.git", .upToNextMajor(from: "1.0.9"))
]
```

------ 

## More options

* `RouteFactory` Class
 	* This class help you to create a route directly without create a new file (if your screen compsition is too simple without any details). 
```swift
 let simpleRoute: RouteFactory<SimpleViewController> = RouteFactory.createRoute(navigateType: .push)
 router?.navigate(to: simpleRoute)
```

### AppRouter Properties

* `navigationController`  
 	*  Access to the navigation controller on multiple scenarios (last presented, selected tab bar, as the first child to select tab bar, the window root, or the first child at the window root) and return nil if there are no navigationController after checked all above scenarios

* `presentedViewController`  
 	*  Access to the last presented view controller 

* `canDuplicateViewControllers` 
 	*  As the name suggest you can prevent the client from push the same type of view controller when this value is true

* `lastPushedViewController` 
 	*  The client is responsible to assign this value at (navigation controller delegate willShow viewController function), and the app AppRouter will use it to check Duplicates ViewControllers (app router cann't check Duplicates ViewControllers without this value).
```swift
extension AppNavigationController: UINavigationControllerDelegate {
    navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        router?.lastPushedViewController = viewController
    }
}
```

### Route Optionals Properties

* `modalPresentationStyle: UIModalPresentationStyle` 
* Modal presentation styles for presenting view controllers.


* `animatedTransitioningDelegate: UIViewControllerTransitioningDelegate?` 
* A set of methods that vend objects used to manage a fixed-length or interactive transition between view controllers.
* When using this value you must set `modalPresentationStyle` to custom and you must hold a reference for animatedTransitioningDelegate or it will be deallocated 
```swift
struct PhotosPreviewRoute: Route {

    private let animator = PhotosPreviewViewControllerPresentDismissAnimator()

    var modalPresentationStyle: UIModalPresentationStyle {
       .custom
    }
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate? {
       animator
    }

    var navigateType: NavigateType {
       .present
    }

    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController {
        guard let medias = params?["medias"] as? [MediaWrapper] else { fatalError("cann't start photosPreviewViewController without medias")}
        guard let currentIndex = params?["currentIndex"] as? Int else { fatalError("cann't start photosPreviewViewController without currentIndex")}
        guard let mustHideDeleteButton = params?["mustHideDeleteButton"] as? Bool else { fatalError("cann't start photosPreviewViewController without mustHideDeleteButton")}
        guard let mediaContainerView = params?["mediaContainerView"] as? HasMediaToPreview else { fatalError("cann't start photosPreviewViewController without mediaContainerView")}
        let delegate = params?["delegate"] as? PhotosPreviewViewControllerDelegate
        let photosPreviewViewController = PhotosPreviewViewController(router: router, medias: medias, currentIndex: currentIndex, mustHideDeleteButton: mustHideDeleteButton, delegate: delegate)
        animator.mediaContainerView = mediaContainerView
        return photosPreviewViewController
    }
}
```


* `transition: CATransition?` 
* An object that provides an animated transition between a layer's states.
* can animated the push navigate type and the windowRoot type.
```swift
    var transition: CATransition?{
        let transition = CATransition()
        transition.type = .fade
        return transition
    }
```

* `animated: Bool` 
* Specify true to animate the transition or false if you do not want the transition to be animated for all navigate type.
 


