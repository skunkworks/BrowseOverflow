//
//  FakeBrowseOverflowConfiguration.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "BrowseOverflowConfiguration.h"

@interface FakeBrowseOverflowConfiguration : BrowseOverflowConfiguration

@property (nonatomic, strong) StackOverflowManager *managerToReturn;
@property (nonatomic, strong) AvatarStore *avatarStoreToReturn;

@end
