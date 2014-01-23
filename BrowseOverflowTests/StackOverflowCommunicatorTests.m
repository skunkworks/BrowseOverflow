//
//  StackOverflowCommunicatorTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//
//  Note: The tests for StackOverflowCommunicator are intended to verify its interaction with NSURLConnection and
//  its behavior in response to it (i.e. that it notifies its delegate with various responses). There are a few
//  different public methods that fetch questions, question body, answers, etc., but the book has chosen not to verify
//  behavior for each method. This is because we have knowledge that these methods for the most part use the same
//  plumbing to make calls to NSURLConnection, and also because we can drive tests for these methods from the
//  class that actually uses the StackOverflowCommunicator, i.e. the facade class StackOverflowManager. I think the
//  reasoning is that if you're building a facade class, you might as well have that facade class drive the bulk of
//  the functionality tests. I think this is because the actual functionality is done behind the scenes in other classes,
//  and the facade is chiefly responsible for coordinating other objects it's composed of. All we really care about is
//  that the facade class returns what the client asked for, not that a behind-the-scenes player like
//  StackOverflowCommunicator does something.

#import <XCTest/XCTest.h>
#import "FakeStackOverflowManager.h"
#import "InspectableStackOverflowCommunicator.h"
#import "NoNetworkStackOverflowCommunicator.h"
#import "FakeURLResponse.h"

@interface StackOverflowCommunicatorTests : XCTestCase

@end

@implementation StackOverflowCommunicatorTests

#pragma mark - Delegate property tests

- (void)testDelegateWhenSetToNonConformingObjectThrows
{
    StackOverflowCommunicator *communicator = [[StackOverflowCommunicator alloc] init];
    
    id nonconformingObj = [NSNull null];
    
    XCTAssertThrows(communicator.delegate = nonconformingObj);
}

- (void)testDelegateWhenSetToNilDoesntThrow
{
    StackOverflowCommunicator *communicator = [[StackOverflowCommunicator alloc] init];
    
    XCTAssertNoThrow(communicator.delegate = nil);
}

- (void)testDelegateWhenSetToConformingObjectDoesntThrow
{
    StackOverflowCommunicator *communicator = [[StackOverflowCommunicator alloc] init];
    
    id conformingObj = [[FakeStackOverflowManager alloc] init];
    
    XCTAssertNoThrow(communicator.delegate = conformingObj);
}

#pragma mark - API endpoint tests

// Note: the following tests check that the communicator uses the correct RESTful API endpoint URI.
// It's a bit of trickery, however, as all we've done is provide a way to peek inside the
// communicator object by subclassing the communicator class and providing a public method to
// access the URL.
//
// We use the same method to check that the communicator creates an NSURLConnection.
//
// IMO, this "works" but isn't wholly satisfying because you're testing some internal state of the
// object that isn't testable through its public interface. The question is really, what should we
// be testing? For example, when you fetch questions with tag, we are really testing for the
// communicator and its interaction with NSURLConnection. Okay, it created an NSURLConnection, but
// did it create it *correctly*? At the moment, these tests only verify that the URL is set correctly
// and that an NSURLConnection exists, but they don't verify much else about how that interaction
// occurred.

- (void)testFetchQuestionsWithTagWhenCalledUsesCorrectAPIEndpoint
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchQuestionsWithTag:@"sometag"];
    
    NSString *fetchingURLString = [[communicator fetchingURL] absoluteString];
    NSString *expectedURLString = [NSString stringWithFormat:@"http://api.stackexchange.com/2.1/search?pagesize=20&order=desc&sort=activity&site=stackoverflow&tagged=sometag"];
    XCTAssertEqualObjects(fetchingURLString, expectedURLString);
}

- (void)testFetchBodyForQuestionWithIDWhenCalledUsesCorrectAPIEndpoint
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchBodyForQuestionWithID:12345];
    
    NSString *fetchingURLString = [[communicator fetchingURL] absoluteString];
    NSString *expectedURLString = @"http://api.stackexchange.com/2.1/questions/12345?site=stackoverflow&filter=!9f*CwKRWa";
    XCTAssertEqualObjects(fetchingURLString, expectedURLString);
}

- (void)testDownloadInformationForQuestionWithIDWhenCalledUsesCorrectAPIEndpoint
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchInformationForQuestionWithID:12345];
    
    NSString *fetchingURLString = [[communicator fetchingURL] absoluteString];
    NSString *expectedURLString = @"http://api.stackexchange.com/2.1/questions/12345?order=desc&sort=activity&site=stackoverflow";
    XCTAssertEqualObjects(fetchingURLString, expectedURLString);
}

- (void)testDownloadAnswersToQuestionWithIDWhenCalledUsesCorrectAPIEndpoint
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchAnswersToQuestionWithID:12345];
    
    NSString *fetchingURLString = [[communicator fetchingURL] absoluteString];
    NSString *expectedURLString = @"http://api.stackexchange.com/2.1/questions/12345/answers?order=desc&sort=activity&site=stackoverflow&filter=!-.AG)tkYKcl.";
    XCTAssertEqualObjects(fetchingURLString, expectedURLString);
}

#pragma mark - NSURLConnection interaction tests

- (void)testFetchQuestionsWithTagWhenCalledCreatesConnection
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchQuestionsWithTag:@"sometag"];
    
    XCTAssertNotNil([communicator currentURLConnection]);
    // Clean up URL connection -- necessary to avoid retain cycle since NSURLConnection retains its delegate
    [communicator cancelAndDiscardCurrentURLConnection];
}

- (void)testFetchBodyForQuestionWithIDWhenCalledCreatesConnection
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchBodyForQuestionWithID:12345];
    
    XCTAssertNotNil([communicator currentURLConnection]);
    [communicator cancelAndDiscardCurrentURLConnection];
}

- (void)testDownloadInformationForQuestionWithIDWhenCalledCreatesConnection
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchInformationForQuestionWithID:12345];
    
    XCTAssertNotNil([communicator currentURLConnection]);
    [communicator cancelAndDiscardCurrentURLConnection];
}

- (void)testDownloadAnswersToQuestionWithIDWhenCalledCreatesConnection
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchAnswersToQuestionWithID:12345];
    
    XCTAssertNotNil([communicator currentURLConnection]);
    [communicator cancelAndDiscardCurrentURLConnection];
}

// Scenarios where communicator is interrupted by new request
- (void)testInitiatingNewRequestWhenCommunicatorIsStillFulfillingOldRequestReplacesConnection
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    [communicator fetchAnswersToQuestionWithID:12345];
    NSURLConnection *oldConnection = [communicator currentURLConnection];
    
    [communicator fetchAnswersToQuestionWithID:54321];
    NSURLConnection *newConnection = [communicator currentURLConnection];
    
    XCTAssertNotNil(newConnection);
    XCTAssertNotEqualObjects(oldConnection, newConnection);
    [communicator cancelAndDiscardCurrentURLConnection];
}

- (void)testInitiatingNewRequestWhenCommunicatorIsStillFulfillingOldRequestDiscardsExistingData
{
    // Note: NoNetworkStackOverflowCommunicator is a test-only subclass that we use to stub
    // out NSURLConnection. This is necessary to write an isolated test for the behavior of the
    // communicator class from that of its NSURLConnection dependency.
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    [communicator fetchAnswersToQuestionWithID:12345];
    NSData *existingData = [@"some data" dataUsingEncoding:NSUTF8StringEncoding];
    communicator.receivedData = existingData;
    
    [communicator fetchAnswersToQuestionWithID:54321];
    
    XCTAssertEqual([communicator.receivedData length], (NSUInteger)0);
}

#pragma mark - Communicator delegate notification tests

- (void)testReceivingResponseWhenResponseHas404StatusNotifiesDelegateWithError
{
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    FakeStackOverflowManager *mockDelegate = [[FakeStackOverflowManager alloc] init];
    communicator.delegate = mockDelegate;
    FakeURLResponse *stub404Response = [[FakeURLResponse alloc] initWithStatusCode:404];
    
    [communicator fetchQuestionsWithTag:@"sometag"];
    [communicator connection:nil didReceiveResponse:(NSURLResponse *)stub404Response];
    
    XCTAssertEqual([mockDelegate topicFailureErrorCode], 404);
}

- (void)testReceivingResponseWhenResponseHas200StatusDoesNotNotifyDelegateWithError
{
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    FakeStackOverflowManager *mockDelegate = [[FakeStackOverflowManager alloc] init];
    communicator.delegate = mockDelegate;
    FakeURLResponse *stub200Response = [[FakeURLResponse alloc] initWithStatusCode:200];
    
    [communicator fetchQuestionsWithTag:@"sometag"];
    [communicator connection:nil didReceiveResponse:(NSURLResponse *)stub200Response];
    
    XCTAssertNotEqual([mockDelegate topicFailureErrorCode], 200);
}

- (void)testConnectionErrorWhenItOccursNotifiesDelegateWithSameError
{
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    FakeStackOverflowManager *mockDelegate = [[FakeStackOverflowManager alloc] init];
    communicator.delegate = mockDelegate;
    NSError *fakeError = [NSError errorWithDomain:@"Fake domain" code:12345 userInfo:nil];
    
    [communicator fetchQuestionsWithTag:@"sometag"];
    [communicator connection:nil didFailWithError:fakeError];
    
    XCTAssertEqual([mockDelegate topicFailureErrorCode], 12345);
}

- (void)testCommunicatorWhenRequestFinishesSendsRequestDataToDelegate
{
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    FakeStackOverflowManager *mockDelegate = [[FakeStackOverflowManager alloc] init];
    communicator.delegate = mockDelegate;
    
    [communicator fetchQuestionsWithTag:@"sometag"];
    [communicator connection:nil didReceiveData:[@"abcde" dataUsingEncoding:NSUTF8StringEncoding]];
    [communicator connection:nil didReceiveData:[@"fghij" dataUsingEncoding:NSUTF8StringEncoding]];
    [communicator connectionDidFinishLoading:nil];
    
    NSString *receivedJSON = [mockDelegate receivedJSON];
    XCTAssertEqualObjects(receivedJSON, @"abcdefghij");
}

@end
