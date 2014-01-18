//
//  MockStackOverflowCommunicator.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "MockStackOverflowCommunicator.h"

@implementation MockStackOverflowCommunicator

- (void)searchForQuestionsWithTag:(NSString *)tag
{
    self.wasAskedToFetchQuestions = YES;
}

- (void)fetchBodyForQuestionWithID:(NSInteger)questionID
{
    self.wasAskedToFetchQuestionBody = YES;
    self.questionIDItFetched = questionID;
}

@end
