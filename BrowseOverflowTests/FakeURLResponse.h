//
//  FakeURLResponse.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeURLResponse : NSObject
{
    NSInteger statusCode;
}

- (id)initWithStatusCode:(NSInteger)code;
- (NSInteger)statusCode;

@end
