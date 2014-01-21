//
//  MockStackOverflowCommunicatorDelegate.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "FakeStackOverflowManager.h"

@implementation FakeStackOverflowManager

#pragma mark - StackOverflowCommunicatorDelegate

- (void)fetchQuestionsDidReturnJSON:(NSString *)objectNotation
{
    self.receivedJSON = objectNotation;
}

- (void)fetchQuestionsFailedWithError:(NSError *)error
{
    self.topicFailureErrorCode = [error code];
}

- (void)fetchBodyForQuestionWithIDFailedWithError:(NSError *)error
{
    // Not needed, since StackOverflowCommunicatorTests only uses to test connectivity
}

- (void)fetchBodyForQuestionWithID:(NSInteger)questionID didReturnJSON:(NSString *)objectNotation
{
    // Not needed, since StackOverflowCommunicatorTests only uses to test connectivity
}

- (void)fetchAnswersForQuestionWithID:(NSInteger)questionID didReturnJSON:(NSString *)objectNotation
{
    // Not needed, since StackOverflowCommunicatorTests only uses to test connectivity
}

- (void)fetchAnswersForQuestionWithIDFailedWithError:(NSError *)error
{
    // Not needed, since StackOverflowCommunicatorTests only uses to test connectivity
}

#pragma mark - StackOverflowManager

- (void)fetchQuestionsForTopic:(Topic *)topic {
    self.wasAskedToFetchQuestions = YES;
    self.topicForQuestionsToFetch = topic;
}

- (void)fetchBodyForQuestion:(Question *)question
{
    self.wasAskedToFetchQuestionBody = YES;
    self.questionForQuestionBodyToFetch = question;
}

- (void)fetchAnswersForQuestion:(Question *)question
{
    self.wasAskedToFetchAnswers = YES;
    self.questionForAnswersToFetch = question;
}

@end
