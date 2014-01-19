//
//  MockStackOverflowCommunicator.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackOverflowCommunicator.h"

@interface MockStackOverflowCommunicator : StackOverflowCommunicator

@property (nonatomic, readonly) BOOL wasAskedToFetchQuestions;
@property (nonatomic, readonly) BOOL wasAskedToFetchQuestionBody;
@property (nonatomic, readonly) BOOL wasAskedToFetchAnswers;
@property (nonatomic, readonly) NSInteger questionIDItFetched;
@property (nonatomic, readonly) NSString *tagItFetched;

@end
