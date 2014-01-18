//
//  QuestionBuilderTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/13/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QuestionBuilder.h"
#import "Question.h"

@interface QuestionBuilderTests : XCTestCase
{
    QuestionBuilder *questionBuilder;
}

@end

@implementation QuestionBuilderTests

static NSString *NoQuestionJSON = @"{ \"noitems\": true }";

static NSString *EmptyQuestionJSON = @"{ \"items\": [ {} ] }";

static NSString *OneQuestionJSON = @"{"
@"\"items\": ["
@"{"
@"\"tags\": ["
@"\"ios\","
@"\"iphone\","
@"\"objective-c\","
@"\"xcode5\","
@"\"cocoapods\""
@"],"
@"\"owner\": {"
@"\"reputation\": 22,"
@"\"user_id\": 2913347,"
@"\"user_type\": \"registered\","
@"\"accept_rate\": 75,"
@"\"profile_image\": \"https://www.gravatar.com\","
@"\"display_name\": \"Beebunny\","
@"\"link\": \"http://stackoverflow.com/users/2913347/beebunny\""
@"},"
@"\"is_answered\": false,"
@"\"view_count\": 2,"
@"\"answer_count\": 0,"
@"\"score\": 49,"
@"\"last_activity_date\": 1389676604,"
@"\"creation_date\": 1389676604,"
@"\"question_id\": 21106537,"
@"\"link\": \"http://stackoverflow.com/questions/21106537/integrate-framework-that-uses-cocoapods-to-build-into-existing-project\","
@"\"title\": \"Integrate framework that uses CocoaPods to build into existing project\","
@"\"body\": \"<p>I have an existing iOS project.  I want to use a framework that...</p>\""
@"}"
@"],"
@"\"has_more\": true,"
@"\"quota_max\": 10000,"
@"\"quota_remaining\": 9982"
@"}";

- (QuestionBuilder *)createQuestionBuilder {
    return [[QuestionBuilder alloc] init];
}

- (void)testQuestionsFromJSONWhenItReceivesNilJSONThrowsException
{
    questionBuilder = [self createQuestionBuilder];
    NSError *error;
    
    XCTAssertThrows([questionBuilder questionsFromJSON:nil error:&error], @"Lack of JSON data should be handled elsewhere");
}

- (void)testQuestionsFromJSONWhenItReceivesNULLErrorDoesNotThrowException
{
    questionBuilder = [self createQuestionBuilder];
    
    XCTAssertNoThrow([questionBuilder questionsFromJSON:@"Some data" error:NULL]);
}

- (void)testQuestionsFromJSONWhenItReceivesInvalidJSONSetsErrorWithInvalidJSONCode
{
    questionBuilder = [self createQuestionBuilder];
    NSError *error;
    
    [questionBuilder questionsFromJSON:@"Invalid JSON" error:&error];
    
    XCTAssertEqual([error code], QuestionBuilderInvalidJSONError);
}

- (void)testQuestionsFromJSONWhenItReceivesInvalidJSONReturnsNil
{
    questionBuilder = [self createQuestionBuilder];
    
    NSArray *questions = [questionBuilder questionsFromJSON:@"Invalid JSON" error:NULL];
    
    XCTAssertNil(questions);
}

// "Missing data": data that doesn't match the expected JSON format for StackOverflow API
- (void)testQuestionsFromJSONWhenItReceivesJSONWithNoQuestionsReturnsNil
{
    questionBuilder = [self createQuestionBuilder];
    
    NSArray *questions = [questionBuilder questionsFromJSON:NoQuestionJSON error:NULL];
    
    XCTAssertNil(questions);
}

- (void)testQuestionsFromJSONWhenItReceivesJSONWithNoQuestionsSetsErrorWithMissingDataCode
{
    questionBuilder = [self createQuestionBuilder];
    NSError *error;
    
    [questionBuilder questionsFromJSON:NoQuestionJSON error:&error];
    
    XCTAssertEqual([error code], (NSInteger)QuestionBuilderMissingDataError);
}

// "Right format": has an items property that contains an array (i.e. questions array)
- (void)testQuestionsFromJSONWhenItReceivesValidJSONWithRightFormatDoesNotSetError
{
    questionBuilder = [self createQuestionBuilder];
    NSError *error;
    
    [questionBuilder questionsFromJSON:EmptyQuestionJSON error:&error];
    
    XCTAssertNil(error);
}

- (void)testQuestionsFromJSONWhenItReceivesValidJSONWithOneItemReturnsArrayOfOneQuestion
{
    questionBuilder = [self createQuestionBuilder];
    
    NSArray *questions = [questionBuilder questionsFromJSON:OneQuestionJSON error:NULL];
    
    XCTAssertEqual((NSInteger)[questions count], 1);
    Question *question = questions[0];
    XCTAssertTrue([question isKindOfClass:[Question class]]);
}

- (void)testQuestionsFromJSONWhenItReceivesValidJSONWithOneItemSetsUpQuestionPropertiesCorrectly
{
    questionBuilder = [self createQuestionBuilder];
    
    NSArray *questions = [questionBuilder questionsFromJSON:OneQuestionJSON error:NULL];
    
    Question *question = questions[0];
    XCTAssertEqual(question.questionID, 21106537);
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1389676604];
    XCTAssertEqualObjects(question.date, expectedDate);
    XCTAssertEqualObjects(question.title, @"Integrate framework that uses CocoaPods to build into existing project");
    XCTAssertEqual(question.score, 49);
    Person *expectedAsker = [[Person alloc] initWithName:@"Beebunny"
                                               avatarURL:[NSURL URLWithString:@"https://www.gravatar.com"]];
    XCTAssertEqualObjects(question.asker, expectedAsker);
}

- (void)testQuestionsFromJSONWhenItReceivesValidJSONWithEmptyQuestionReturnsValidQuestion
{
    questionBuilder = [self createQuestionBuilder];
    
    NSArray *questions = [questionBuilder questionsFromJSON:EmptyQuestionJSON error:NULL];
    
    XCTAssertEqual([questions count], (NSUInteger)1);
}

- (void)testFillQuestionWhenItReceivesNilQuestionThrowsException
{
    questionBuilder = [self createQuestionBuilder];
    
    XCTAssertThrows([questionBuilder fillQuestion:nil withQuestionBodyJSON:@"don't matter" error:NULL]);
}

- (void)testFillQuestionWhenItReceivesInvalidJSONReturnsFalse
{
    questionBuilder = [self createQuestionBuilder];
    Question *question = [[Question alloc] init];
    
    BOOL successful = [questionBuilder fillQuestion:question withQuestionBodyJSON:@"invalid JSON" error:NULL];
    
    XCTAssertFalse(successful);
}

- (void)testFillQuestionWhenItReceivesInvalidJSONSetsErrorWithCorrectCode
{
    questionBuilder = [self createQuestionBuilder];
    Question *question = [[Question alloc] init];
    NSError *error;
    
    [questionBuilder fillQuestion:question withQuestionBodyJSON:@"invalid JSON" error:&error];
    
    XCTAssertEqual([error code], (NSInteger)QuestionBuilderInvalidJSONError);
}

- (void)testFillQuestionWhenItReceivesValidJSONWithMissingQuestionSetsErrorWithCorrectCode
{
    questionBuilder = [self createQuestionBuilder];
    Question *question = [[Question alloc] init];
    NSError *error;
    
    [questionBuilder fillQuestion:question withQuestionBodyJSON:NoQuestionJSON error:&error];
    
    XCTAssertEqual([error code], QuestionBuilderMissingDataError);
}

- (void)testFillQuestionWhenItReceivesValidJSONWithMissingQuestionReturnsFalse
{
    questionBuilder = [self createQuestionBuilder];
    Question *question = [[Question alloc] init];
    
    BOOL successful = [questionBuilder fillQuestion:question withQuestionBodyJSON:NoQuestionJSON error:NULL];
    
    XCTAssertFalse(successful);
}

- (void)testFillQuestionWhenItReceivesValidJSONWithMissingBodyReturnsFalse
{
    questionBuilder = [self createQuestionBuilder];
    Question *question = [[Question alloc] init];
    
    BOOL successful = [questionBuilder fillQuestion:question withQuestionBodyJSON:EmptyQuestionJSON error:NULL];
    
    XCTAssertFalse(successful);
}

- (void)testFillQuestionWhenItReceivesValidJSONWithMissingBodySetsErrorWithCorrectCode
{
    questionBuilder = [self createQuestionBuilder];
    Question *question = [[Question alloc] init];
    NSError *error;
    
    [questionBuilder fillQuestion:question withQuestionBodyJSON:EmptyQuestionJSON error:&error];
    
    XCTAssertEqual([error code], QuestionBuilderMissingDataError);
}

- (void)testFillQuestionWhenItReceivesValidJSONWithRightFormatReturnsTrue
{
    questionBuilder = [self createQuestionBuilder];
    Question *question = [[Question alloc] init];
    
    BOOL successful = [questionBuilder fillQuestion:question withQuestionBodyJSON:OneQuestionJSON error:NULL];
    
    XCTAssertTrue(successful);
}

- (void)testFillQuestionWhenItReceivesValidJSONWithRightFormatSetsQuestionBody
{
    questionBuilder = [self createQuestionBuilder];
    Question *question = [[Question alloc] init];
    
    [questionBuilder fillQuestion:question withQuestionBodyJSON:OneQuestionJSON error:NULL];
    
    //<p>I have an existing iOS project.  I want to use a framework that ...\\n
    XCTAssertEqualObjects(question.body, @"<p>I have an existing iOS project.  I want to use a framework that...</p>");
}

@end
