import XCTest
@testable import AppRouter

final class AppRouterTests: XCTestCase {
    
    func test_initWithRootViewContrllerNil_shouldBeNotNil(){ // need to fix
        // given
        let sut = makeSut(rootViewController: nil)
        
        // when
        sut.navigate(to: TestWindowRootRoute(), with: nil, completion: nil)
        
        //then
        XCTAssertNotNil(sut.window.rootViewController)
    }
    
    func test_navigateWithRootwindowType(){
        // given
        let sut = makeSut()
        
        // when
        sut.navigate(to: TestWindowRootRoute(), with: nil, completion: nil)
        
        //then
        XCTAssertTrue(sut.window.rootViewController is MockViewController)
    }
    
    func test_navigateWithPresentType(){
        // given
        let sut = makeSut()
        
        // when
        sut.navigate(to: TestPresentRoute(), with: nil, completion: nil)
        
        //then
        XCTAssertTrue(sut.window.rootViewController?.presentedViewController is MockViewController)
    }
    
    func test_navigateWithPushType(){
        // given
        let rootViewController = UINavigationController()
        let sut = makeSut(rootViewController: rootViewController)
        
        // when
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        
        //then
        XCTAssertTrue(rootViewController.topViewController is MockViewController)
    }
    
    func test_routeParams(){
        // given
        let sut = makeSut()
        let route = TestPresentRoute()
        let params =  ["Test" : "valid"]
        
        // when
        sut.navigate(to: route, with: params, completion: nil)
        
        //then
        XCTAssertNotNil(route.params)
        XCTAssertEqual(route.params!["Test"] as? String, params["Test"])
    }
    
    func test_routeCompletion(){
        // given
        let sut = makeSut()
        let route = TestPresentRoute()
        let completion =  {  }
        
        // when
        sut.navigate(to: route, with: nil, completion: completion)
        
        //then
        XCTAssertNotNil(sut.completion)
    }
    
    func test_routeModalPresentationStyle(){
        // given
        let sut = makeSut()
        let route = TestPresentRoute()
        
        // when
        sut.navigate(to: route, with: nil, completion: nil)
        
        //then
        XCTAssertEqual(route.modalPresentationStyle, sut.window.rootViewController?.presentedViewController?.modalPresentationStyle)
    }
    
    func test_routeAnimatedTransitioningDelegate(){
        // given
        let sut = makeSut()
        let route = TestPresentRoute()
        
        // when
        sut.navigate(to: route, with: nil, completion: nil)
        
        //then
        XCTAssert(type(of: route.animatedTransitioningDelegate) == type(of: sut.window.rootViewController?.presentedViewController?.transitioningDelegate))
    }
    
    func test_popViewController(){
        // given
        let rootViewController = UINavigationController()
        let sut = makeSut(rootViewController: rootViewController)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        
        // when
        sut.popViewController(animated: false)
        let expectation = XCTestExpectation(description: "pop view controller success")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(rootViewController.viewControllers.count, 2)
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 5)
    }
    
    func test_popNumberOfScreens(){
        // given
        let rootViewController = UINavigationController()
        let sut = makeSut(rootViewController: rootViewController)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        
        // when
        let expectation = XCTestExpectation(description: "pop number of view controllers success")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sut.pop(numberOfScreens: 2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(rootViewController.viewControllers.count, 1)
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 5)
    }
    
    func test_removeNumberOfScreens(){
        // given
        let rootViewController = UINavigationController()
        let sut = makeSut(rootViewController: rootViewController)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        
        // when
        let expectation = XCTestExpectation(description: "pop number of view controllers success")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sut.remove(numberOfScreens: 2)
            XCTAssertEqual(rootViewController.viewControllers.count, 1)
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 5)
    }
    
    func test_dismissViewControllerCompletion(){
        let sut = makeSut()
        let route = TestPresentRoute()
        let completion =  {  }
        
        // when
        sut.navigate(to: route, with: nil, completion: nil)
        sut.dismiss(completion: completion)
        
        //then
        XCTAssertNotNil(sut.dismissCompletion)
    }
    
    func test_dismissViewController(){
        //given
        let sut = makeSut()
        sut.navigate(to: TestPresentRoute(), with: nil, completion: nil)
        
        // when
        let expectation = XCTestExpectation(description: "dismiss view controller success")
        sut.dismiss(animated: false, completion: {
            sut.dismissCompletion = nil // we need to make dismissCompletion to avoid memory leak during test
            XCTAssertNil(sut.window.rootViewController?.presentedViewController)
            expectation.fulfill()
        })
        
        //then
        wait(for: [expectation], timeout: 5)
    }
    
    func test_injectAppRouteToViewController(){
        // given
        let sut = makeSut()
        
        // when
        sut.navigate(to: TestPresentRoute(), with: nil, completion: nil)
        
        //then
        XCTAssertNotNil((sut.window.rootViewController?.presentedViewController as? MockViewController)?.router)
    }
    
    private weak var weakSUT: AppRouterMock?
    
    override func tearDown() {
        super.tearDown()
        XCTAssertNil(weakSUT, "Memory leak detected. Weak reference to the SUT instance is not nil.")
    }
    
    // MARK:- helpers
    
    private func makeSut(rootViewController: UIViewController? = UIViewController()) -> AppRouterMock{
        let window = UIWindow() // i suppose it must not to be nil
        let router = AppRouterMock(window: window, rootViewController: rootViewController)
        weakSUT = router
        return router
    }
    
    private class AppRouterMock: AppRouter {
        
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
    
    private class TestPushRoute: Route{
        
        var modalPresentationStyle: UIModalPresentationStyle{
            .none
        }
        
        var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate?{
            nil
        }
        
        var navigateType: NavigateType{
            .push
        }
        
        var pushTransition: CATransition?{
            nil
        }
        
        var animated: Bool{
            false
        }
        
        func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
            return MockViewController(router: router)
        }
        
    }
    
    private class TestPresentRoute: Route{
        
        var modalPresentationStyle: UIModalPresentationStyle{
            .custom
        }
        
        var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate?{
            MockAnimatedTransitioningDelegate()
        }
        
        var navigateType: NavigateType{
            .present
        }
        
        var pushTransition: CATransition?{
            nil
        }
        
        var animated: Bool{
            false
        }
        
        var params: [String: Any]? =  nil
        
        
        func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
            self.params = params
            return MockViewController(router: router)
        }
        
    }
    
    private class TestWindowRootRoute: Route{
        
        var modalPresentationStyle: UIModalPresentationStyle{
            .none
        }
        
        var animatedTransitioningDelegate: UIViewControllerTransitioningDelegate?{
            nil
        }
        
        var navigateType: NavigateType{
            .windowRoot
        }
        
        var pushTransition: CATransition?{
            nil
        }
        
        var animated: Bool{
            false
        }
        
        func create(_ router: AppRouter, _ params: [String : Any]?) -> UIViewController {
            return MockViewController(router: router)
        }
        
    }
    
    
    
    private class MockViewController: UIViewController {
        
        weak var router: AppRouter?
        
        init(router: AppRouter) {
            self.router = router
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    private class MockAnimatedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate{}
    
}
