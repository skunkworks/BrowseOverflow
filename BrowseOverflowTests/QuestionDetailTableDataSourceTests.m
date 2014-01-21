//
//  QuestionDetailTableDataSourceTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/20/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QuestionDetailTableDataSource.h"
#import "QuestionDetailCell.h"
#import "AnswerCell.h"
#import "FakeAvatarStore.h"

@interface QuestionDetailTableDataSourceTests : XCTestCase
{
    QuestionDetailTableDataSource *dataSource;
}
@end

@implementation QuestionDetailTableDataSourceTests

#pragma mark - Utility helper methods

- (QuestionDetailTableDataSource *)createDataSource {
    return [[QuestionDetailTableDataSource alloc] init];
}

- (Question *)createQuestion {
    Question *q = [[Question alloc] init];
    q.title = @"Test question title";
    q.score = 42;
    q.body = @"Test question body";
    q.questionID = 12345;
    q.date = [NSDate distantPast];
    q.asker = [[Person alloc] initWithName:@"Richard Shin" avatarURL:nil];
    return q;
}

- (Answer *)createAnswer {
    Answer *a = [[Answer alloc] init];
    a.text = @"This is the answer text";
    a.score = 24;
    a.accepted = YES;
    a.answerer = [[Person alloc] initWithName:@"Ferris Shin"
                                    avatarURL:[NSURL URLWithString:@"http://www.gravatar.com/avatar/4576585a7a1eaa2edc8445ac71f3c55d"]];
    return a;
}

#pragma mark - Property tests

- (void)testItHasAQuestionProperty
{
    dataSource = [self createDataSource];
    
    dataSource.question = [[Question alloc] init];
    
    XCTAssertNotNil(dataSource.question);
}

- (void)testItHasAnAvatarStoreProperty
{
    dataSource = [self createDataSource];
    AvatarStore *avatarStore = [[AvatarStore alloc] init];
    
    dataSource.avatarStore = avatarStore;
    
    XCTAssertEqualObjects(dataSource.avatarStore, avatarStore);
}

#pragma mark - UITableViewDataSource tests

- (void)testNumberOfRowsWhenItHasNoQuestionsReturnsOne
{
    dataSource = [self createDataSource];
    
    NSInteger numberOfRows = [dataSource tableView:nil numberOfRowsInSection:0];
    
    XCTAssertEqual(numberOfRows, 1);
}

- (void)testNumberOfRowsWhenItHasOneAnswerReturnsTwo
{
    dataSource = [self createDataSource];
    Question *question = [self createQuestion];
    dataSource.question = question;
    Answer *answer = [self createAnswer];
    [question addAnswer:answer];
    
    NSInteger numberOfRows = [dataSource tableView:nil numberOfRowsInSection:0];
    
    XCTAssertEqual(numberOfRows, 2);
}

- (void)testNumberOfRowsWhenItHasTwoAnswersReturnsThree
{
    dataSource = [self createDataSource];
    Question *question = [self createQuestion];
    Answer *answer = [self createAnswer];
    Answer *anotherAnswer = [self createAnswer];
    [question addAnswer:answer];
    [question addAnswer:anotherAnswer];
    dataSource.question = question;
    
    NSInteger numberOfRows = [dataSource tableView:nil numberOfRowsInSection:0];
    
    XCTAssertEqual(numberOfRows, 3);
}

- (void)testCellForRowWhenCalledForQuestionRowReturnsQuestionSummaryCellSetUpWithQuestionProperties
{
    dataSource = [self createDataSource];
    Question *question = [self createQuestion];
    dataSource.question = question;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    QuestionDetailCell *questionCell = (QuestionDetailCell *)[dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertEqualObjects(questionCell.titleLabel.text, @"Test question title");
    XCTAssertEqualObjects(questionCell.bodyLabel.text, @"Test question body");
    XCTAssertEqualObjects(questionCell.askerNameLabel.text, @"Richard Shin");
    XCTAssertEqualObjects(questionCell.scoreLabel.text, @"42");
}

- (void)testCellForRowWhenCalledForAnswerRowsReturnsAnswerCellWithoutPlaceholderMessage
{
    dataSource = [self createDataSource];
    Question *question = [self createQuestion];
    Answer *answer = [self createAnswer];
    [question addAnswer:answer];
    dataSource.question = question;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:0];
    AnswerCell *answerCell = (AnswerCell *)[dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertEqualObjects(answerCell.textLabel.text, @"This is the answer text");
    XCTAssertEqualObjects(answerCell.answererNameLabel.text, @"Ferris Shin");
    XCTAssertEqualObjects(answerCell.scoreLabel.text, @"24");
    XCTAssertEqualObjects(answerCell.acceptedLabel.text, @"✓");
}

#pragma mark - UITableViewDelegate

// No behavior defined for cell selection, so no delegate methods to test!

#pragma mark - AvatarStore interaction tests

- (void)testCellForRowWhenAvatarStoreHasCachedAvatarSetsImageForCell
{
    dataSource = [self createDataSource];
    // Set up AvatarStore with an image. We fake it however by grabbing the image data
    // from a test fixture image and setting that to represent the image for the "real" URL
    AvatarStore *avatarStore = [[AvatarStore alloc] init];
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *testFixtureAvatarURL = [testBundle URLForResource:@"test_fixture_avatar" withExtension:@"png"];
    NSURL *realAvatarURL = [NSURL URLWithString:@"http://www.gravatar.com/avatar/4576585a7a1eaa2edc8445ac71f3c55d"];
    NSData *testFixtureAvatarData = [NSData dataWithContentsOfURL:testFixtureAvatarURL];
    [avatarStore setData:testFixtureAvatarData
             forLocation:[realAvatarURL absoluteString]];
    dataSource.avatarStore = avatarStore;
    Question *question = [self createQuestion];
    Answer *answer = [self createAnswer];
    [question addAnswer:answer];
    // Set up answer with an asker whose avatar URL matches the one we just inserted into the avatar store
    answer.answerer.avatarURL = realAvatarURL;
    dataSource.question = question;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:0];
    AnswerCell *cell = (AnswerCell *)[dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertNotNil(cell.avatarView.image);
}

// Scenario: QuestionListDataSource returns a cell for a question where the AvatarStore does not have an avatar
// cached in it. It should ask the AvatarStore to fetch data from a URL asynchronously.
//
// Note: the book has you use NSNotificationCenter to send a message to the data source when the avatar has been
// fetched. I think it's much cleaner to use blocks to do this. We can have the data source check to see if that
// image exists in the AvatarStore. If it doesn't, it can make a call to fetch it and do something on completion.
- (void)testCellForRowWhenAvatarStoreDoesNotHaveCachedAvatarAsksItToFetchAvatar
{
    dataSource = [self createDataSource];
    FakeAvatarStore *mockAvatarStore = [[FakeAvatarStore alloc] init];
    dataSource.avatarStore = mockAvatarStore;
    Question *question = [self createQuestion];
    Answer *answer = [self createAnswer];
    [question addAnswer:answer];
    NSURL *realAvatarURL = [NSURL URLWithString:@"http://www.gravatar.com/avatar/4576585a7a1eaa2edc8445ac71f3c55d"];
    answer.answerer.avatarURL = realAvatarURL;
    dataSource.question = question;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:0];
    [dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertTrue([mockAvatarStore wasAskedToFetchDataForLocation:[realAvatarURL absoluteString]]);
}

// Scenario: When the AvatarStore successfully fetches data from the requested URL, it should have been handed a
// completion handler block that sets the avatarView in the cell. Verify that that's the case (i.e. stub the
// AvatarStore method so that it immediately executes the block and passes valid avatar data back).
- (void)testCellForRowWhenItRequestsAvatarStoreToFetchAvatarSendsACompletionBlockToSetImageForCell
{
    dataSource = [self createDataSource];
    FakeAvatarStore *mockAvatarStore = [[FakeAvatarStore alloc] init];
    dataSource.avatarStore = mockAvatarStore;
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *testFixtureAvatarURL = [testBundle URLForResource:@"test_fixture_avatar" withExtension:@"png"];
    NSData *testFixtureAvatarData = [NSData dataWithContentsOfURL:testFixtureAvatarURL];
    [mockAvatarStore setAvatarDataReturnedByFetch:testFixtureAvatarData];
    Question *question = [self createQuestion];
    Answer *answer = [self createAnswer];
    [question addAnswer:answer];
    NSURL *realAvatarURL = [NSURL URLWithString:@"http://www.gravatar.com/avatar/4576585a7a1eaa2edc8445ac71f3c55d"];
    answer.answerer.avatarURL = realAvatarURL;
    dataSource.question = question;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:0];
    AnswerCell *cell = (AnswerCell *)[dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertNotNil(cell.avatarView.image);
}

// TODO: Should put in tests for QuestionDetailCell avatar loading
@end
