//
//  StackOverflowCommunicatorTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MockStackOverflowCommunicatorDelegate.h"
#import "InspectableStackOverflowCommunicator.h"
#import "NoNetworkStackOverflowCommunicator.h"
#import "FakeURLResponse.h"

@interface StackOverflowCommunicatorTests : XCTestCase

@end

@implementation StackOverflowCommunicatorTests

#pragma mark - Delegate tests

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
    
    id conformingObj = [[MockStackOverflowCommunicatorDelegate alloc] init];
    
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
// be testing? For example, when you search for questions with tag, we are really testing for the
// communicator and its interaction with NSURLConnection. Okay, it created an NSURLConnection, but
// did it create it *correctly*? At the moment, these tests only verify that the URL is set correctly
// and that an NSURLConnection exists, but they don't verify much else about how that interaction
// occurred.

- (void)testSearchForQuestionsWithTagWhenCalledUsesCorrectAPIEndpoint
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator searchForQuestionsWithTag:@"sometag"];
    
    NSString *fetchingURLString = [[communicator fetchingURL] absoluteString];
    NSString *expectedURLString = [NSString stringWithFormat:@"http://api.stackexchange.com/2.1/search?pagesize=20&order=desc&sort=activity&site=stackoverflow&tagged=sometag"];
    XCTAssertEqualObjects(fetchingURLString, expectedURLString);
}

- (void)testFetchBodyForQuestionWithIDWhenCalledUsesCorrectAPIEndpoint
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator fetchBodyForQuestionWithID:12345];
    
    NSString *fetchingURLString = [[communicator fetchingURL] absoluteString];
    NSString *expectedURLString = @"http://api.stackexchange.com/2.1/questions/12345?pagesize=20&order=desc&sort=activity&site=stackoverflow&filter=!)5E5Eqicc32_BFI72Q8kQtp9Mbg9";
    XCTAssertEqualObjects(fetchingURLString, expectedURLString);
}

- (void)testDownloadInformationForQuestionWithIDWhenCalledUsesCorrectAPIEndpoint
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator downloadInformationForQuestionWithID:12345];
    
    NSString *fetchingURLString = [[communicator fetchingURL] absoluteString];
    NSString *expectedURLString = @"http://api.stackexchange.com/2.1/questions/12345?order=desc&sort=activity&site=stackoverflow";
    XCTAssertEqualObjects(fetchingURLString, expectedURLString);
}

- (void)testDownloadAnswersToQuestionWithIDWhenCalledUsesCorrectAPIEndpoint
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator downloadAnswersToQuestionWithID:12345];
    
    NSString *fetchingURLString = [[communicator fetchingURL] absoluteString];
    NSString *expectedURLString = @"http://api.stackexchange.com/2.1/questions/12345/answers?order=desc&sort=activity&site=stackoverflow";
    XCTAssertEqualObjects(fetchingURLString, expectedURLString);
}

#pragma mark - Connectivity tests

- (void)testSearchForQuestionsWithTagWhenCalledCreatesConnection
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator searchForQuestionsWithTag:@"sometag"];
    
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
    
    [communicator downloadInformationForQuestionWithID:12345];
    
    XCTAssertNotNil([communicator currentURLConnection]);
    [communicator cancelAndDiscardCurrentURLConnection];
}

- (void)testDownloadAnswersToQuestionWithIDWhenCalledCreatesConnection
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    
    [communicator downloadAnswersToQuestionWithID:12345];
    
    XCTAssertNotNil([communicator currentURLConnection]);
    [communicator cancelAndDiscardCurrentURLConnection];
}

// Scenarios where communicator is interrupted by new request

- (void)testInitiatingNewRequestWhenCommunicatorIsStillFulfillingOldRequestReplacesConnection
{
    InspectableStackOverflowCommunicator *communicator = [[InspectableStackOverflowCommunicator alloc] init];
    [communicator downloadAnswersToQuestionWithID:12345];
    NSURLConnection *oldConnection = [communicator currentURLConnection];
    
    [communicator downloadAnswersToQuestionWithID:54321];
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
    [communicator downloadAnswersToQuestionWithID:12345];
    NSData *existingData = [@"some data" dataUsingEncoding:NSUTF8StringEncoding];
    communicator.receivedData = existingData;
    
    [communicator downloadAnswersToQuestionWithID:54321];
    
    XCTAssertEqual([communicator.receivedData length], (NSUInteger)0);
}

- (void)testReceivingResponseWhenResponseHas404StatusNotifiesDelegateWithError
{
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    MockStackOverflowCommunicatorDelegate *mockDelegate = [[MockStackOverflowCommunicatorDelegate alloc] init];
    communicator.delegate = mockDelegate;
    FakeURLResponse *stub404Response = [[FakeURLResponse alloc] initWithStatusCode:404];
    
    [communicator searchForQuestionsWithTag:@"sometag"];
    [communicator connection:nil didReceiveResponse:(NSURLResponse *)stub404Response];
    
    XCTAssertEqual([mockDelegate topicFailureErrorCode], 404);
}

- (void)testReceivingResponseWhenResponseHas200StatusDoesNotNotifyDelegateWithError
{
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    MockStackOverflowCommunicatorDelegate *mockDelegate = [[MockStackOverflowCommunicatorDelegate alloc] init];
    communicator.delegate = mockDelegate;
    FakeURLResponse *stub200Response = [[FakeURLResponse alloc] initWithStatusCode:200];
    
    [communicator searchForQuestionsWithTag:@"sometag"];
    [communicator connection:nil didReceiveResponse:(NSURLResponse *)stub200Response];
    
    XCTAssertNotEqual([mockDelegate topicFailureErrorCode], 200);
}

- (void)testConnectionErrorWhenItOccursNotifiesDelegateWithSameError
{
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    MockStackOverflowCommunicatorDelegate *mockDelegate = [[MockStackOverflowCommunicatorDelegate alloc] init];
    communicator.delegate = mockDelegate;
    NSError *fakeError = [NSError errorWithDomain:@"Fake domain" code:12345 userInfo:nil];
    
    [communicator searchForQuestionsWithTag:@"sometag"];
    [communicator connection:nil didFailWithError:fakeError];
    
    XCTAssertEqual([mockDelegate topicFailureErrorCode], 12345);
}

- (void)testCommunicatorWhenRequestFinishesSendsRequestDataToDelegate
{
    NoNetworkStackOverflowCommunicator *communicator = [[NoNetworkStackOverflowCommunicator alloc] init];
    MockStackOverflowCommunicatorDelegate *mockDelegate = [[MockStackOverflowCommunicatorDelegate alloc] init];
    communicator.delegate = mockDelegate;
    
    [communicator searchForQuestionsWithTag:@"sometag"];
    [communicator connection:nil didReceiveData:[@"abcde" dataUsingEncoding:NSUTF8StringEncoding]];
    [communicator connection:nil didReceiveData:[@"fghij" dataUsingEncoding:NSUTF8StringEncoding]];
    [communicator connectionDidFinishLoading:nil];
    
    NSString *receivedJSON = [mockDelegate receivedJSON];
    XCTAssertEqualObjects(receivedJSON, @"abcdefghij");
}

@end
