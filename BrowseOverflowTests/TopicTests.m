//
//  TopicTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Topic.h"

@interface TopicTests : XCTestCase
{
    Topic *topic;
}

@end

@implementation TopicTests

- (Topic *)createTopic {
    return [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];
}

- (void)testTopicExists
{
    topic = [self createTopic];
    XCTAssertNotNil(topic);
}

- (void)testTopicHasAName
{
    topic = [self createTopic];
    XCTAssertEqual([topic name], @"iPhone");
}

- (void)testTopicHasATag
{
    topic = [self createTopic];
    XCTAssertEqual([topic tag], @"iphone");
}

- (void)testRecentQuestionsWhenCalledReturnsList
{
    topic = [self createTopic];
    
    NSArray *questionList = [topic recentQuestions];
    
    XCTAssertTrue([questionList isKindOfClass:[NSArray class]]);
}

- (void)testRecentQuestionsByDefaultIsEmpty
{
    topic = [self createTopic];
    
    NSArray *questionList = [topic recentQuestions];
    int numberOfQuestions = [questionList count];
    XCTAssertEqual(numberOfQuestions, 0);
}

- (void)testAddQuestionWhenCalledAddsAQuestionToRecentQuestions
{
    topic = [self createTopic];
    Question *question = [[Question alloc] init];
    
    [topic addQuestion:question];
    
    NSArray *questionList = [topic recentQuestions];
    int numberOfQuestions = [questionList count];
    XCTAssertEqual(numberOfQuestions, 1);
}

// TODO: Would be best to implement question uniqueness in Topic, but this will break other tests (not a big deal)
//
//- (void)testAddQuestionWhenItHasQuestionWithSameIDReplacesOldQuestionWithNewQuestion
//{
//    topic = [self createTopic];
//    Question *oldQuestion = [[Question alloc] init];
//    oldQuestion.title = @"Old title";
//    oldQuestion.score = 42;
//    oldQuestion.date = [NSDate distantPast];
//    oldQuestion.questionID = 12345;
//    oldQuestion.body = @"Old body";
//    oldQuestion.asker = [[Person alloc] initWithName:@"Some dude" avatarURL:nil];
//    Question *newQuestion = [[Question alloc] init];
//    newQuestion.title = @"New title";
//    newQuestion.score = 43;
//    newQuestion.date = [NSDate distantFuture];
//    newQuestion.questionID = 12345;
//    newQuestion.body = @"New body";
//    newQuestion.asker = [[Person alloc] initWithName:@"Richard Shin" avatarURL:nil];
//
//    [topic addQuestion:oldQuestion];
//    [topic addQuestion:newQuestion];
//    
//    XCTAssertEqual((NSInteger)[[topic recentQuestions] count], 1);
//    Question *question = [topic recentQuestions][0];
//    XCTAssertEqualObjects(question.title, @"New title");
//    XCTAssertEqual(question.score, 43);
//    XCTAssertEqualObjects(question.date, [NSDate distantFuture]);
//    XCTAssertEqual(question.questionID, 12345);
//    XCTAssertEqualObjects(question.body, @"New body");
//    XCTAssertEqualObjects(question.asker.name, @"Richard Shin");
//}

- (void)testRecentQuestionsWhenAddedInAscendingChronologicalOrderAreReturnedInDescendingChronologicalOrder
{
    topic = [self createTopic];
    Question *earlierQuestion = [[Question alloc] init];
    Question *laterQuestion = [[Question alloc] init];
    earlierQuestion.date = [NSDate distantPast];
    laterQuestion.date = [NSDate distantFuture];
    
    [topic addQuestion:earlierQuestion];
    [topic addQuestion:laterQuestion];
    
    NSArray *questionList = [topic recentQuestions];
    Question *listedFirst = questionList[0];
    Question *listedSecond = questionList[1];
    XCTAssertTrue([listedFirst.date compare:listedSecond.date] == NSOrderedDescending);
}

- (void)testRecentQuestionsWhenAddedInDescendingChronologicalOrderAreReturnedInDescendingChronologicalOrder
{
    topic = [self createTopic];
    Question *earlierQuestion = [[Question alloc] init];
    Question *laterQuestion = [[Question alloc] init];
    earlierQuestion.date = [NSDate distantPast];
    laterQuestion.date = [NSDate distantFuture];
    
    [topic addQuestion:laterQuestion];
    [topic addQuestion:earlierQuestion];
    
    NSArray *questionList = [topic recentQuestions];
    Question *listedFirst = questionList[0];
    Question *listedSecond = questionList[1];
    XCTAssertTrue([listedFirst.date compare:listedSecond.date] == NSOrderedDescending);
}

- (void)testRecentQuestionsWhenManyQuestionsAreAddedReturnsMaxLimitOfTwenty
{
    topic = [self createTopic];
    Question *question = [[Question alloc] init];
    
    for (int i = 0; i < 25; i++) {
        [topic addQuestion:question];
    }
    
    NSArray *questionList = [topic recentQuestions];
    int numberOfQuestions = [questionList count];
    XCTAssertTrue(numberOfQuestions == 20);
}

- (void)testRecentQuestionsWhenManyEarlierQuestionsAreAddedBeforeLatestQuestionReturnsMostRecentQuestions
{
    topic = [self createTopic];
    Question *earlyQuestion = [[Question alloc] init];
    Question *latestQuestion = [[Question alloc] init];
    earlyQuestion.date = [NSDate distantPast];
    latestQuestion.date = [NSDate distantFuture];
    
    for (int i = 0; i < 25; i++) {
        [topic addQuestion:earlyQuestion];
    }
    [topic addQuestion:latestQuestion];
    
    Question *listedFirst = [[topic recentQuestions] objectAtIndex:0];
    XCTAssertEqualObjects(listedFirst, latestQuestion);
}

- (void)testRecentQuestionsWhenLatestQuestionIsAddedBeforeManyEarlierQuestionsReturnsMostRecentQuestions
{
    topic = [self createTopic];
    Question *earlyQuestion = [[Question alloc] init];
    Question *latestQuestion = [[Question alloc] init];
    earlyQuestion.date = [NSDate distantPast];
    latestQuestion.date = [NSDate distantFuture];
    
    [topic addQuestion:latestQuestion];
    for (int i = 0; i < 25; i++) {
        [topic addQuestion:earlyQuestion];
    }
    
    Question *listedFirst = [[topic recentQuestions] objectAtIndex:0];
    XCTAssertEqualObjects(listedFirst, latestQuestion);
}

@end
