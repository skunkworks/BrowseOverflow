//
//  FakeAnswerBuilder.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "FakeAnswerBuilder.h"

@interface FakeAnswerBuilder ()
@property (nonatomic, readwrite) NSString *receivedJSON;
@end

@implementation FakeAnswerBuilder

- (NSArray *)answersFromJSON:(NSString *)objectNotation
                       error:(NSError **)error
{
    self.receivedJSON = objectNotation;
    *error = self.errorToSet;
    return self.answersToReturn;
}

@end
