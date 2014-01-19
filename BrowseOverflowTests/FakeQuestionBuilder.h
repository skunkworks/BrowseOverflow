//
//  FakeQuestionBuilder.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/13/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionBuilder.h"

@interface FakeQuestionBuilder : QuestionBuilder

@property (nonatomic, copy) NSString *receivedJSON;
@property (nonatomic, strong) Question *receivedQuestion;
@property (nonatomic, copy) NSError *errorToSet;
@property (nonatomic, copy) NSArray *questionsToReturn;
@property (nonatomic) BOOL successToReturn;
@end
