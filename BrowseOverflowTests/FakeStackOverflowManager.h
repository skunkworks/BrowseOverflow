//
//  MockStackOverflowCommunicatorDelegate.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowManager.h"

@interface FakeStackOverflowManager : StackOverflowManager <StackOverflowCommunicatorDelegate>

@property (nonatomic) BOOL wasAskedToFetchQuestions;
@property (nonatomic) BOOL wasAskedToFetchQuestionBody;
@property (nonatomic) BOOL wasAskedToFetchAnswers;

@property (nonatomic) NSInteger topicFailureErrorCode;
@property (nonatomic, strong) NSString *receivedJSON;
@property (nonatomic, strong) Topic *topicForQuestionsToFetch;
@property (nonatomic, strong) Question *questionForQuestionBodyToFetch;
@property (nonatomic, strong) Question *questionForAnswersToFetch;

@end
