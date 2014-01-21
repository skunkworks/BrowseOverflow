//
//  FakeBrowseOverflowConfiguration.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "FakeBrowseOverflowConfiguration.h"

@implementation FakeBrowseOverflowConfiguration

- (StackOverflowManager *)createManager {
    return self.managerToReturn;
}

- (AvatarStore *)avatarStore {
    return self.avatarStoreToReturn;
}

@end
