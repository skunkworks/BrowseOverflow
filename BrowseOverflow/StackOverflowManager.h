//
//  StackOverflowManager.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowCommunicator.h"
#import "Topic.h"
#import "QuestionBuilder.h"

@protocol StackOverflowManagerDelegate <NSObject>

- (void)fetchQuestionsForTopicFailedWithError:(NSError *)error;
- (void)didReceiveQuestions:(NSArray *)questions;
- (void)fetchBodyForQuestionFailedWithError:(NSError *)error;
- (void)didReceiveQuestionBodyForQuestion:(Question *)question;

@end

@interface StackOverflowManager : NSObject <StackOverflowCommunicatorDelegate>

extern NSString *const StackOverflowManagerError;

enum {
    StackOverflowManagerQuestionSearchError,
    StackOverflowManagerQuestionBodySearchError
};

@property (nonatomic, weak) id<StackOverflowManagerDelegate> delegate;
// Should probably be in a designated init, since this class is useless without this
@property (nonatomic, strong) StackOverflowCommunicator *communicator;
@property (nonatomic, strong) QuestionBuilder *questionBuilder;

- (void)fetchQuestionsForTopic:(Topic *)topic;
- (void)fetchBodyForQuestion:(Question *)question;

@end
