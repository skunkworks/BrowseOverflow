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

@property (nonatomic) BOOL wasAskedToFetchQuestions;
@property (nonatomic) BOOL wasAskedToFetchQuestionBody;
@property (nonatomic) NSInteger questionIDItFetched;

@end
