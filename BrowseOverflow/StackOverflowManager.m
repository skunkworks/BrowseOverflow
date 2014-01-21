//
//  StackOverflowManager.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "StackOverflowManager.h"

@interface StackOverflowManager ()
@property (nonatomic, strong) Question *questionForFetchBody;
@property (nonatomic, strong) Question *questionForFetchAnswers;
@end

@implementation StackOverflowManager

NSString *const StackOverflowManagerError = @"StackOverflowManagerError";

- (void)setDelegate:(id<StackOverflowManagerDelegate>)delegate
{
    if (delegate &&
        ![delegate conformsToProtocol:@protocol(StackOverflowManagerDelegate)]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Delegate does not conform to required protocol"];
    }
    _delegate = delegate;
}

- (void)fetchQuestionsForTopic:(Topic *)topic
{
    [self.communicator fetchQuestionsWithTag:topic.tag];
}

- (void)fetchBodyForQuestion:(Question *)question
{
    // Stash question we're retrieving body for, so that when we're finished we can send it
    // back to the delegate.
    self.questionForFetchBody = question;
    [self.communicator fetchBodyForQuestionWithID:question.questionID];
}

- (void)fetchAnswersForQuestion:(Question *)question
{
    self.questionForFetchAnswers = question;
    [self.communicator fetchAnswersToQuestionWithID:question.questionID];
}

#pragma mark - StackOverflowCommunicatorDelegate methods

- (void)fetchQuestionsFailedWithError:(NSError *)error
{
    [self reportFetchQuestionsErrorToDelegate:error];
}

- (void)fetchQuestionsDidReturnJSON:(NSString *)objectNotation
{
    NSError *error;
    NSArray *questions = [self.questionBuilder questionsFromJSON:objectNotation error:&error];
    if (!questions) {
        [self reportFetchQuestionsErrorToDelegate:error];
    } else {
        [self sendQuestionsToDelegate:questions];
    }
}

- (void)fetchBodyForQuestionWithIDFailedWithError:(NSError *)error
{
    [self reportFetchQuestionBodyErrorToDelegate:error];
}

- (void)fetchBodyForQuestionWithID:(NSInteger)questionID
                     didReturnJSON:(NSString *)objectNotation
{
    NSError *error;
    
    // We stored the question whose JSON we just received in the questionForFetchBody property
    BOOL successful = [self.questionBuilder fillQuestion:self.questionForFetchBody
                                    withQuestionBodyJSON:objectNotation
                                                   error:&error];
    if (!successful) {
        [self reportFetchQuestionBodyErrorToDelegate:error];
    } else {
        [self sendQuestionToDelegate:self.questionForFetchBody];
    }
    
    self.questionForFetchBody = nil;
}

- (void)fetchAnswersForQuestionWithIDFailedWithError:(NSError *)error
{
    [self reportFetchAnswersErrorToDelegate:error];
}

- (void)fetchAnswersForQuestionWithID:(NSInteger)questionID
                        didReturnJSON:(NSString *)objectNotation
{
    NSError *error;
    NSArray *answers = [self.answerBuilder answersFromJSON:objectNotation
                                                     error:&error];
    if (!answers) {
        [self reportFetchAnswersErrorToDelegate:error];
    } else {
        [self sendAnswersToDelegate:answers];
    }
}

#pragma mark - Private methods

// Takes in NSError from either the communicator or the question builder, and wraps it so that it's
// at the correct abstraction level.
- (void)reportFetchQuestionsErrorToDelegate:(NSError *)error
{
    if (!error) return;
    
    NSDictionary *userInfo = @{ NSUnderlyingErrorKey : error };
    NSError *reportError = [NSError errorWithDomain:StackOverflowManagerError
                                               code:StackOverflowManagerFetchQuestionsError
                                           userInfo:userInfo];
    [self.delegate fetchQuestionsForTopicFailedWithError:reportError];
}

- (void)reportFetchQuestionBodyErrorToDelegate:(NSError *)error
{
    if (!error) return;
    
    NSDictionary *userInfo = @{ NSUnderlyingErrorKey : error };
    NSError *reportError = [NSError errorWithDomain:StackOverflowManagerError
                                               code:StackOverflowManagerFetchQuestionBodyError
                                           userInfo:userInfo];
    [self.delegate fetchBodyForQuestionFailedWithError:reportError];
}

- (void)reportFetchAnswersErrorToDelegate:(NSError *)error
{
    if (!error) return;
    
    NSDictionary *userInfo = @{ NSUnderlyingErrorKey : error };
    NSError *reportError = [NSError errorWithDomain:StackOverflowManagerError
                                               code:StackOverflowManagerFetchAnswersError
                                           userInfo:userInfo];
    [self.delegate fetchAnswersForQuestionFailedWithError:reportError];
}

- (void)sendQuestionsToDelegate:(NSArray *)questions {
    [self.delegate didReceiveQuestions:questions];
}

- (void)sendQuestionToDelegate:(Question *)question {
    [self.delegate didReceiveQuestionBodyForQuestion:question];
}

- (void)sendAnswersToDelegate:(NSArray *)answers {
    [self.delegate didReceiveAnswers:answers];
}

@end
