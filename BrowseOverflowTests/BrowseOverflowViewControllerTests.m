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
#import "QuestionListTableDataSource.h"
#import "FakeStackOverflowManager.h"
#import "FakeBrowseOverflowConfiguration.h"
#import "FakeUITableView.h"
#import "FakeAvatarStore.h"

@interface BrowseOverflowViewControllerTests : XCTestCase
{
    BrowseOverflowViewController *viewController;
}
@end


// Some hacky shit to make this class more testable
static const char *notificationKey = "BrowseOverflowViewControllerTestsAssociatedNotificationKey";

@implementation BrowseOverflowViewController (TestNotificationDelivery)

- (void)browseOverflowViewControllerTests_userDidSelectTopicNotification: (NSNotification *)note {
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

#pragma mark - Helper utility methods

- (BrowseOverflowViewController *)createViewController {
    return [[BrowseOverflowViewController alloc] init];
}

- (void)swapInstanceMethodsForClass:(Class)class
                        forSelector:(SEL)selector
                      otherSelector:(SEL)otherSelector
{
    Method method = class_getInstanceMethod(class, selector);
    Method otherMethod = class_getInstanceMethod(class, otherSelector);
    method_exchangeImplementations(method, otherMethod);
}

#pragma mark - Property tests

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

#pragma mark - Tests after VC has been loaded

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

- (void)testViewDidLoadWhenDataSourceIsQuestionListSetsItsAvatarStoreFromConfiguration
{
    viewController = [self createViewController];
    QuestionListTableDataSource *dataSource = [[QuestionListTableDataSource alloc] init];
    viewController.tableViewDataSource = dataSource;
    FakeBrowseOverflowConfiguration *stubConfiguration = [[FakeBrowseOverflowConfiguration alloc] init];
    FakeAvatarStore *fakeAvatarStore = [[FakeAvatarStore alloc] init];
    stubConfiguration.avatarStoreToReturn = fakeAvatarStore;
    viewController.configuration = stubConfiguration;
    
    [viewController viewDidLoad];
    
    XCTAssertEqualObjects(dataSource.avatarStore, fakeAvatarStore);
}

#pragma mark - Topic selected notification tests

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
    SEL realUserDidSelectTopicNotification = NSSelectorFromString(@"userDidSelectTopicNotification:");
    SEL testUserDidSelectTopicNotification = @selector(browseOverflowViewControllerTests_userDidSelectTopicNotification:);
    [self swapInstanceMethodsForClass:[BrowseOverflowViewController class]
                          forSelector:realUserDidSelectTopicNotification
                        otherSelector:testUserDidSelectTopicNotification];
    
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:TopicTableDidSelectTopicNotification
                                                            object:nil];
        
        XCTAssertNil(objc_getAssociatedObject(viewController, notificationKey));
    }
    @finally {
        [self swapInstanceMethodsForClass:[BrowseOverflowViewController class]
                              forSelector:realUserDidSelectTopicNotification
                            otherSelector:testUserDidSelectTopicNotification];
    }
}

- (void)testViewControllerAfterViewAppearsRespondsToNotification
{
    viewController = [self createViewController];
    SEL realUserDidSelectTopicNotification = NSSelectorFromString(@"userDidSelectTopicNotification:");
    SEL testUserDidSelectTopicNotification = @selector(browseOverflowViewControllerTests_userDidSelectTopicNotification:);
    [self swapInstanceMethodsForClass:[BrowseOverflowViewController class]
                          forSelector:realUserDidSelectTopicNotification
                        otherSelector:testUserDidSelectTopicNotification];
    
    @try {
        [viewController viewDidAppear:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:TopicTableDidSelectTopicNotification
                                                            object:nil];
        
        XCTAssertNotNil(objc_getAssociatedObject(viewController, notificationKey));
    }
    @finally {
        [self swapInstanceMethodsForClass:[BrowseOverflowViewController class]
                              forSelector:realUserDidSelectTopicNotification
                            otherSelector:testUserDidSelectTopicNotification];
    }

}

- (void)testViewControllerAfterViewDisappearsDoesNotRespondToNotification
{
    viewController = [self createViewController];
    SEL realUserDidSelectTopicNotification = NSSelectorFromString(@"userDidSelectTopicNotification:");
    SEL testUserDidSelectTopicNotification = @selector(browseOverflowViewControllerTests_userDidSelectTopicNotification:);
    [self swapInstanceMethodsForClass:[BrowseOverflowViewController class]
                          forSelector:realUserDidSelectTopicNotification
                        otherSelector:testUserDidSelectTopicNotification];

    @try {
        [viewController viewDidAppear:NO];
        [viewController viewWillDisappear:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:TopicTableDidSelectTopicNotification
                                                            object:nil];
        
        XCTAssertNil(objc_getAssociatedObject(viewController, notificationKey));
    }
    @finally {
        [self swapInstanceMethodsForClass:[BrowseOverflowViewController class]
                              forSelector:realUserDidSelectTopicNotification
                            otherSelector:testUserDidSelectTopicNotification];
    }
}

#pragma mark - View controller lifecycle method tests

// Book sets up a few tests for the expectation that the super implementations of view controller
// lifecycle methods are invoked (e.g. viewDidAppear and viewWillDisappear). This seems like a dumb
// thing to test, but I think it's just the book's way of introducing method swizzling.

- (void)testViewDidAppearWhenCalledCallsSuperImplementation
{
    viewController = [self createViewController];
    SEL realViewDidAppear = @selector(viewDidAppear:);
    SEL testViewDidAppear = @selector(browseOverflowViewControllerTests_viewDidAppear:);
    [self swapInstanceMethodsForClass:[UIViewController class]
                          forSelector:realViewDidAppear
                        otherSelector:testViewDidAppear];
    
    // We could do all swizzling in setUp and tearDown, but we don't want to swizzle for every
    // test, and any thrown exception would skip the swizzling back.
    @try {
        [viewController viewDidAppear:NO];
        
        XCTAssertNotNil(objc_getAssociatedObject(viewController, viewDidAppearKey));
    }
    @finally {
        [self swapInstanceMethodsForClass:[UIViewController class]
                              forSelector:realViewDidAppear
                            otherSelector:testViewDidAppear];
    }
}

- (void)testViewWillDisappearWhenCalledCallsSuperImplementation
{
    viewController = [self createViewController];
    SEL realViewWillDisappear = @selector(viewWillDisappear:);
    SEL testViewWillDisappear = @selector(browseOverflowViewControllerTests_viewWillDisappear:);
    [self swapInstanceMethodsForClass:[UIViewController class]
                          forSelector:realViewWillDisappear
                        otherSelector:testViewWillDisappear];
    
    @try {
        [viewController viewWillDisappear:NO];
        
        XCTAssertNotNil(objc_getAssociatedObject(viewController, viewWillDisappearKey));
    }
    @finally {
        [self swapInstanceMethodsForClass:[UIViewController class]
                              forSelector:realViewWillDisappear
                            otherSelector:testViewWillDisappear];
    }
}

- (void)testViewWillAppearWhenDataSourceIsQuestionListFetchesQuestionsWithCommunicator
{
    viewController = [self createViewController];
    FakeStackOverflowManager *stubManager = [[FakeStackOverflowManager alloc] init];
    FakeBrowseOverflowConfiguration *stubConfiguration = [[FakeBrowseOverflowConfiguration alloc] init];
    stubConfiguration.managerToReturn = stubManager;
    viewController.configuration = stubConfiguration;
    viewController.tableViewDataSource = [[QuestionListTableDataSource alloc] init];
    
    [viewController viewWillAppear:NO];
    
    XCTAssertTrue([stubManager wasAskedToFetchQuestions]);
}

- (void)testViewWillAppearWhenCalledSetsViewControllerAsDelegateOfItsManager
{
    viewController = [self createViewController];
    FakeStackOverflowManager *mockManager = [[FakeStackOverflowManager alloc] init];
    FakeBrowseOverflowConfiguration *stubConfiguration = [[FakeBrowseOverflowConfiguration alloc] init];
    stubConfiguration.managerToReturn = mockManager;
    viewController.configuration = stubConfiguration;
    
    [viewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(mockManager.delegate, viewController);
}

#pragma mark - Pushing new view controllers

// The architecture of the code is such that BrowseOverflowViewController is designed to be a generic table view
// class that has a data source and delegate object (XTableDataSource) that drives its behavior. To respond to various
// events, the XTableDataSource obj notifies its parent via NSNotificationCenter.
//
// It seems a bit confusing that for a generic class like BrowseOverflowViewController that we test its specific
// behavior for Topic, Question List, etc. This is a personal weakness of mine -- the desire to make things excessively
// reusable. The god's honest truth is that the scope of the usage of BrowseOverflowViewController is static and
// known: there are topics, topics have questions, questions have answers. Writing code that makes that assumption
// is not a bad practice in as much as we don't anticipate any changes to those requirements, and making that assumption
// simplifies the code.

- (void)testViewControllerWhenUserSelectsTopicPushesNewViewControllerToNavigationController
{
    viewController = [self createViewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [viewController userDidSelectTopicNotification:nil];
    
    UIViewController *topViewController = navController.topViewController;
    XCTAssertNotEqualObjects(topViewController, viewController);
}

- (void)testViewControllerWhenUserSelectsTopicPushesNewViewControllerWithQuestionListDataSourceConfiguredForTopic
{
    viewController = [self createViewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    Topic *iPhoneTopic = [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];

    NSNotification *topicNotification = [NSNotification notificationWithName:TopicTableDidSelectTopicNotification
                                                                      object:iPhoneTopic];
    [viewController userDidSelectTopicNotification:topicNotification];
    
    BrowseOverflowViewController *topViewController = (BrowseOverflowViewController *)navController.topViewController;
    id tableViewDataSource = topViewController.tableViewDataSource;
    XCTAssertTrue([tableViewDataSource isKindOfClass:[QuestionListTableDataSource class]]);
    XCTAssertEqualObjects([tableViewDataSource topic], iPhoneTopic);
}

- (void)testViewControllerWhenUserSelectsTopicPushesNewViewControllerWithConfiguration
{
    viewController = [self createViewController];
    viewController.configuration = [[BrowseOverflowConfiguration alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    Topic *iPhoneTopic = [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];

    NSNotification *topicNotification = [NSNotification notificationWithName:TopicTableDidSelectTopicNotification
                                                                      object:iPhoneTopic];
    [viewController userDidSelectTopicNotification:topicNotification];
    
    BrowseOverflowViewController *topViewController = (BrowseOverflowViewController *)navController.topViewController;
    XCTAssertEqualObjects(topViewController.configuration, viewController.configuration);
}

#pragma mark - Response to StackOverflowManagerDelegate events

// A bit confusing: the QuestionListTableDataSource has a Topic property, but it also has an addQuestion method.
// When the VC receives questions from StackOverflowManager, should it add questions to the Topic or should it
// add them directly to the data source?

- (void)testDidReceiveQuestionsWhenCalledAddsQuestionToTopic
{
    viewController = [self createViewController];
    QuestionListTableDataSource *dataSource = [[QuestionListTableDataSource alloc] init];
    viewController.tableViewDataSource = dataSource;
    Topic *topic = [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];
    dataSource.topic = topic;
    Question *question = [[Question alloc] init];
    
    [viewController didReceiveQuestions:@[question]];
    
    XCTAssertEqual((NSInteger)[[topic recentQuestions] count], 1);
}

- (void)testDidReceiveQuestionsWhenCalledReloadsTableView
{
    viewController = [self createViewController];
    FakeUITableView *mockTableView = [[FakeUITableView alloc] init];
    viewController.tableView = mockTableView;
    
    [viewController didReceiveQuestions:nil];
    
    XCTAssertTrue(mockTableView.didReceiveReloadData);
}


@end
