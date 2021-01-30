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
    
    func test_navigateWithRootwindowType_shouldEqaulToMockViewController() {
        // given
        let sut = makeSut()
        
        // when
        sut.navigate(to: TestWindowRootRoute(), with: nil, completion: nil)
        
        //then
        XCTAssertTrue(sut.window.rootViewController is MockViewController)
    }
    
    func test_navigateWithPresentType_shouldEqaulToMockViewController() {
        // given
        let sut = makeSut()
        
        // when
        sut.navigate(to: TestPresentRoute(), with: nil, completion: nil)
        
        //then
        XCTAssertTrue(sut.window.rootViewController?.presentedViewController is MockViewController)
    }
    
    func test_navigateWithPushType_shouldEqaulToMockViewController() {
        // given
        let rootViewController = UINavigationController()
        let sut = makeSut(rootViewController: rootViewController)
        
        // when
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        
        //then
        XCTAssertTrue(rootViewController.topViewController is MockViewController)
    }
    
    func test_routeParams_shouldNotNil() {
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
    
    func test_routeCompletion_shouldNotNil() {
        // given
        let sut = makeSut()
        let route = TestPresentRoute()
        let completion =  {  }
        
        // when
        sut.navigate(to: route, with: nil, completion: completion)
        
        //then
        XCTAssertNotNil(sut.completion)
    }
    
    func test_routeModalPresentationStyle_shouldEqaulViewControllerModalPresentationStyle() {
        // given
        let sut = makeSut()
        let route = TestPresentRoute()
        
        // when
        sut.navigate(to: route, with: nil, completion: nil)
        
        //then
        XCTAssertEqual(route.modalPresentationStyle, sut.window.rootViewController?.presentedViewController?.modalPresentationStyle)
    }
    
    func test_routeAnimatedTransitioningDelegate_shouldEqaulViewControllerTransitioningDelegate(){
        // given
        let sut = makeSut()
        let route = TestPresentRoute()
        
        // when
        sut.navigate(to: route, with: nil, completion: nil)
        
        //then
        XCTAssert(type(of: route.animatedTransitioningDelegate) == type(of: sut.window.rootViewController?.presentedViewController?.transitioningDelegate))
    }
    
    func test_pushThreeViewController_thenPop_shouldCountEqualTwo() {
        // given
        let rootViewController = UINavigationController()
        let sut = makeSut(rootViewController: rootViewController)
        
        // when
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.popViewController(animated: false)
        let expectation = XCTestExpectation(description: "pop view controller success")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(rootViewController.viewControllers.count, 2)
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 5)
    }
    
    func test_pushThreeViewController_thenPopNumberOfScreensTwo_shouldCountEqualOne() {
        // given
        let rootViewController = UINavigationController()
        let sut = makeSut(rootViewController: rootViewController)
        
        // when
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
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
    
    func test_pushThreeViewController_thenRemoveNumberOfScreens_shouldCountEqualOne() {
        // given
        let rootViewController = UINavigationController()
        let sut = makeSut(rootViewController: rootViewController)
        
        // when
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        sut.navigate(to: TestPushRoute(), with: nil, completion: nil)
        let expectation = XCTestExpectation(description: "pop number of view controllers success")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sut.remove(numberOfScreens: 2)
            XCTAssertEqual(rootViewController.viewControllers.count, 1)
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 5)
    }
    
    func test_dismissViewControllerCompletion_shouldNotNil() {
        // given
        let sut = makeSut()
        let route = TestPresentRoute()
        let completion =  {  }
        
        // when
        sut.navigate(to: route, with: nil, completion: nil)
        sut.dismiss(completion: completion)
        
        //then
        XCTAssertNotNil(sut.dismissCompletion)
    }
    
    func test_routeFactoryWindowRoot_windowRootTypeSholdBeMockViewController() {
        // given
        let sut = makeSut()
        
        // when
        let route: RouteFactory<MockViewController> = RouteFactory.createRoute(navigateType: .windowRoot)
        sut.navigate(to: route, with: nil, completion: nil)
                
        //then
        XCTAssertTrue(sut.window.rootViewController is MockViewController)
    }
    
    private weak var weakSUT: AppRouterMock?
    
    override func tearDown() {
        super.tearDown()
        XCTAssertNil(weakSUT, "Memory leak detected. Weak reference to the SUT instance is not nil.")
    }
    
    // MARK:- helpers
    private func makeSut(rootViewController: UIViewController? = UIViewController()) -> AppRouterMock {
        let window = UIWindow() // i suppose it must not to be nil
        let router = AppRouterMock(window: window, rootViewController: rootViewController)
        weakSUT = router
        return router
    }
}
