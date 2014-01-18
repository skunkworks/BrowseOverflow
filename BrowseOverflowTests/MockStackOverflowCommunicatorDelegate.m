//
//  MockStackOverflowCommunicatorDelegate.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "MockStackOverflowCommunicatorDelegate.h"

@implementation MockStackOverflowCommunicatorDelegate

- (void)fetchBodyForQuestionWithIDFailedWithError:(NSError *)error
{
    // Not needed, since StackOverflowCommunicatorTests only uses searchForQuestions to test connectivity
}

- (void)fetchBodyForQuestionWithID:(NSInteger)questionID didReturnJSON:(NSString *)objectNotation
{
    // Not needed, since StackOverflowCommunicatorTests only uses searchForQuestions to test connectivity    
}

- (void)searchForQuestionsDidReturnJSON:(NSString *)objectNotation
{
    self.receivedJSON = objectNotation;
}

- (void)searchForQuestionsFailedWithError:(NSError *)error
{
    self.topicFailureErrorCode = [error code];
}

@end
