//
//  MockQuestionBuilder.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/13/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "MockQuestionBuilder.h"

@implementation MockQuestionBuilder


- (NSArray *)questionsFromJSON:(NSString *)objectNotation
                         error:(NSError **)error
{
    self.receivedJSON = objectNotation;
    *error = self.errorToSet;
    // TODO: parse JSON, return objects, set error?
    return self.questionsToReturn;
}

- (BOOL)fillQuestion:(Question *)question
withQuestionBodyJSON:(NSString *)objectNotation
               error:(NSError **)error
{
    self.receivedJSON = objectNotation;
    self.receivedQuestion = question;
    *error = self.errorToSet;
    return self.successToReturn;
}

@end
