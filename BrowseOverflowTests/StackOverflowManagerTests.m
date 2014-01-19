//
//  StackOverflowManagerTests
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StackOverflowManager.h"
#import "MockStackOverflowManagerDelegate.h"
#import "MockStackOverflowCommunicator.h"
#import "FakeQuestionBuilder.h"
#import "FakeAnswerBuilder.h"

@interface StackOverflowManagerTests : XCTestCase
{
    StackOverflowManager *mgr;
}

@end

@implementation StackOverflowManagerTests

#pragma mark - Helper utility methods

- (StackOverflowManager *)createStackOverflowManager {
    return [[StackOverflowManager alloc] init];
}

- (NSError *)createFakeError {
    return [NSError errorWithDomain:@"Test domain"
                               code:0
                           userInfo:nil];
}

- (FakeQuestionBuilder *)createFakeQuestionBuilder {
    PersonBuilder *personBuilder = [[PersonBuilder alloc] init];
    return [[FakeQuestionBuilder alloc] initWithPersonBuilder:personBuilder];
}

- (FakeAnswerBuilder *)createFakeAnswerBuilder {
    PersonBuilder *personBuilder = [[PersonBuilder alloc] init];
    return [[FakeAnswerBuilder alloc] initWithPersonBuilder:personBuilder];
}

#pragma mark - Delegate property tests

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

// Because StackOverflowManager is a facade class, we test not only that it returns the correct response to its
// delegate when public methods are called, but that its behavior with its composed classes (the builder classes,
// the communicator class) is as expected.
//
// This seems strange to test because the client of StackOverflowManager doesn't care that the manager is really a
// facade and that the heavy lifting is done by other classes. However, because the manager's behavior is ultimately
// made up by a hierarchy of objects, the "unit" in these unit tests is not StackOverflowManager as much as it is the
// sum of StackOverflowManager and the classes that compose it. Therefore, it is appropriate to define and specify
// how the manager interacts with these objects.
//
// That does not eliminate the need for unit tests on the composed classes (builders, communicator). Those are still
// necessary to provide coverage. Without them, we would have to rely on the manager unit tests acting as a sort of
// black-box integration test.
//
// For further elaboration, see note in StackOverflowCommunicatorTests.
#pragma mark - Facade method tests:
#pragma mark Fetching questions

- (void)testFetchQuestionsForTopicWhenCalledFetchesQuestionsWithCommunicator
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowCommunicator *mockCommunicator = [[MockStackOverflowCommunicator alloc] init];
    mgr.communicator = mockCommunicator;
    Topic *topic = [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];
    
    [mgr fetchQuestionsForTopic:topic];
    
    XCTAssertTrue([mockCommunicator wasAskedToFetchQuestions]);
}

- (void)testFetchQuestionsForTopicWhenCalledFetchesQuestionsForCorrectTopic
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowCommunicator *mockCommunicator = [[MockStackOverflowCommunicator alloc] init];
    mgr.communicator = mockCommunicator;
    Topic *topic = [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];
    
    [mgr fetchQuestionsForTopic:topic];
    
    XCTAssertEqual([mockCommunicator tagItFetched], @"iphone");
}

// Verify that when the manager receives an error fetching questions from the communicator
// that it in turn reports its own error (at its abstraction level) back to its delegate.
- (void)testFetchingQuestionsWhenCommunicatorHasErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    NSError *errorFromCommunicator = [self createFakeError];
    
    // -searchingForQuestionsFailedWithError: is a method implemented by the communicator's delegate
    // when an attempt to search for questions fails.
    [mgr fetchQuestionsFailedWithError:errorFromCommunicator];
    
    // -fetchError is a mock-only property that stores the error that the manager mock delegate receives
    // from the manager.
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNotEqualObjects(errorFromManager, errorFromCommunicator);
}

- (void)testFetchingQuestionsWhenCommunicatorHasErrorNotifiesDelegateWithUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    
    NSError *errorFromCommunicator = [self createFakeError];
    [mgr fetchQuestionsFailedWithError:errorFromCommunicator];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    NSError *underlyingError = [[errorFromManager userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertEqual(underlyingError, errorFromCommunicator);
}

- (void)testFetchingQuestionsWhenCommunicatorReturnsJSONResponsePassesResponseToQuestionBuilder
{
    mgr = [self createStackOverflowManager];
    FakeQuestionBuilder *mockQuestionBuilder = [self createFakeQuestionBuilder];
    mgr.questionBuilder = mockQuestionBuilder;
    
    [mgr fetchQuestionsDidReturnJSON:@"valid JSON results"];
    
    XCTAssertEqual(mockQuestionBuilder.receivedJSON, @"valid JSON results");
}

- (void)testFetchingQuestionsWhenQuestionBuilderHasErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    FakeQuestionBuilder *mockQuestionBuilder = [self createFakeQuestionBuilder];
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    NSError *errorFromQuestionBuilder = [self createFakeError];
    mockQuestionBuilder.errorToSet = errorFromQuestionBuilder;
    mockQuestionBuilder.questionsToReturn = nil;

    [mgr fetchQuestionsDidReturnJSON:@"invalid JSON results"];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNotEqualObjects(errorFromManager, errorFromQuestionBuilder);
}

- (void)testFetchingQuestionsWhenQuestionBuilderHasErrorNotifiesDelegateWithErrorContainingUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    FakeQuestionBuilder *mockQuestionBuilder = [self createFakeQuestionBuilder];
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    NSError *errorFromQuestionBuilder = [self createFakeError];
    mockQuestionBuilder.errorToSet = errorFromQuestionBuilder;
    
    [mgr fetchQuestionsDidReturnJSON:@"invalid JSON results"];
    
    NSError *underlyingError = [[[mockDelegate fetchError] userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertNotNil(underlyingError);
}

- (void)testFetchingQuestionsWhenQuestionBuilderIsSuccessfulSendsDelegateAnArrayOfQuestions
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    FakeQuestionBuilder *mockQuestionBuilder = [self createFakeQuestionBuilder];
    NSArray *questionsFromQuestionBuilder = [NSArray arrayWithObject:[[Question alloc] init]];
    mockQuestionBuilder.questionsToReturn = questionsFromQuestionBuilder;
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    
    [mgr fetchQuestionsDidReturnJSON:@"valid JSON results"];
    
    NSArray *questionsFromManager = [mockDelegate receivedQuestions];

    XCTAssertEqualObjects(questionsFromManager, questionsFromQuestionBuilder);
}

- (void)testFetchingQuestionsWhenQuestionBuilderIsSuccessfulDoesNotReportErrorToDelegate
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    FakeQuestionBuilder *mockQuestionBuilder = [self createFakeQuestionBuilder];
    mockQuestionBuilder.questionsToReturn = [NSArray arrayWithObject:[[Question alloc] init]];
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    
    [mgr fetchQuestionsDidReturnJSON:@"valid JSON results"];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNil(errorFromManager);
}

// Additional specification: if a topic legitimately has 0 questions, it should return an empty array
- (void)testFetchingQuestionsWhenQuestionBuilderReturnsNoQuestionsSendsDelegateAnEmptyArray
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    FakeQuestionBuilder *mockQuestionBuilder = [self createFakeQuestionBuilder];
    NSArray *emptyArray = [[NSArray alloc] init];
    mockQuestionBuilder.questionsToReturn = emptyArray;
    mgr.delegate = mockDelegate;
    mgr.questionBuilder = mockQuestionBuilder;
    
    [mgr fetchQuestionsDidReturnJSON:@"valid JSON results"];
    
    XCTAssertEqualObjects([mockDelegate receivedQuestions], emptyArray);
}

#pragma mark Fetching question body

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

- (void)testFetchingQuestionBodyWhenCommunicatorHasErrorNotifiesDelegateWithDifferentError
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

- (void)testFetchingQuestionBodyWhenCommunicatorHasErrorNotifiesDelegateWithErrorContainingUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    NSError *errorFromCommunicator = [self createFakeError];
    
    [mgr fetchBodyForQuestionWithIDFailedWithError:errorFromCommunicator];
    
    NSError *underlyingError = [[[mockDelegate fetchError] userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertEqualObjects(underlyingError, errorFromCommunicator);
}

- (void)testFetchingQuestionBodyWhenCommunicatorReturnsJSONResponseSendsResponseToQuestionBuilder
{
    mgr = [self createStackOverflowManager];
    FakeQuestionBuilder *mockQuestionBuilder = [self createFakeQuestionBuilder];
    mgr.questionBuilder = mockQuestionBuilder;
    Question *question = [[Question alloc] init];
    
    [mgr fetchBodyForQuestionWithID:question.questionID
                      didReturnJSON:@"some JSON"];
    
    XCTAssertEqualObjects(mockQuestionBuilder.receivedJSON, @"some JSON");
}

- (void)testFetchingQuestionBodyWhenCommunicatorReturnsJSONResponseSendsResponseForCorrectQuestionToQuestionBuilder
{
    mgr = [self createStackOverflowManager];
    FakeQuestionBuilder *mockQuestionBuilder = [self createFakeQuestionBuilder];
    mgr.questionBuilder = mockQuestionBuilder;
    Question *question = [[Question alloc] init];
    question.questionID = 12345;
    
    [mgr fetchBodyForQuestion:question];
    [mgr fetchBodyForQuestionWithID:question.questionID
                      didReturnJSON:@"some JSON"];
    
    XCTAssertEqualObjects(mockQuestionBuilder.receivedQuestion, question);
}

- (void)testFetchingQuestionBodyWhenQuestionBuilderIsSuccessfulSendsQuestionToDelegate
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    FakeQuestionBuilder *stubQuestionBuilder = [self createFakeQuestionBuilder];
    stubQuestionBuilder.successToReturn = YES;
    mgr.questionBuilder = stubQuestionBuilder;
    Question *question = [[Question alloc] init];
    
    [mgr fetchBodyForQuestion:question];
    [mgr fetchBodyForQuestionWithID:question.questionID
                      didReturnJSON:@"some JSON"];
    
    XCTAssertEqualObjects([mockDelegate receivedQuestion], question);
}

- (void)testFetchingQuestionBodyWhenQuestionBuilderHasErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    FakeQuestionBuilder *stubQuestionBuilder = [self createFakeQuestionBuilder];
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

- (void)testFetchingQuestionBodyWhenQuestionBuilderHasErrorNotifiesDelegateWithErrorContainingUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    FakeQuestionBuilder *stubQuestionBuilder = [self createFakeQuestionBuilder];
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

#pragma mark Fetching answers tests

- (void)testFetchAnswersForQuestionWhenCalledFetchesBodyWithCommunicator
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowCommunicator *mockCommunicator = [[MockStackOverflowCommunicator alloc] init];
    mgr.communicator = mockCommunicator;
    Question *question = [[Question alloc] init];
    
    [mgr fetchAnswersForQuestion:question];
    
    XCTAssertTrue([mockCommunicator wasAskedToFetchAnswers]);
}

- (void)testFetchAnswersForQuestionWhenCalledSendsTheRightQuestionIDToCommunicator
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowCommunicator *mockCommunicator = [[MockStackOverflowCommunicator alloc] init];
    mgr.communicator = mockCommunicator;
    Question *question = [[Question alloc] init];
    question.questionID = 12345;
    
    [mgr fetchAnswersForQuestion:question];
    
    XCTAssertEqual([mockCommunicator questionIDItFetched], question.questionID);
}

- (void)testFetchingAnswersWhenCommunicatorHasErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    NSError *errorFromCommunicator = [self createFakeError];
    
    [mgr fetchAnswersForQuestionWithIDFailedWithError:errorFromCommunicator];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNotNil(errorFromManager);
    XCTAssertNotEqualObjects(errorFromManager, errorFromCommunicator);
}

- (void)testFetchingAnswersWhenCommunicatorHasErrorNotifiesDelegateWithErrorContainingUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    NSError *errorFromCommunicator = [self createFakeError];
    
    [mgr fetchAnswersForQuestionWithIDFailedWithError:errorFromCommunicator];
    
    NSError *underlyingError = [[[mockDelegate fetchError] userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertEqualObjects(underlyingError, errorFromCommunicator);
}

- (void)testFetchingAnswersWhenCommunicatorReturnsJSONResponseSendsResponseToAnswerBuilder
{
    mgr = [self createStackOverflowManager];
    FakeAnswerBuilder *mockAnswerBuilder = [self createFakeAnswerBuilder];
    mgr.answerBuilder = mockAnswerBuilder;
    
    [mgr fetchAnswersForQuestionWithID:12345 didReturnJSON:@"some JSON"];
    
    XCTAssertEqualObjects(mockAnswerBuilder.receivedJSON, @"some JSON");
}

- (void)testFetchingAnswersWhenAnswerBuilderIsSuccessfulSendsAnswersToDelegate
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    FakeAnswerBuilder *stubAnswerBuilder = [self createFakeAnswerBuilder];
    mgr.answerBuilder = stubAnswerBuilder;
    NSArray *answers = @[[[Answer alloc] init]];
    [stubAnswerBuilder setAnswersToReturn:answers];
    
    [mgr fetchAnswersForQuestionWithID:12345 didReturnJSON:@"some JSON"];
    
    XCTAssertEqualObjects([mockDelegate receivedAnswers], answers);
}

- (void)testFetchingAnswersWhenAnswerBuilderHasErrorNotifiesDelegateWithDifferentError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    FakeAnswerBuilder *stubAnswerBuilder = [self createFakeAnswerBuilder];
    NSError *errorFromAnswerBuilder = [self createFakeError];
    stubAnswerBuilder.errorToSet = errorFromAnswerBuilder;
    mgr.answerBuilder = stubAnswerBuilder;
    
    [mgr fetchAnswersForQuestionWithID:12345 didReturnJSON:@"some JSON that causes error"];
    
    NSError *errorFromManager = [mockDelegate fetchError];
    XCTAssertNotNil(errorFromManager);
    XCTAssertNotEqualObjects(errorFromManager, errorFromAnswerBuilder);
}

- (void)testFetchingAnswersWhenQuestionBuilderHasErrorNotifiesDelegateWithErrorContainingUnderlyingError
{
    mgr = [self createStackOverflowManager];
    MockStackOverflowManagerDelegate *mockDelegate = [[MockStackOverflowManagerDelegate alloc] init];
    mgr.delegate = mockDelegate;
    FakeAnswerBuilder *stubAnswerBuilder = [self createFakeAnswerBuilder];
    NSError *errorFromAnswerBuilder = [self createFakeError];
    stubAnswerBuilder.errorToSet = errorFromAnswerBuilder;
    mgr.answerBuilder = stubAnswerBuilder;

    [mgr fetchAnswersForQuestionWithID:12345
                         didReturnJSON:@"some JSON that causes error"];
    
    NSError *underlyingError = [[[mockDelegate fetchError] userInfo] objectForKey:NSUnderlyingErrorKey];
    XCTAssertEqualObjects(underlyingError, errorFromAnswerBuilder);
}


@end
