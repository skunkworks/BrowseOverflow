//
//  Person.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "Person.h"

@implementation Person

- (id)initWithName:(NSString *)name
         avatarURL:(NSURL *)url
{
    if (self = [super init]) {
        _name = [name copy];
        _avatarURL = url;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    Person *otherPerson = (Person *)object;
    if (!otherPerson) return NO;
    if (![otherPerson isKindOfClass:[Person class]]) return NO;
    
    if (![self.name isEqualToString:otherPerson.name]) return NO;
    if (![[self.avatarURL absoluteString] isEqualToString:[otherPerson.avatarURL absoluteString]]) return NO;
    return YES;
}

@end
