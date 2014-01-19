//
//  PersonBuilder.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "PersonBuilder.h"

@implementation PersonBuilder

#pragma mark - JSON keys
NSString *const PersonNameKey = @"display_name";
NSString *const PersonAvatarKey = @"profile_image";

#pragma mark - Public methods

- (Person *)personFromJSONObject:(id)jsonObject
{
    NSString *name = [jsonObject objectForKey:PersonNameKey];
    NSString *avatar = [jsonObject objectForKey:PersonAvatarKey];
    NSURL *avatarURL = [NSURL URLWithString:avatar]; // Is nil if string is nil
    if (name || avatarURL) {
        return [[Person alloc] initWithName:name avatarURL:avatarURL];
    }
    return nil;
}

@end
