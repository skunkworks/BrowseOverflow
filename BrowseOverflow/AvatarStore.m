//
//  AvatarStore.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "AvatarStore.h"

@interface AvatarStore ()
@property (nonatomic, strong) NSMutableDictionary *avatarDictionary;
@end

@implementation AvatarStore

- (NSMutableDictionary *)avatarDictionary {
    if (!_avatarDictionary) _avatarDictionary = [NSMutableDictionary dictionary];
    return _avatarDictionary;
}

- (void)setData:(NSData *)data forLocation:(NSString *)location
{
    [self.avatarDictionary setObject:data forKey:location];
}

- (NSData *)dataForLocation:(NSString *)location
{
    return [self.avatarDictionary objectForKey:location];
}

@end
