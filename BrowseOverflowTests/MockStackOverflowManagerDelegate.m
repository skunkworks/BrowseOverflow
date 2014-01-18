//
//  MockStackOverflowManagerDelegate.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/13/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "MockStackOverflowManagerDelegate.h"

@implementation MockStackOverflowManagerDelegate

- (void)fetchQuestionsForTopicFailedWithError:(NSError *)error
{
    self.fetchError = error;
}

- (void)didReceiveQuestions:(NSArray *)questions
{
    self.receivedQuestions = questions;
}

- (void)fetchBodyForQuestionFailedWithError:(NSError *)error
{
    self.fetchError = error;
}

- (void)didReceiveQuestionBodyForQuestion:(Question *)question
{
    self.receivedQuestion = question;
}

@end
