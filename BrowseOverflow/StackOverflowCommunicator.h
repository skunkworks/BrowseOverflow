//
//  StackOverflowCommunicator.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"

@protocol StackOverflowCommunicatorDelegate <NSObject>

- (void)fetchQuestionsFailedWithError:(NSError *)error;
- (void)fetchQuestionsDidReturnJSON:(NSString *)objectNotation;
- (void)fetchBodyForQuestionWithIDFailedWithError:(NSError *)error;
- (void)fetchBodyForQuestionWithID:(NSInteger)questionID
                     didReturnJSON:(NSString *)objectNotation;
- (void)fetchAnswersForQuestionWithIDFailedWithError:(NSError *)error;
- (void)fetchAnswersForQuestionWithID:(NSInteger)questionID
                        didReturnJSON:(NSString *)objectNotation;
@end

@interface StackOverflowCommunicator : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURL *fetchingURL;
    NSURLConnection *fetchingConnection;
    NSMutableData *receivedData;
}

extern NSString *const StackOverflowCommunicatorErrorDomain;

- (void)fetchQuestionsWithTag:(NSString *)tag;
- (void)fetchBodyForQuestionWithID:(NSInteger)questionID;
- (void)fetchAnswersToQuestionWithID:(NSInteger)questionID;

// What should this method do?
- (void)fetchInformationForQuestionWithID:(NSInteger)questionID;

- (void)cancelAndDiscardCurrentURLConnection;

@property (nonatomic, weak) id <StackOverflowCommunicatorDelegate> delegate;

@end
