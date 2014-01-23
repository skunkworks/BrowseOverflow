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

#pragma mark - UITableViewDataSource

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

// Book makes a note that testing views can be difficult, but that this is one way to do it. However, Auto Layout
// makes it so that this doesn't test what we think it does because the cell that's returned comes straight from the
// nib file without going through auto layout processing.
//- (void)testHeightForRowForQuestionDetailCellReturnsHeightGreaterThanOrEqualToCellsHeight
//{
//    dataSource = [self createDataSource];
//    Question *question = [self createQuestion];
//    dataSource.question = question;
//    
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
//    UITableViewCell *cell = [dataSource tableView:nil cellForRowAtIndexPath:ip];
//    CGFloat height = [dataSource tableView:nil heightForRowAtIndexPath:ip];
//    
//    XCTAssertTrue(height > CGRectGetHeight(cell.frame));
//}

#pragma mark - AvatarStore interaction

- (void)testCellForRowWhenAvatarStoreHasCachedAvatarSetsImageForCell
{
    dataSource = [self createDataSource];
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
    answer.answerer.avatarURL = realAvatarURL;
    dataSource.question = question;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:0];
    AnswerCell *cell = (AnswerCell *)[dataSource tableView:nil cellForRowAtIndexPath:ip];
    
    XCTAssertNotNil(cell.avatarView.image);
}

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

@end
