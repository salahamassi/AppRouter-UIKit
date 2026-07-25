# AppRouter-UIKit

[![CI](https://github.com/salahamassi/AppRouter-UIKit/actions/workflows/CI.yml/badge.svg)](https://github.com/salahamassi/AppRouter-UIKit/actions/workflows/CI.yml)
[![Swift](https://img.shields.io/badge/Swift-5.3+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-11.0+-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

A lightweight, type-safe navigation framework for UIKit. Born from real production challenges at [WINCH](https://winchksa.com), AppRouter eliminates navigation boilerplate and enforces clean composition patterns.

<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/e77aea4c-3227-40ff-8bac-5983ec040e59" />

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/salahamassi/AppRouter-UIKit.git", from: "1.0.9")
]
```

## Quick Start

### 1. Set up the router

```swift
// AppDelegate
var appRouter: AppRouter?

func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
    let nav = UINavigationController()
    appRouter = AppRouter(window: window, rootViewController: nav)
    return true
}
```

### 2. Make view controllers routable

```swift
extension UIViewController: Routable {
    var router: AppRouter? { appRouter }
}
```

### 3. Create routes

```swift
class ProfileRoute: Route {
    var navigateType: NavigateType { .push }

    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController {
        let userId = params?["userId"] as? String ?? ""
        return ProfileViewController(userId: userId)
    }
}
```

### 4. Navigate

```swift
router?.navigate(to: ProfileRoute(), with: ["userId": "123"])
```

## Navigation Types

| Type | Description |
|------|-------------|
| `.push` | Push onto navigation stack |
| `.present` | Modal presentation |
| `.windowRoot` | Replace window root controller |
| `.addChild(parent, view:, safeArea:)` | Add as child with nested router |

## Features

### Type-Safe Route Composition

Each screen's dependencies are composed in its `Route` — not scattered across the codebase:

```swift
class OrderDetailsRoute: Route {
    var navigateType: NavigateType { .push }

    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController {
        guard let orderId = params?["orderId"] as? String else {
            fatalError("OrderDetailsRoute requires orderId")
        }
        let loader = OrderDetailsLoader()
        let presenter = OrderDetailsPresenter()
        return OrderDetailsViewController(orderId: orderId, loader: loader, presenter: presenter)
    }
}
```

### Quick Routes with RouteFactory

For simple screens without complex composition:

```swift
let route: RouteFactory<SettingsViewController> = RouteFactory.createRoute(navigateType: .push)
router?.navigate(to: route)
```

### Duplicate Prevention

Prevent the same screen from being pushed twice:

```swift
router?.canDuplicateViewControllers = false
```

### Stack Management

```swift
router?.popViewController()                          // Pop one
router?.pop(numberOfScreens: 2)                      // Pop multiple
router?.remove(types: [LoadingViewController.self])   // Remove specific types
router?.removeAllAndKeep(types: [HomeViewController.self])  // Keep only these
```

### Nested (Inner) Routers

For container patterns like tab bars with embedded navigation:

```swift
class OrdersRoute: Route {
    let parent: UIViewController
    let containerView: UIView

    var navigateType: NavigateType {
        .addChild(parent, view: containerView, safeArea: true)
    }

    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController {
        UINavigationController(rootViewController: OrdersViewController())
    }
}

// Child screens use innerRouter instead of the main router
innerRouter?.navigate(to: .orderDetails(params: ["orderId": order.id]))
```

### Custom Transitions

```swift
class FadeRoute: Route {
    var navigateType: NavigateType { .push }
    var transition: CATransition? {
        let t = CATransition()
        t.type = .fade
        return t
    }

    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController {
        FadeViewController()
    }
}
```

### Custom Presentation

```swift
class PhotoPreviewRoute: Route {
    private let animator = PhotosPresentDismissAnimator()

    var navigateType: NavigateType { .present }
    var modalPresentationStyle: UIModalPresentationStyle { .custom }
    var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate? { animator }

    func create(_ router: AppRouter, _ params: [String: Any]?) -> UIViewController {
        PhotoPreviewViewController(medias: params?["medias"] as? [Media] ?? [])
    }
}
```

## Organizing Routes

Use enums with Swift extensions for clean route access:

```swift
enum AuthRoutes {
    case signin
    case signup
    case pinCode(mobile: String)
}

extension AppRouter {
    func navigate(to route: AuthRoutes) {
        switch route {
        case .signin:
            navigate(to: SigninRoute())
        case .signup:
            navigate(to: SignupRoute())
        case .pinCode(let mobile):
            navigate(to: PinCodeRoute(), with: ["mobile": mobile])
        }
    }
}

// Usage
router?.navigate(to: .signin)
router?.navigate(to: .pinCode(mobile: "+966501234567"))
```

## Testing

24 tests covering all navigation scenarios:

```
Executed 24 tests, with 0 failures in 7.6 seconds
```

## The Problem

Navigation in UIKit apps often looks like this:

```swift
let vc = ServiceLocationViewController()
let presenter = ServiceLocationPresenter(output: WeakRef(vc))
let dataSource = AppDataSource()
let useCase = ServiceLocationUseCase(dataSource: dataSource, output: presenter, selectedLocationType: type)
vc.startLocationUpdate = useCase.startLocationUpdate
vc.confirmLocateServiceAction = useCase.confirmLocateServiceAction
navigationController?.pushViewController(vc, animated: true)
```

Composition logic scattered everywhere. Duplicate code. No consistency.

## The Solution

```swift
router?.navigate(to: .serviceLocation(params: ["selectedLocationType": type]))
```

One line. All composition hidden behind a `Route` protocol.

## Why AppRouter?

- **Zero dependencies** — Pure UIKit, no third-party frameworks
- **Production-tested** — Powers WINCH's logistics platform serving Gulf clients
- **Lightweight** — Simple protocol-based API, easy to adopt incrementally
- **Testable** — Router can be mocked for unit testing navigation logic

## Author

**Salah Nahed** — Senior Mobile Engineer

- [GitHub](https://github.com/salahamassi)
- [LinkedIn](https://www.linkedin.com/in/salah-nahed-a73250135)
- [Medium](https://medium.com/@salahamassi)

## License

MIT
