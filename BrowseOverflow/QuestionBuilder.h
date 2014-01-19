//
//  QuestionBuilder.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/13/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"
#import "PersonBuilder.h"

@interface QuestionBuilder : NSObject

extern NSString *const QuestionBuilderError;

enum {
    QuestionBuilderInvalidJSONError,
    QuestionBuilderMissingDataError
};

// Designated initializer
- (id)initWithPersonBuilder:(PersonBuilder *)personBuilder;

@property (nonatomic, strong) PersonBuilder *personBuilder;

// Returns NSArray of Question
// Pass in pointer to NSError to receive errors when question parsing fails
- (NSArray *)questionsFromJSON:(NSString *)objectNotation
                         error:(NSError **)error;

// Returns YES if successful, NO if not. Sets NSError if unsuccessful.
// Populates question's body with data from JSON
- (BOOL)fillQuestion:(Question *)question
withQuestionBodyJSON:(NSString *)objectNotation
               error:(NSError **)error;

@end
