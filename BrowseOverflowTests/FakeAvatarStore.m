//
//  FakeAvatarStore.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "FakeAvatarStore.h"

@implementation FakeAvatarStore

- (void)fetchDataForLocation:(NSString *)location onCompletion:(void (^)(NSData *))completionHandler
{
    fetchLocation = location;
    if (completionHandler) completionHandler(fetchedData);
}

- (BOOL)wasAskedToFetchDataForLocation:(NSString *)location
{
    return [fetchLocation isEqualToString:location];
}

- (void)setAvatarDataReturnedByFetch:(NSData *)data
{
    fetchedData = data;
}

@end
