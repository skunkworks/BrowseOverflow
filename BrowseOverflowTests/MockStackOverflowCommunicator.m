//
//  MockStackOverflowCommunicator.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "MockStackOverflowCommunicator.h"

@interface MockStackOverflowCommunicator ()
@property (nonatomic, readwrite) BOOL wasAskedToFetchQuestions;
@property (nonatomic, readwrite) BOOL wasAskedToFetchQuestionBody;
@property (nonatomic, readwrite) BOOL wasAskedToFetchAnswers;
@property (nonatomic, readwrite) NSInteger questionIDItFetched;
@property (nonatomic, readwrite) NSString *tagItFetched;
@end

@implementation MockStackOverflowCommunicator

- (void)fetchQuestionsWithTag:(NSString *)tag
{
    self.wasAskedToFetchQuestions = YES;
    self.tagItFetched = tag;
}

- (void)fetchBodyForQuestionWithID:(NSInteger)questionID
{
    self.wasAskedToFetchQuestionBody = YES;
    self.questionIDItFetched = questionID;
}

- (void)fetchAnswersToQuestionWithID:(NSInteger)questionID
{
    self.wasAskedToFetchAnswers = YES;
    self.questionIDItFetched = questionID;
}

@end
