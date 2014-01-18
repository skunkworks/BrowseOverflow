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
    [self.communicator searchForQuestionsWithTag:topic.tag];
}

- (void)fetchBodyForQuestion:(Question *)question
{
    // Stash question we're retrieving body for, so that when we're finished we can send it
    // back to the delegate.
    self.questionForFetchBody = question;
    [self.communicator fetchBodyForQuestionWithID:question.questionID];
}

#pragma mark - StackOverflowCommunicatorDelegate methods

- (void)searchForQuestionsFailedWithError:(NSError *)error
{
    [self reportQuestionSearchErrorToDelegate:error];
}

- (void)searchForQuestionsDidReturnJSON:(NSString *)objectNotation
{
    NSError *error;
    NSArray *questions = [self.questionBuilder questionsFromJSON:objectNotation error:&error];
    if (!questions) {
        [self reportQuestionSearchErrorToDelegate:error];
    } else {
        [self sendQuestionsToDelegate:questions];
    }
    
    // TODO: do something with questions!
}

- (void)fetchBodyForQuestionWithIDFailedWithError:(NSError *)error
{
    [self reportQuestionBodySearchErrorToDelegate:error];
}

- (void)fetchBodyForQuestionWithID:(NSInteger)questionID
                     didReturnJSON:(NSString *)objectNotation
{
    NSError *error;
    
    // TODO: where do we get the question from? Probably from caching in an array from searchForQuestions?
    BOOL successful = [self.questionBuilder fillQuestion:self.questionForFetchBody
                                    withQuestionBodyJSON:objectNotation
                                                   error:&error];
    if (!successful) {
        [self reportQuestionBodySearchErrorToDelegate:error];
    } else {
        [self sendQuestionToDelegate:self.questionForFetchBody];
    }
    
    self.questionForFetchBody = nil;
}

#pragma mark - Private methods

// Takes in NSError from either the communicator or the question builder, and wraps it so that it's
// at the correct abstraction level.
- (void)reportQuestionSearchErrorToDelegate:(NSError *)error
{
    if (!error) return;
    
    NSDictionary *userInfo = @{ NSUnderlyingErrorKey : error };
    NSError *reportError = [NSError errorWithDomain:StackOverflowManagerError
                                               code:StackOverflowManagerQuestionSearchError
                                           userInfo:userInfo];
    [self.delegate fetchQuestionsForTopicFailedWithError:reportError];
}

- (void)reportQuestionBodySearchErrorToDelegate:(NSError *)error
{
    if (!error) return;
    
    NSDictionary *userInfo = @{ NSUnderlyingErrorKey : error };
    NSError *reportError = [NSError errorWithDomain:StackOverflowManagerError
                                               code:StackOverflowManagerQuestionSearchError
                                           userInfo:userInfo];
    [self.delegate fetchBodyForQuestionFailedWithError:reportError];
}

- (void)sendQuestionsToDelegate:(NSArray *)questions
{
    [self.delegate didReceiveQuestions:questions];
}

- (void)sendQuestionToDelegate:(Question *)question
{
    [self.delegate didReceiveQuestionBodyForQuestion:question];
}

@end
