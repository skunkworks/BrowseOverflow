//
//  BOAppDelegateTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAppDelegate.h"

@interface BOAppDelegateTests : XCTestCase
{
    BOAppDelegate *appDelegate;
}
@end

@implementation BOAppDelegateTests

#pragma mark - Utility helper methods
- (BOAppDelegate *)createAppDelegate {
    return [[BOAppDelegate alloc] init];
}

#pragma mark - Tests

- (void)testAppDelegateWhenAppFinishesLaunchingConfiguresWindowAsKeyWindow
{
    appDelegate = [self createAppDelegate];
    
    [appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    UIWindow *window = appDelegate.window;
    XCTAssertTrue(window.isKeyWindow);
}

- (void)testAppDelegateWhenAppFinishesLaunchingSetsRootViewControllerToNavigationController
{
    appDelegate = [self createAppDelegate];
    
    [appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    XCTAssertTrue([navController isKindOfClass:[UINavigationController class]]);
}

// App finishes launching successfully
- (void)testDidFinishLaunchingWhenCalledReturnsTrue
{
    appDelegate = [self createAppDelegate];
    
    BOOL finished = [appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    XCTAssertTrue(finished);
}

- (void)testAppDelegateWhenAppFinishesLaunchingSetsNavigationControllerRootToBrowseOverflowViewController
{
    appDelegate = [self createAppDelegate];
    
    [appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    BrowseOverflowViewController *bovc = (BrowseOverflowViewController *)appDelegate.navigationController.topViewController;
    XCTAssertTrue([bovc isKindOfClass:[BrowseOverflowViewController class]]);
}

- (void)testAppDelegateWhenAppFinishesLaunchingSetsUpTopicDataSource
{
    appDelegate = [self createAppDelegate];
    
    [appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    BrowseOverflowViewController *viewController = (BrowseOverflowViewController *)appDelegate.navigationController.topViewController;
    XCTAssertTrue([viewController.tableViewDataSource isKindOfClass:[TopicTableDataSource class]]);
}

- (void)testInitialBrowseOverflowViewControllerWhenAppFinishesLaunchingHasAConfigurationObject
{
    appDelegate = [self createAppDelegate];
    
    [appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    BrowseOverflowViewController *viewController = (BrowseOverflowViewController *)appDelegate.navigationController.topViewController;
    XCTAssertTrue([viewController.configuration isKindOfClass:[BrowseOverflowConfiguration class]]);
}

- (void)testInitialBrowseOverflowViewControllerWhenAppFinishesLaunchingHasATopicTableDataSource
{
    appDelegate = [self createAppDelegate];
    
    [appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    BrowseOverflowViewController *viewController = (BrowseOverflowViewController *)appDelegate.navigationController.topViewController;
    XCTAssertTrue([viewController.tableViewDataSource isKindOfClass:[TopicTableDataSource class]]);
}

- (void)testInitialBrowseOverflowViewControllerWhenAppFinishesLaunchingHasATitle
{
    appDelegate = [self createAppDelegate];
    
    [appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    BrowseOverflowViewController *viewController = (BrowseOverflowViewController *)appDelegate.navigationController.topViewController;
    XCTAssertEqualObjects(viewController.title, @"Browse StackOverflow Topics");
}

@end
