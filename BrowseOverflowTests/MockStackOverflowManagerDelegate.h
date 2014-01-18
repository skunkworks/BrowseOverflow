//
//  MockStackOverflowManagerDelegate.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/13/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowManager.h"

@interface MockStackOverflowManagerDelegate : NSObject <StackOverflowManagerDelegate>

@property (nonatomic, strong) NSError *fetchError;
@property (nonatomic, strong) NSArray *receivedQuestions;
@property (nonatomic, strong) Question *receivedQuestion;

@end
