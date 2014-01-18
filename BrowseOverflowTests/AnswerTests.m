//
//  AnswerTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Answer.h"

@interface AnswerTests : XCTestCase
{
    Answer *answer;
}

@end

@implementation AnswerTests

- (Answer *)createAnswer {
    return [[Answer alloc] init];
}

- (void)testAnswerExists
{
    answer = [self createAnswer];
    
    XCTAssertNotNil(answer);
}

- (void)testAnswerHasText
{
    answer = [self createAnswer];
    NSString *answerText = @"This is some answer text";
    
    answer.text = answerText;
    
    XCTAssertEqual(answer.text, answerText);
}

- (void)testAnswerHasAScore
{
    answer = [self createAnswer];
    
    answer.score = 30;
    
    XCTAssertEqual(answer.score, 30);
}

- (void)testAnswerHasAnAnswerer
{
    answer = [self createAnswer];
    Person *person = [[Person alloc] init];
    
    answer.answerer = person;
    
    XCTAssertEqual(answer.answerer, person);
}

- (void)testAnswerByDefaultIsNotAccepted
{
    answer = [self createAnswer];
    
    XCTAssertFalse(answer.isAccepted);
}

- (void)testAnswerCanBeAccepted
{
    answer = [self createAnswer];
    
    answer.accepted = YES;
    
    XCTAssertTrue(answer.isAccepted);
}

#pragma mark - Answer comparison and order tests

- (void)testAnswerComparisonPutsAcceptedAnswersBeforeUnacceptedWithHigherScores
{
    Answer *acceptedAnswer = [self createAnswer];
    Answer *unacceptedAnswer = [self createAnswer];
    acceptedAnswer.accepted = YES;
    acceptedAnswer.score = 1;
    unacceptedAnswer.accepted = NO;
    unacceptedAnswer.score = 100;
    
    NSComparisonResult acceptedComparisonResult = [acceptedAnswer compare:unacceptedAnswer];
    NSComparisonResult unacceptedComparisonResult = [unacceptedAnswer compare:acceptedAnswer];
    
    XCTAssertEqual(acceptedComparisonResult, NSOrderedAscending);
    XCTAssertEqual(unacceptedComparisonResult, NSOrderedDescending);
}

- (void)testAnswerComparisonWhenAnswersHaveTheSameScoreAreConsideredEqual
{
    Answer *firstAnswer = [self createAnswer];
    Answer *secondAnswer = [self createAnswer];
    firstAnswer.score = 100;
    secondAnswer.score = 100;
    
    NSComparisonResult firstComparisonResult = [firstAnswer compare:secondAnswer];
    NSComparisonResult secondComparisonResult = [secondAnswer compare:firstAnswer];
    
    XCTAssertEqual(firstComparisonResult, NSOrderedSame);
    XCTAssertEqual(secondComparisonResult, NSOrderedSame);
}

- (void)testAnswerComparisonPutsAnswersWithHigherScoresFirst
{
    Answer *higherAnswer = [self createAnswer];
    Answer *lowerAnswer = [self createAnswer];
    higherAnswer.score = 100;
    lowerAnswer.score = 99;
    
    NSComparisonResult higherComparisonResult = [higherAnswer compare:lowerAnswer];
    NSComparisonResult lowerComparisonResult = [lowerAnswer compare:higherAnswer];
    
    XCTAssertEqual(higherComparisonResult, NSOrderedAscending);
    XCTAssertEqual(lowerComparisonResult, NSOrderedDescending);
}

@end
