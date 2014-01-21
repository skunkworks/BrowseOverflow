//
//  BrowseOverflowConfigurationTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BrowseOverflowConfiguration.h"

@interface BrowseOverflowConfigurationTests : XCTestCase
{
    BrowseOverflowConfiguration *configuration;
}
@end

@implementation BrowseOverflowConfigurationTests

- (BrowseOverflowConfiguration *)createConfiguration {
    return [[BrowseOverflowConfiguration alloc] init];
}

#pragma mark - Tests

- (void)testCreateManagerWhenCalledReturnsCorrectlyConfiguredManager
{
    configuration = [self createConfiguration];
    
    StackOverflowManager *manager = [configuration createManager];
    
    XCTAssertNotNil(manager.questionBuilder);
    XCTAssertNotNil(manager.answerBuilder);
    XCTAssertNotNil(manager.communicator);
    XCTAssertEqualObjects(manager.communicator.delegate, manager);
}

- (void)testAvatarStoreWhenCalledReturnsAvatarStore
{
    configuration = [self createConfiguration];
    
    AvatarStore *avatarStore = [configuration avatarStore];
    
    XCTAssertNotNil(avatarStore);
}

- (void)testAvatarStoreWhenCalledMultipleTimesReturnsSameInstance
{
    configuration = [self createConfiguration];
    
    AvatarStore *store1 = [configuration avatarStore];
    AvatarStore *store2 = [configuration avatarStore];
    
    XCTAssertEqualObjects(store1, store2);
}

@end
