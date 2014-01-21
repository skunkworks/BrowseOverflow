//
//  BrowseOverflowConfiguration.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowManager.h"
#import "AvatarStore.h"

@interface BrowseOverflowConfiguration : NSObject

- (StackOverflowManager *)createManager;
- (AvatarStore *)avatarStore;

@end
