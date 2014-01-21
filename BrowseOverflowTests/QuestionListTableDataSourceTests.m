//
//  QuestionListTableDataSourceTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QuestionListTableDataSource.h"
#import "FakeAvatarStore.h"
#import "FakeUITableView.h"

@interface QuestionListTableDataSourceTests : XCTestCase
{
    QuestionListTableDataSource *dataSource;
}
@end

@implementation QuestionListTableDataSourceTests

#pragma mark - Utility helper methods

- (QuestionListTableDataSource *)createDataSource {
    return [[QuestionListTableDataSource alloc] init];
}

- (Topic *)createTopic {
    return [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];
}

#pragma mark - Property tests

- (void)testItHasATopicProperty
{
    dataSource = [self createDataSource];
    Topic *topic = [[Topic alloc] initWithName:@"Sample" tag:@"sample"];
    
    dataSource.topic = topic;
    
    XCTAssertEqualObjects(dataSource.topic, topic);
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

- (void)testNumberOfRowsWhenItHasOneQuestionReturnsOne
{
    dataSource = [self createDataSource];
    Topic *topic = [self createTopic];
    dataSource.topic = topic;
    Question *question = [[Question alloc] init];
    [topic addQuestion:question];
    
    NSInteger numberOfRows = [dataSource tableView:nil numberOfRowsInSection:0];
    
    XCTAssertEqual(numberOfRows, 1);
}

- (void)testNumberOfRowsWhenItHasTwoQuestionsReturnsTwo
{
    dataSource = [self createDataSource];
    Topic *topic = [self createTopic];
    dataSource.topic = topic;
    Question *question = [[Question alloc] init];
    Question *anotherQuestion = [[Question alloc] init];
    [topic addQuestion:question];
    [topic addQuestion:anotherQuestion];
    
    NSInteger numberOfRows = [dataSource tableView:nil numberOfRowsInSection:0];
    
    XCTAssertEqual(numberOfRows, 2);
}

- (void)testCellForRowWhenNoQuestionsReturnsCellWithPlaceholderMessageForFirstRow
{
    dataSource = [self createDataSource];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell *cell = [dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    NSRange range = [cell.textLabel.text rangeOfString:@"Failed to connect to network"];
    XCTAssertNotNil(cell.textLabel.text);
    XCTAssertTrue(range.location != NSNotFound);
}

- (void)testCellForRowWhenItHasQuestionsReturnsCellWithoutPlaceholderMessage
{
    dataSource = [self createDataSource];
    Topic *topic = [self createTopic];
    dataSource.topic = topic;
    Question *question = [[Question alloc] init];
    [topic addQuestion:question];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell *cell = [dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertTrue([cell isKindOfClass:[QuestionSummaryCell class]]);
    XCTAssertNil(cell.textLabel.text);
}

- (void)testCellForRowWhenItHasQuestionsReturnsCellConfiguredWithQuestionProperties
{
    dataSource = [self createDataSource];
    Topic *topic = [self createTopic];
    dataSource.topic = topic;
    Question *question = [[Question alloc] init];
    question.title = @"Test question title";
    question.score = 42;
    question.asker = [[Person alloc] initWithName:@"Richard Shin" avatarURL:nil];
    [topic addQuestion:question];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    
    QuestionSummaryCell *questionCell = (QuestionSummaryCell *)[dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertEqualObjects(questionCell.titleLabel.text, @"Test question title");
    XCTAssertEqualObjects(questionCell.personNameLabel.text, @"Richard Shin");
    XCTAssertEqualObjects(questionCell.scoreLabel.text, @"42");
}

#pragma mark - AvatarStore interaction tests

// Scenario: QuestionListDataSource returns a cell for a question where the AvatarStore already has an avatar
// cached in it.
- (void)testCellForRowWhenAvatarStoreHasCachedAvatarSetsImageForCell
{
    dataSource = [self createDataSource];
    Topic *topic = [self createTopic];
    dataSource.topic = topic;
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
    // Set up question with an asker whose avatar URL matches the one we just inserted into the avatar store
    Question *question = [[Question alloc] init];
    Person *asker = [[Person alloc] initWithName:@"Richard Shin"
                                       avatarURL:realAvatarURL];
    [question setAsker:asker];
    [topic addQuestion:question];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    QuestionSummaryCell *cell = (QuestionSummaryCell *)[dataSource tableView:nil
                                                       cellForRowAtIndexPath:ip];
    
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
    Topic *topic = [self createTopic];
    dataSource.topic = topic;
    FakeAvatarStore *mockAvatarStore = [[FakeAvatarStore alloc] init];
    dataSource.avatarStore = mockAvatarStore;
    Question *question = [[Question alloc] init];
    NSURL *realAvatarURL = [NSURL URLWithString:@"http://www.gravatar.com/avatar/4576585a7a1eaa2edc8445ac71f3c55d"];
    Person *asker = [[Person alloc] initWithName:@"Richard Shin"
                                       avatarURL:realAvatarURL];
    [question setAsker:asker];
    [topic addQuestion:question];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertTrue([mockAvatarStore wasAskedToFetchDataForLocation:[realAvatarURL absoluteString]]);
}

// Scenario: When the AvatarStore successfully fetches data from the requested URL, it should have been handed a
// completion handler block that sets the avatarView in the cell. Verify that that's the case (i.e. stub the
// AvatarStore method so that it immediately executes the block and passes valid avatar data back).
- (void)testCellForRowWhenItRequestsAvatarStoreToFetchAvatarSendsACompletionBlockToSetImageForCell
{
    dataSource = [self createDataSource];
    Topic *topic = [self createTopic];
    dataSource.topic = topic;
    FakeAvatarStore *mockAvatarStore = [[FakeAvatarStore alloc] init];
    dataSource.avatarStore = mockAvatarStore;
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *testFixtureAvatarURL = [testBundle URLForResource:@"test_fixture_avatar" withExtension:@"png"];
    NSData *testFixtureAvatarData = [NSData dataWithContentsOfURL:testFixtureAvatarURL];
    [mockAvatarStore setAvatarDataReturnedByFetch:testFixtureAvatarData];
    Question *question = [[Question alloc] init];
    NSURL *realAvatarURL = [NSURL URLWithString:@"http://www.gravatar.com/avatar/4576585a7a1eaa2edc8445ac71f3c55d"];
    Person *asker = [[Person alloc] initWithName:@"Richard Shin"
                                       avatarURL:realAvatarURL];
    [question setAsker:asker];
    [topic addQuestion:question];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    QuestionSummaryCell *questionCell = (QuestionSummaryCell *)[dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertNotNil(questionCell.avatarView.image);
}
// Removed this functionality -- premature optimization
//
//- (void)testCellForRowWhenATableViewIsBeingScrolledDoesNotSendFetchRequestToAvatarStore
//{
//    dataSource = [self createDataSource];
//    Topic *topic = [self createTopic];
//    dataSource.topic = topic;
//    FakeAvatarStore *mockAvatarStore = [[FakeAvatarStore alloc] init];
//    dataSource.avatarStore = mockAvatarStore;
//    Question *question = [[Question alloc] init];
//    NSURL *realAvatarURL = [NSURL URLWithString:@"http://www.gravatar.com/avatar/4576585a7a1eaa2edc8445ac71f3c55d"];
//    Person *asker = [[Person alloc] initWithName:@"Richard Shin"
//                                       avatarURL:realAvatarURL];
//    [question setAsker:asker];
//    [topic addQuestion:question];
//    FakeUITableView *stubTableView = [[FakeUITableView alloc] init];
//    [stubTableView setIsDragging:YES];
//    
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
//    [dataSource tableView:stubTableView cellForRowAtIndexPath:ip];
//    
//    XCTAssertFalse([mockAvatarStore wasAskedToFetchDataForLocation:[realAvatarURL absoluteString]]);
//}
//
//- (void)testCellForRowWhenATableViewIsDeceleratingDoesNotSendFetchRequestToAvatarStore
//{
//    dataSource = [self createDataSource];
//    Topic *topic = [self createTopic];
//    dataSource.topic = topic;
//    FakeAvatarStore *mockAvatarStore = [[FakeAvatarStore alloc] init];
//    dataSource.avatarStore = mockAvatarStore;
//    Question *question = [[Question alloc] init];
//    NSURL *realAvatarURL = [NSURL URLWithString:@"http://www.gravatar.com/avatar/4576585a7a1eaa2edc8445ac71f3c55d"];
//    Person *asker = [[Person alloc] initWithName:@"Richard Shin"
//                                       avatarURL:realAvatarURL];
//    [question setAsker:asker];
//    [topic addQuestion:question];
//    FakeUITableView *stubTableView = [[FakeUITableView alloc] init];
//    [stubTableView setIsDecelerating:YES];
//    
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
//    [dataSource tableView:stubTableView cellForRowAtIndexPath:ip];
//    
//    XCTAssertFalse([mockAvatarStore wasAskedToFetchDataForLocation:[realAvatarURL absoluteString]]);
//}

#pragma mark - UIScrollViewDelegate methods

// This is to implement the behavior where thumbnails are loaded only for rows when table view is not moving (i.e.
// not being dragged or decelerating). Neglecting to do this causes the table view scrolling to jitter.
// TODO:

@end
