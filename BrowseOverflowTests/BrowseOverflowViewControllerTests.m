//
//  BrowseOverflowViewControllerTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/16/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "BrowseOverflowViewController.h"
#import "TopicTableDataSource.h"

@interface BrowseOverflowViewControllerTests : XCTestCase
{
    BrowseOverflowViewController *viewController;
    SEL realViewDidAppear, testViewDidAppear;
    SEL realViewWillDisappear, testViewWillDisappear;
}
@end


// Some hacky shit to make this class more testable
static const char *notificationKey = "BrowseOverflowViewControllerTestsAssociatedNotificationKey";

@implementation BrowseOverflowViewController (TestNotificationDelivery)

- (void)userDidSelectTopicNotification: (NSNotification *)note {
    objc_setAssociatedObject(self, notificationKey, note, OBJC_ASSOCIATION_RETAIN);
}

@end

static const char *viewDidAppearKey = "BrowseOverflowViewControllerTestsViewDidAppearKey";
static const char *viewWillDisappearKey = "BrowseOverflowViewControllerTestsViewWillDisappearKey";
@implementation UIViewController (TestSuperclassCalled)

- (void)browseOverflowViewControllerTests_viewDidAppear:(BOOL)animated {
    // Note: instead of storing @(YES) to show that the method is called, we stash the parameter that
    // was called instead. That way in the test, if you do a get for this obj and it returns NULL,
    // you know the method wasn't called. If you do get this obj, you have the param it was called with.
    objc_setAssociatedObject(self, viewDidAppearKey, @(animated), OBJC_ASSOCIATION_RETAIN);
}
- (void)browseOverflowViewControllerTests_viewWillDisappear:(BOOL)animated {
    objc_setAssociatedObject(self, viewWillDisappearKey, @(animated), OBJC_ASSOCIATION_RETAIN);
}

@end


@implementation BrowseOverflowViewControllerTests

- (void)swapInstanceMethodsForClass:(Class)class
                        forSelector:(SEL)selector
                      otherSelector:(SEL)otherSelector
{
    Method method = class_getInstanceMethod(class, selector);
    Method otherMethod = class_getInstanceMethod(class, otherSelector);
    method_exchangeImplementations(method, otherMethod);
}

// Method swizzling is best done in setup and teardown, since it's the best way to guarantee that the
// methods get swizzled back to normal (imagine if a test threw an exception and didn't finish running)
//- (void)setUp
//{
//    realViewDidAppear = @selector(viewDidAppear:);
//    testViewDidAppear = @selector(browseOverflowViewControllerTests_viewDidAppear:);
//    realViewWillDisappear = @selector(viewWillDisappear:);
//    testViewWillDisappear = @selector(browseOverflowViewControllerTests_viewWillDisappear:);
//    [self swapInstanceMethodsForClass:[UIViewController class]
//                          forSelector:realViewDidAppear
//                        otherSelector:testViewDidAppear];
//    [self swapInstanceMethodsForClass:[UIViewController class]
//                          forSelector:realViewWillDisappear
//                        otherSelector:testViewWillDisappear];
//}
//
//- (void)tearDown
//{
//    [self swapInstanceMethodsForClass:[UIViewController class]
//                          forSelector:realViewDidAppear
//                        otherSelector:testViewDidAppear];
//    [self swapInstanceMethodsForClass:[UIViewController class]
//                          forSelector:realViewWillDisappear
//                        otherSelector:testViewWillDisappear];
//}

- (BrowseOverflowViewController *)createViewController {
    return [[BrowseOverflowViewController alloc] init];
}

- (void)testItHasATableViewProperty
{
    viewController = [self createViewController];
    
    // Uses Obj-C runtime programming to verify that this class has a tableView property.
    objc_property_t tableViewProperty = class_getProperty([viewController class], "tableView");
    
    XCTAssertTrue(tableViewProperty != NULL);
}

- (void)testItHasATableViewDataSourceProperty
{
    viewController = [self createViewController];
    
    objc_property_t tableViewDataSource = class_getProperty([viewController class], "tableViewDataSource");
    
    XCTAssertTrue(tableViewDataSource != NULL);
}

- (void)testViewControllerWhenLoadedConnectsTableViewToDataSource
{
    viewController = [self createViewController];
    TopicTableDataSource *topicTableDataSource = [[TopicTableDataSource alloc] init];
    viewController.tableViewDataSource = topicTableDataSource;
    viewController.tableView = [[UITableView alloc] init];
    
    [viewController viewDidLoad];
    
    XCTAssertEqualObjects(viewController.tableView.dataSource, topicTableDataSource);
}

- (void)testViewControllerWhenLoadedConnectsTableViewToDelegate
{
    viewController = [self createViewController];
    TopicTableDataSource *topicTableDataSource = [[TopicTableDataSource alloc] init];
    viewController.tableViewDataSource = topicTableDataSource;
    viewController.tableView = [[UITableView alloc] init];
    
    [viewController viewDidLoad];
    
    XCTAssertEqualObjects(viewController.tableView.delegate, topicTableDataSource);
}

// *** Thing to test: VC only responds to a particular notification when it's on screen ***
//   Default path: call nothing, broadcast notification, see if VC did anything
//   Happy path test: call viewDidAppear to simulate being on screen, broadcast notification, see if VC did anything
//   Sad path test: call viewWillDisappear to simulate being pushed off screen, broadcast notification, see if VC did anything
//
// *** How to test that the VC "did anything"? ***
// Book suggests using a category in the test project to override the method configured to fire when the VC receives the notification.
// The category method uses some runtime trickery (objc_setAssociatedObject), which uses something called "Associative References",
// which is basically an optional dictionary that every object can use as storage to hold arbitrary key/value pairs. That basically
// allows us to add instance variables to a category, which is not possible directly. So basically, when the overridden method gets
// called, it adds some key/value pair, and the test assertion checks for that key/value pair as a way to tell if the notification
// was being listened to or not.
//
// I hate this approach. It's still just a dependency on a private method. All it does is check that your private method gets called,
// and it uses some hocus pocus to add something to a class that didn't belong normally. This is very clearly my bias against using
// dynamic language features. On second thought, if one were to ever do something like this, it makes most sense to do for a test,
// where you might be working with some objects that are too difficult to set up to test in the test environment. But isn't a class
// that's hard to test a code smell?
//
// To make it a truly effective test though, you need to define exactly what is the definition of BrowseOverflowViewController
// "doing something" when the notification occurs. Is it pushing on a new VC? Is that *always* what it should do? What if a subclass
// decides it wants to present a modal VC instead? Those are questions we don't know how to answer yet, so there's a good argument
// that you should proceed with a haphazard approach and play around until you know a little more about the requirements, at which
// point you can circle back and refactor.

- (void)testViewControllerBeforeViewAppearsDoesNotRespondToNotification
{
    viewController = [self createViewController];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TopicTableDidSelectTopicNotification
                                                        object:nil];
    
    id receivedNotification = objc_getAssociatedObject(viewController, notificationKey);
    XCTAssertNil(receivedNotification);
}

- (void)testViewControllerAfterViewAppearsRespondsToNotification
{
    viewController = [self createViewController];
    [viewController viewDidAppear:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TopicTableDidSelectTopicNotification
                                                        object:nil];
    
    id receivedNotification = objc_getAssociatedObject(viewController, notificationKey);
    XCTAssertNotNil(receivedNotification);
}

- (void)testViewControllerAfterViewDisappearsDoesNotRespondToNotification
{
    viewController = [self createViewController];
    [viewController viewDidAppear:NO];
    [viewController viewWillDisappear:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TopicTableDidSelectTopicNotification
                                                        object:nil];
    
    id receivedNotification = objc_getAssociatedObject(viewController, notificationKey);
    XCTAssertNil(receivedNotification);
}

// Book sets up a few tests for the expectation that the super implementations of view controller lifecycle methods are
// invoked (e.g. viewDidAppear and viewWillDisappear). This seems like a dumb thing to test, but I think it's just the
// book's way of introducing method swizzling.

- (void)testViewDidAppearWhenCalledCallsSuperImplementation
{
    viewController = [self createViewController];
    realViewDidAppear = @selector(viewDidAppear:);
    testViewDidAppear = @selector(browseOverflowViewControllerTests_viewDidAppear:);
    [self swapInstanceMethodsForClass:[UIViewController class]
                          forSelector:realViewDidAppear
                        otherSelector:testViewDidAppear];
    
    [viewController viewDidAppear:NO];
    
    id animatedParameter = objc_getAssociatedObject(viewController, viewDidAppearKey);
    XCTAssertNotNil(animatedParameter);
    [self swapInstanceMethodsForClass:[UIViewController class]
                          forSelector:realViewWillDisappear
                        otherSelector:testViewWillDisappear];

}

- (void)testViewWillDisappearWhenCalledCallsSuperImplementation
{
    viewController = [self createViewController];
    
    [viewController viewWillDisappear:NO];
    
    id animatedParameter = objc_getAssociatedObject(viewController, viewWillDisappearKey);
    XCTAssertNotNil(animatedParameter);
}

@end
