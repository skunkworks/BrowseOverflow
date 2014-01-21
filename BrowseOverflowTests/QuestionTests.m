//
//  QuestionTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Question.h"

@interface QuestionTests : XCTestCase
{
    Question *question;
}

@end

@implementation QuestionTests

- (Question *)createQuestion {
    return [[Question alloc] init];
}

- (Answer *)createAnswerWithScore:(NSInteger)score accepted:(BOOL)accepted {
    Answer *answer = [[Answer alloc] init];
    answer.score = score;
    answer.accepted = accepted;
    return answer;
}

#pragma mark - Unit test helper method tests

- (void)testCreateAnswerWithScore
{
    Answer *answer = [self createAnswerWithScore:100 accepted:YES];
    XCTAssertEqual(answer.score, 100);
    XCTAssertEqual(answer.accepted, YES);
}

#pragma mark - Question tests

- (void)testQuestionExists
{
    question = [self createQuestion];
    
    XCTAssertNotNil(question);
}

// Note to self: in writing this test, the book makes a really good point about TDD and why
// the philosophy is to write the *simplest thing* that gets the test to pass. The book's first
// solution is to create a - (NSDate *)date method. I skipped that and went directly to creating
// a property, which by strict TDD practices is not right because I jumped ahead to creating
// not just a getter but also a setter. I did that without having a use case or a test dictate
// that that's necessary. Again, the point of TDD is to write only the code you need!
- (void)testQuestionHasADate
{
    question = [self createQuestion];
    
    NSDate *testDate = [NSDate distantPast];
    question.date = testDate;
    
    XCTAssertEqual(question.date, testDate);
}

- (void)testQuestionHasATitle
{
    question = [self createQuestion];
    
    NSString *testTitle = @"Do iPhones dream of electric sheep?";
    question.title = testTitle;
    
    XCTAssertEqualObjects(question.title, testTitle);
}

- (void)testQuestionHasAScore
{
    question = [self createQuestion];
    
    question.score = 42;
    
    XCTAssertEqual(question.score, 42);
}

- (void)testQuestionHasAQuestionID
{
    question = [self createQuestion];
    
    question.questionID = 1234;
    
    XCTAssertEqual(question.questionID, 1234);
}

- (void)testQuestionHasAnAsker
{
    question = [self createQuestion];
    Person *asker = [[Person alloc] init];
    
    question.asker = asker;
    
    XCTAssertTrue([question.asker isKindOfClass:[Person class]]);
}

- (void)testQuestionHasABody
{
    question = [self createQuestion];
    
    question.body = @"This is the question body";
    
    XCTAssertEqualObjects(question.body, @"This is the question body");
}

- (void)testQuestionHasAnswers
{
    question = [self createQuestion];
    
    NSArray *answers = question.answers;
    
    XCTAssertTrue([answers isKindOfClass:[NSArray class]]);
}

- (void)testAddAnswerWhenCalledAddsAnAnswer
{
    question = [self createQuestion];
    Answer *answer = [[Answer alloc] init];
    
    [question addAnswer:answer];
    NSInteger numberOfAnswers = [question.answers count];
    
    XCTAssertEqual(numberOfAnswers, 1);
}

- (void)testAnswersWhenAcceptedAnswerAddedFirstIsOrderedByAcceptedToUnaccepted
{
    question = [self createQuestion];
    Answer *acceptedAnswer = [self createAnswerWithScore:1 accepted:YES];
    Answer *otherAnswer = [self createAnswerWithScore:100 accepted:NO];

    [question addAnswer:acceptedAnswer];
    [question addAnswer:otherAnswer];
    NSArray *answers = [question answers];
    Answer *firstListed = answers[0];
    Answer *secondListed = answers[1];
    
    XCTAssertEqual(firstListed, acceptedAnswer);
    XCTAssertEqual(secondListed, otherAnswer);
}

- (void)testAnswersWhenAcceptedAnswerAddedLastIsOrderedByAcceptedToUnaccepted
{
    question = [self createQuestion];
    Answer *acceptedAnswer = [self createAnswerWithScore:1 accepted:YES];
    Answer *otherAnswer = [self createAnswerWithScore:100 accepted:NO];
    
    [question addAnswer:otherAnswer];
    [question addAnswer:acceptedAnswer];
    NSArray *answers = [question answers];
    Answer *firstListed = answers[0];
    
    XCTAssertTrue([firstListed isAccepted]);
}


- (void)testAnswersWhenHigherScoreAddedFirstIsOrderedFromHighToLowScores
{
    question = [self createQuestion];
    Answer *higherAnswer = [self createAnswerWithScore:100 accepted:NO];
    Answer *lowerAnswer = [self createAnswerWithScore:99 accepted:NO];
    
    [question addAnswer:higherAnswer];
    [question addAnswer:lowerAnswer];
    NSArray *answers = [question answers];
    Answer *firstListed = answers[0];
    Answer *secondListed = answers[1];
    
    XCTAssertEqual(firstListed, higherAnswer);
    XCTAssertEqual(secondListed, lowerAnswer);
}

- (void)testAnswersWhenHigherScoreAddedLastIsOrderedFromHighToLowScores
{
    question = [self createQuestion];
    Answer *higherAnswer = [self createAnswerWithScore:100 accepted:NO];
    Answer *lowerAnswer = [self createAnswerWithScore:99 accepted:NO];
    
    [question addAnswer:lowerAnswer];
    [question addAnswer:higherAnswer];
    NSArray *answers = [question answers];
    Answer *firstListed = answers[0];
    Answer *secondListed = answers[1];
    
    XCTAssertEqual(firstListed, higherAnswer);
    XCTAssertEqual(secondListed, lowerAnswer);
}

@end
