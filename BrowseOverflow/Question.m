//
//  Question.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "Question.h"

@implementation Question

- (id)init
{
    if (self = [super init]) {
        answers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (NSArray *)answers
{
    return [[answers allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)addAnswer:(Answer *)answer
{
    [answers addObject:answer];
}

@end