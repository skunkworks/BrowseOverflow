//
//  FakeAnswerBuilder.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "AnswerBuilder.h"

@interface FakeAnswerBuilder : AnswerBuilder

@property (nonatomic, strong) NSError *errorToSet;
@property (nonatomic, strong) NSArray *answersToReturn;
@property (nonatomic, readonly) NSString *receivedJSON;

@end
