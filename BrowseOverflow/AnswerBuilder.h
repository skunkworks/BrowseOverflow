//
//  AnswerBuilder.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Answer.h"
#import "PersonBuilder.h"

@interface AnswerBuilder : NSObject

extern NSString *const AnswerBuilderError;

enum {
    AnswerBuilderInvalidJSONError,
    AnswerBuilderMissingDataError
};

// Designated initializer
- (id)initWithPersonBuilder:(PersonBuilder *)personBuilder;

@property (nonatomic, strong) PersonBuilder *personBuilder;

- (NSArray *)answersFromJSON:(NSString *)objectNotation
                       error:(NSError **)error;

@end
