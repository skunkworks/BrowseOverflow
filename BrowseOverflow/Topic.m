//
//  Topic.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "Topic.h"

@implementation Topic
{
    NSMutableArray *questions;
}

- (id)initWithName:(NSString *)name tag:(NSString *)tag
{
    if (self = [super init]) {
        _name = [name copy];
        _tag = [tag copy];
        questions = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)recentQuestions
{
    return [[self class] sortedQuestionsLatestFirst:questions];
}

- (void)addQuestion:(id)question
{
    [questions addObject:question];
    if ([questions count] > 20) {
        NSArray *sortedQuestions = [[self class] sortedQuestionsLatestFirst:questions];
        questions = [NSMutableArray arrayWithArray:[sortedQuestions subarrayWithRange:NSMakeRange(0, 20)]];
    }

//    NSInteger questionID = [(Question *)question questionID];
//    NSUInteger idx = [questions indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        Question *testQuestion = (Question *)obj;
//        if (testQuestion.questionID == questionID) {
//            *stop = YES;
//            return YES;
//        }
//        return NO;
//    }];
//    if (idx == NSNotFound) {
//        [questions addObject:question];
//        if ([questions count] > 20) {
//            NSArray *sortedQuestions = [[self class] sortedQuestionsLatestFirst:questions];
//            questions = [NSMutableArray arrayWithArray:[sortedQuestions subarrayWithRange:NSMakeRange(0, 20)]];
//        }
//    } else {
//        questions[idx] = question;
//    }
}

+ (NSArray *)sortedQuestionsLatestFirst:(NSArray *)questionList
{
    NSArray *sortedQuestions = [questionList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                {
                                    NSDate *date1 = ((Question *)obj1).date;
                                    NSDate *date2 = ((Question *)obj2).date;
                                    return [date2 compare:date1];
                                }];
    
    return sortedQuestions;
}

@end
