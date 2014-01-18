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
    NSArray *questions;
}

- (id)initWithName:(NSString *)name tag:(NSString *)tag
{
    if (self = [super init]) {
        _name = [name copy];
        _tag = [tag copy];
        questions = [NSArray array];
    }
    return self;
}

- (NSArray *)recentQuestions
{
    return [[self class] sortedQuestionsLatestFirst:questions];
}

- (void)addQuestion:(id)question
{
    questions = [questions arrayByAddingObject:question];
    if ([questions count] > 20) {
        questions = [[self class] sortedQuestionsLatestFirst:questions];
        questions = [questions subarrayWithRange:NSMakeRange(0, 20)];
    }
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
