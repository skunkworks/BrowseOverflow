//
//  FakeURLResponse.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "FakeURLResponse.h"

@implementation FakeURLResponse

- (id)initWithStatusCode:(NSInteger)code
{
    if (self = [super init]) {
        statusCode = code;
    }
    return self;
}

- (NSInteger)statusCode {
    return statusCode;
}

@end
