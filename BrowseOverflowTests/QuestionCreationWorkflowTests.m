//
//  QuestionCreationWorkflowTests
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StackOverflowManager.h"
#import "MockStackOverflowManagerDelegate.h"
#import "MockStackOverflowCommunicator.h"
#import "MockQuestionBuilder.h"

@interface QuestionCreationWorkflowTests : XCTestCase
{
    StackOverflowManager *mgr;
}

@end

@implementation QuestionCreationWorkflowTests

- (StackOverflowManager *)createStackOverflowManager {
    return [[StackOverflowManager alloc] init];
}

- (NSError *)createFakeError {
    return [NSError errorWithDomain:@"Test domain"
                               code:0
                           userInfo:nil];
}

- (void)testDelegateWhenSetToNonConformingObjectThrows
{
    mgr = [self createStackOverflowManager];
    
    id nonconformingObj = [NSNull null];
    
    XCTAssertThrows(mgr.delegate = nonconformingObj);
}

- (void)testDelegateWhenSetToConformingObjectDoesntThrow
{
    mgr = [self createStackOverflowManager];
    
    id conformingObj = [[MockStackOverflowManagerDelegate alloc] init];
    
    XCTAssertNoThrow(mgr.delegate = conformingObj);
}

- (void)testDelegateWhenSetToNilDoesntThrow
{
    mgr = [self createStackOverflowManager];
    
    XCTAssertNoThrow(mgr.delegate = nil);
}

- (void)testFetchQuestionsForTopicWhenCalledFetchesQuestionsWithCommunicator
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowCommunicator *mockCommunicator = [[MockStackOverflowCommunicator alloc] init];
    mgr.communicator = mockCommunicator;
    Topic *topic = [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];
    
    [mgr fetchQuestionsForTopic:topic];
    
    XCTAssertTrue([mockCommunicator wasAskedToFetchQuestions]);
}

// Verify that when the manager receives an error back from the communicator -- via searchingForQuestionsFailedWithError --
// that it in turn reports its own error (at its abstraction level) back to its delegate.
- (void)testManagerWhenSearchingQuestionsCausesErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    NSError *errorFromCommunicator = [self createFakeError];
    
    // -searchingForQuestionsFailedWithError: is a method implemented by the communicator's delegate
    // when an attempt to search for questions fails.
    [mgr searchForQuestionsFailedWithError:errorFromCommunicator];
    
    // -fetchError is a mock-only property that stores the error that the manager mock delegate receives
    // from the manager.
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNotEqualObjects(errorFromManager, errorFromCommunicator);
}

- (void)testManagerWhenSearchingQuestionsCausesErrorNotifiesDelegateWithUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    
    NSError *errorFromCommunicator = [self createFakeError];
    [mgr searchForQuestionsFailedWithError:errorFromCommunicator];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    NSError *underlyingError = [[errorFromManager userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertEqual(underlyingError, errorFromCommunicator);
}

- (void)testManagerWhenSearchingQuestionsReturnsJSONResponsePassesResponseToQuestionBuilder
{
    mgr = [self createStackOverflowManager];
    MockQuestionBuilder *mockQuestionBuilder = [[MockQuestionBuilder alloc] init];
    mgr.questionBuilder = mockQuestionBuilder;
    
    [mgr searchForQuestionsDidReturnJSON:@"valid JSON results"];
    
    XCTAssertEqual(mockQuestionBuilder.receivedJSON, @"valid JSON results");
}

- (void)testManagerWhenBuildingQuestionsCausesErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    MockQuestionBuilder *mockQuestionBuilder = [[MockQuestionBuilder alloc] init];
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    NSError *errorFromQuestionBuilder = [self createFakeError];
    mockQuestionBuilder.errorToSet = errorFromQuestionBuilder;
    mockQuestionBuilder.questionsToReturn = nil;

    [mgr searchForQuestionsDidReturnJSON:@"invalid JSON results"];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNotEqualObjects(errorFromManager, errorFromQuestionBuilder);
}

- (void)testManagerWhenBuildingQuestionsCausesErrorNotifiesDelegateWithErrorContainingUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    MockQuestionBuilder *mockQuestionBuilder = [[MockQuestionBuilder alloc] init];
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    NSError *errorFromQuestionBuilder = [self createFakeError];
    mockQuestionBuilder.errorToSet = errorFromQuestionBuilder;
    
    [mgr searchForQuestionsDidReturnJSON:@"invalid JSON results"];
    
    NSError *underlyingError = [[[mockDelegate fetchError] userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertNotNil(underlyingError);
}

- (void)testManagerWhenBuildingQuestionsCausesErrorSendsDelegateAnArrayOfQuestions
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    MockQuestionBuilder *mockQuestionBuilder = [[MockQuestionBuilder alloc] init];
    NSArray *questionsFromQuestionBuilder = [NSArray arrayWithObject:[[Question alloc] init]];
    mockQuestionBuilder.questionsToReturn = questionsFromQuestionBuilder;
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    
    [mgr searchForQuestionsDidReturnJSON:@"valid JSON results"];
    
    NSArray *questionsFromManager = [mockDelegate receivedQuestions];

    XCTAssertEqualObjects(questionsFromManager, questionsFromQuestionBuilder);
}

- (void)testManagerWhenBuildingQuestionsIsSuccessfulDoesNotReportErrorToDelegate
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    MockQuestionBuilder *mockQuestionBuilder = [[MockQuestionBuilder alloc] init];
    mockQuestionBuilder.questionsToReturn = [NSArray arrayWithObject:[[Question alloc] init]];
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    
    [mgr searchForQuestionsDidReturnJSON:@"valid JSON results"];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNil(errorFromManager);
}

// Additional specification: if a topic legitimately has 0 questions, it should return an empty array
- (void)testManagerWhenBuildingQuestionsReturnsNoQuestionsSendsDelegateAnEmptyArray
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    MockQuestionBuilder *mockQuestionBuilder = [[MockQuestionBuilder alloc] init];
    NSArray *emptyArray = [[NSArray alloc] init];
    mockQuestionBuilder.questionsToReturn = emptyArray;
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    
    [mgr searchForQuestionsDidReturnJSON:@"valid JSON results"];
    
    NSArray *questionsFromManager = [mockDelegate receivedQuestions];
 
    XCTAssertEqualObjects(questionsFromManager, emptyArray);
}

- (void)testFetchBodyForQuestionWhenCalledFetchesBodyWithCommunicator
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowCommunicator *mockCommunicator = [[MockStackOverflowCommunicator alloc] init];
    mgr.communicator = mockCommunicator;
    Question *question = [[Question alloc] init];
    
    [mgr fetchBodyForQuestion:question];
    
    XCTAssertTrue([mockCommunicator wasAskedToFetchQuestionBody]);
}

- (void)testFetchBodyForQuestionWhenCalledSendsTheRightQuestionIDToCommunicator
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowCommunicator *mockCommunicator = [[MockStackOverflowCommunicator alloc] init];
    mgr.communicator = mockCommunicator;
    Question *question = [[Question alloc] init];
    question.questionID = 12345;
    
    [mgr fetchBodyForQuestion:question];
    
    XCTAssertEqual([mockCommunicator questionIDItFetched], question.questionID);
}

- (void)testManagerWhenSearchForQuestionBodyCausesErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    NSError *errorFromCommunicator = [self createFakeError];
    
    [mgr fetchBodyForQuestionWithIDFailedWithError:errorFromCommunicator];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNotNil(errorFromManager);
    XCTAssertNotEqualObjects(errorFromManager, errorFromCommunicator);
}

- (void)testManagerWhenSearchForQuestionBodyCausesErrorNotifiesDelegateWithErrorContainingUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    NSError *errorFromCommunicator = [self createFakeError];
    
    [mgr fetchBodyForQuestionWithIDFailedWithError:errorFromCommunicator];
    
    NSError *underlyingError = [[[mockDelegate fetchError] userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertEqualObjects(underlyingError, errorFromCommunicator);
}

- (void)testManagerWhenFetchingQuestionBodyReturnsJSONResponseSendsResponseToQuestionBuilder
{
    mgr = [self createStackOverflowManager];
    MockQuestionBuilder *mockQuestionBuilder = [[MockQuestionBuilder alloc] init];
    mgr.questionBuilder = mockQuestionBuilder;
    Question *question = [[Question alloc] init];
    
    [mgr fetchBodyForQuestionWithID:question.questionID
                      didReturnJSON:@"some JSON"];
    
    XCTAssertEqualObjects(mockQuestionBuilder.receivedJSON, @"some JSON");
}

- (void)testManagerWhenFetchingQuestionBodyReturnsJSONResponseSendsResponseForCorrectQuestionToQuestionBuilder
{
    mgr = [self createStackOverflowManager];
    MockQuestionBuilder *mockQuestionBuilder = [[MockQuestionBuilder alloc] init];
    mgr.questionBuilder = mockQuestionBuilder;
    Question *question = [[Question alloc] init];
    question.questionID = 12345;
    
    [mgr fetchBodyForQuestion:question];
    [mgr fetchBodyForQuestionWithID:question.questionID
                      didReturnJSON:@"some JSON"];
    
    XCTAssertEqualObjects(mockQuestionBuilder.receivedQuestion, question);
}

- (void)testManagerWhenBuildingQuestionBodyIsSuccessfulSendsQuestionToDelegate
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    MockQuestionBuilder *stubQuestionBuilder = [[MockQuestionBuilder alloc] init];
    stubQuestionBuilder.successToReturn = YES;
    mgr.questionBuilder = stubQuestionBuilder;
    Question *question = [[Question alloc] init];
    
    [mgr fetchBodyForQuestion:question];
    [mgr fetchBodyForQuestionWithID:question.questionID
                      didReturnJSON:@"some JSON"];
    
    XCTAssertEqualObjects([mockDelegate receivedQuestion], question);
}

- (void)testManagerWhenBuildingQuestionBodyCausesErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    MockQuestionBuilder *stubQuestionBuilder = [[MockQuestionBuilder alloc] init];
    stubQuestionBuilder.successToReturn = NO;
    NSError *errorFromQuestionBuilder = [self createFakeError];
    stubQuestionBuilder.errorToSet = errorFromQuestionBuilder;
    mgr.questionBuilder = stubQuestionBuilder;
    Question *question = [[Question alloc] init];
    
    [mgr fetchBodyForQuestionWithID:question.questionID
                      didReturnJSON:@"some JSON that causes error"];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNotNil(errorFromManager);
    XCTAssertNotEqualObjects(errorFromManager, errorFromQuestionBuilder);
}

- (void)testManagerWhenBuildingQuestionBodyCausesErrorNotifiesDelegateWithErrorContainingUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    MockQuestionBuilder *stubQuestionBuilder = [[MockQuestionBuilder alloc] init];
    stubQuestionBuilder.successToReturn = NO;
    NSError *errorFromQuestionBuilder = [self createFakeError];
    stubQuestionBuilder.errorToSet = errorFromQuestionBuilder;
    mgr.questionBuilder = stubQuestionBuilder;
    Question *question = [[Question alloc] init];
    
    [mgr fetchBodyForQuestionWithID:question.questionID
                      didReturnJSON:@"some JSON that causes error"];
    
    NSError *underlyingError = [[[mockDelegate fetchError] userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertEqualObjects(underlyingError, errorFromQuestionBuilder);
}

@end
