//
//  FakeAvatarStore.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "AvatarStore.h"

@interface FakeAvatarStore : AvatarStore
{
    NSString *fetchLocation;
    NSData *fetchedData;
}

- (BOOL)wasAskedToFetchDataForLocation:(NSString *)location;
- (void)setAvatarDataReturnedByFetch:(NSData *)data;
@end
