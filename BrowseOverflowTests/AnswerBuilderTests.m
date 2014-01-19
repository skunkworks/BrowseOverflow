//
//  AnswerBuilderTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AnswerBuilder.h"

@interface AnswerBuilderTests : XCTestCase
{
    AnswerBuilder *answerBuilder;
}
@end

@implementation AnswerBuilderTests

static NSString *InvalidJSON = @"This is not JSON, my friend!";
static NSString *MissingDataJSON = @"{ \"noitems\": true }";
static NSString *EmptyAnswersJSON = @"{ \"items\": [ {} ] }";
static NSString *OneAnswerJSON = @"{"
@"\"items\": ["
@"{"
@"\"owner\": {"
@"\"reputation\": 11,"
@"\"user_id\": 766491,"
@"\"user_type\": \"registered\","
@"\"profile_image\": \"https://www.gravatar.com\","
@"\"display_name\": \"Richard Shin\","
@"\"link\": \"http://stackoverflow.com/users/755491/richard-shin\""
@"},"
@"\"is_accepted\": true,"
@"\"score\": 49,"
@"\"last_activity_date\": 1389333687,"
@"\"creation_date\": 1389333687,"
@"\"answer_id\": 21037200,"
@"\"question_id\": 20965117,"
@"\"title\": \"Writing a unit test to verify NSTimer was started\","
@"\"body\": \"<p>Okay! It took a while to figure out how to do this. I'll...</p>\""
@"}"
@"],"
@"\"has_more\": false,"
@"\"quota_max\": 10000,"
@"\"quota_remaining\": 9982"
@"}";

#pragma mark Helper utility methods

- (AnswerBuilder *)createAnswerBuilder {
    PersonBuilder *personBuilder = [[PersonBuilder alloc] init];
    return [[AnswerBuilder alloc] initWithPersonBuilder:personBuilder];
}

#pragma mark - Initializer tests

- (void)testInitByDefaultThrowsException
{
    XCTAssertThrows([[AnswerBuilder alloc] init]);
}

- (void)testInitWithPersonBuilderWhenPersonBuilderIsNilThrowsException
{
    XCTAssertThrows([[AnswerBuilder alloc] initWithPersonBuilder:nil]);
}

- (void)testInitWithPersonBuilderWhenPersonBuilderIsNotNilDoesNotThrowException
{
    PersonBuilder *personBuilder = [[PersonBuilder alloc] init];
    XCTAssertNoThrow([[AnswerBuilder alloc] initWithPersonBuilder:personBuilder]);
}

#pragma mark - Tests when JSON is nil

- (void)testAnswersFromJSONWhenJSONIsNilThrowsException
{
    answerBuilder = [self createAnswerBuilder];
    
    XCTAssertThrows([answerBuilder answersFromJSON:nil error:NULL]);
}

#pragma mark - Tests when error is NULL

- (void)testAnswersFromJSONWhenErrorIsNULLDoesNotThrowException
{
    answerBuilder = [self createAnswerBuilder];
    
    XCTAssertNoThrow([answerBuilder answersFromJSON:@"Some JSON" error:NULL]);
}

#pragma mark - Tests when JSON is valid and has data

// It should return array of answers
- (void)testAnswersFromJSONWhenValidJSONWithAnswerDataReturnsArrayOfAnswers
{
    answerBuilder = [self createAnswerBuilder];
    
    NSArray *answers = [answerBuilder answersFromJSON:OneAnswerJSON error:NULL];
    
    XCTAssertNotNil(answers);
    XCTAssertTrue([answers isKindOfClass:[NSArray class]]);
}

// The answers should be filled in with the right properties
- (void)testAnswersFromJSONWhenValidJSONWithAnswerDataFillsInAnswerProperties
{
    answerBuilder = [self createAnswerBuilder];
    
    NSArray *answers = [answerBuilder answersFromJSON:OneAnswerJSON error:NULL];
    
    Answer *answer = (Answer *)answers[0];
    XCTAssertEqual(answer.score, 49);
    XCTAssertEqual(answer.accepted, YES);
    XCTAssertEqualObjects(answer.text, @"<p>Okay! It took a while to figure out how to do this. I'll...</p>");
    XCTAssertEqualObjects(answer.answerer.name, @"Richard Shin");
    XCTAssertEqualObjects([answer.answerer.avatarURL absoluteString], @"https://www.gravatar.com");
}

// It should not set error
- (void)testAnswersFromJSONWhenValidJSONWithAnswerDataDoesNotSetError
{
    answerBuilder = [self createAnswerBuilder];
    
    NSError *error;
    [answerBuilder answersFromJSON:OneAnswerJSON error:&error];
    
    XCTAssertNil(error);
}

#pragma mark - Tests when JSON is valid but missing data

// It should return nil
- (void)testAnswersFromJSONWhenJSONIsMissingDataReturnsNil
{
    answerBuilder = [self createAnswerBuilder];
    
    NSArray *answers = [answerBuilder answersFromJSON:MissingDataJSON error:NULL];
    
    XCTAssertNil(answers);
}

// It should set the error with the right domain and code
- (void)testAnswersFromJSONWhenJSONIsMissingDataSetsErrorWithCode
{
    answerBuilder = [self createAnswerBuilder];
    
    NSError *error;
    [answerBuilder answersFromJSON:MissingDataJSON error:&error];
    
    XCTAssertEqualObjects(error.domain, AnswerBuilderError);
    XCTAssertEqual(error.code, AnswerBuilderMissingDataError);
}

#pragma mark - Tests when JSON is invalid
// It should return nil
- (void)testAnswersFromJSONWhenJSONIsInvalidReturnsNil
{
    answerBuilder = [self createAnswerBuilder];
    
    NSArray *answers = [answerBuilder answersFromJSON:InvalidJSON error:NULL];
    
    XCTAssertNil(answers);
}

// It should set the error with the right domain and code
- (void)testAnswersFromJSONWhenJSONIsInvalidSetsErrorWithCode
{
    answerBuilder = [self createAnswerBuilder];

    NSError *error;
    [answerBuilder answersFromJSON:InvalidJSON error:&error];
    
    XCTAssertEqualObjects(error.domain, AnswerBuilderError);
    XCTAssertEqual(error.code, AnswerBuilderInvalidJSONError);
}

// It should set the error with the right domain and code
- (void)testAnswersFromJSONWhenJSONIsInvalidSetsErrorWithUnderlyingError
{
    answerBuilder = [self createAnswerBuilder];
    
    NSError *error;
    [answerBuilder answersFromJSON:InvalidJSON error:&error];
    
    NSError *underlyingError = [[error userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertNotNil(underlyingError);
}

@end
