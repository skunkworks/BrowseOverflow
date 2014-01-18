//
//  Answer.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "Answer.h"

@implementation Answer

- (NSComparisonResult)compare:(Answer *)otherAnswer
{
    if (self.accepted && !otherAnswer.accepted) {
        return NSOrderedAscending;
    } else if (!self.accepted && otherAnswer.accepted) {
        return NSOrderedDescending;
    }
    
    // Both answers are either accepted or unaccepted, so ordering is based on scores
    if (self.score > otherAnswer.score) {
        return NSOrderedAscending;
    } else if (self.score < otherAnswer.score) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

@end
