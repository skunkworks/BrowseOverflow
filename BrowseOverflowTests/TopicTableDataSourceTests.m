//
//  TopicTableDataSourceTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/17/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TopicTableDataSource.h"
#import "Topic.h"

@interface TopicTableDataSourceTests : XCTestCase
{
    TopicTableDataSource *topicTableDataSource;
    NSNotification *receivedNotification;
}
@end

@implementation TopicTableDataSourceTests

#pragma mark - Setup and utility methods

- (TopicTableDataSource *)createDataSource {
    return [[TopicTableDataSource alloc] init];
}

- (void)startListeningForNotificationName:(NSString *)notificationName fromObject:(id)object
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(receiveNotification:)
               name:notificationName
             object:object];
}

- (void)stopListening {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveNotification:(NSNotification *)notification {
    receivedNotification = notification;
}

#pragma mark - UITableViewDataSource

- (void)testNumberOfRowsWhenItHasOneTopicReturnsOne
{
    topicTableDataSource = [self createDataSource];
    Topic *sampleTopic = [[Topic alloc] initWithName:@"sample" tag:@"sample"];
    [topicTableDataSource setTopics:@[sampleTopic]];
    
    NSInteger numberOfRows = [topicTableDataSource tableView:nil numberOfRowsInSection:0];
    XCTAssertEqual(numberOfRows, 1);
}

- (void)testNumberOfRowsWhenItHasTwoTopicsReturnsTwo
{
    topicTableDataSource = [self createDataSource];
    Topic *sampleTopic = [[Topic alloc] initWithName:@"sample" tag:@"sample"];
    Topic *anotherTopic = [[Topic alloc] initWithName:@"another" tag:@"another"];
    [topicTableDataSource setTopics:@[sampleTopic, anotherTopic]];
    
    NSInteger numberOfRows = [topicTableDataSource tableView:nil numberOfRowsInSection:0];
    XCTAssertEqual(numberOfRows, 2);
}

- (void)testNumberOfRowsWhenCalledForNonZeroSectionThrowsException
{
    topicTableDataSource = [self createDataSource];

    XCTAssertThrows([topicTableDataSource tableView:nil numberOfRowsInSection:1]);
}

- (void)testCellForRowWhenCalledForNonZeroSectionThrowsException
{
    topicTableDataSource = [self createDataSource];
    NSIndexPath *secondSectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    XCTAssertThrows([topicTableDataSource tableView:nil cellForRowAtIndexPath:secondSectionIndexPath]);
}

- (void)testCellForRowWhenCalledForNonexistentTopicThrowsException
{
    topicTableDataSource = [self createDataSource];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    XCTAssertThrows([topicTableDataSource tableView:nil cellForRowAtIndexPath:indexPath]);
}

// While writing this test and the implementation code that satisfies the test expectation, the
// book brings up salient point about presentation requirements for the cell that our code returns.
// For example, what is its reuse identifier? What is the style of the cell? We could write tests that
// specify these presentation values to be exactly what we want, or we could leave this unspecified.
// Leaving it unspecified is a tradeoff: more flexibility to change these values vs. leaving more
// responsibility to you the developer and any other devs that might work on this code later. The
// book mentions that this is a wise tradeoff, since "correct" presentation is often subjective.
//
// In addition, it's possible to write some very bad production code that still allows these tests to
// pass. You could have it create a new cell rather than reuse old cells, which makes for horrible
// memory usage. This bumps up against the scope of unit tests because it would specify memory and
// performance requirements. This is why unit tests do not guarantee good production code. It still
// requires that the developer create well-designed code that uses best practices. Satisfying unit
// test requirements is not the be-all end-all!
- (void)testCellForRowWhenCalledWithValidParametersReturnsCellWithTextLabelSetToTopicName
{
    topicTableDataSource = [self createDataSource];
    Topic *sampleTopic = [[Topic alloc] initWithName:@"sample" tag:@"sample"];
    [topicTableDataSource setTopics:@[sampleTopic]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell *cell = [topicTableDataSource tableView:nil cellForRowAtIndexPath:indexPath];
    NSString *textLabel = cell.textLabel.text;
    
    XCTAssertEqualObjects(textLabel, @"sample");
}

#pragma mark - UITableViewDelegate

// Note: I wrote this when first starting work on building out the delegate. At this point, the data
// source existed. The question was how to drive the design of the delegate.
//
// Major design roadblock: at this point in development, we've built out a rudimentary implementation
// of the data source such that it returns cells for a given topic. Now we need to build out the
// delegate. What the delegate does is handle events that occur on its table view. Specifically, when
// the user selects a topic row, we need to push onto the navigation controller another view controller
// to display a list of questions for that topic.
//
// In typically-designed UITableViewControllers, this is not a problem because the view controller is
// both the data source and the delegate *and* it's also the view controller that presents new VCs.
// When the user selects a row, it's the view controller that has didSelectRow called on it. Since it's
// also the data source, it can look up which Topic object is for that row, and then it can present the
// new view controller. See -- it's really a god class.
//
// Since we've chosen to separate out the view controller (that controls the table view) from the logic
// that handles table view events the logic that provides data to the table view, we face a new
// challenge: the table view delegate object needs to notify the view controller that a topic was
// selected, and the view controller needs to have that Topic object for that row so that it knows
// how to create the new VC and push it onto the nav stack.
//
// The book's solution is to connect the table view delegate object to the table view data source object
// so that it can do the Topic object lookup. The delegate object then notifies the view controller
// with the Topic object directly. This of course requires that the delegate object keeps a reference
// to the data source.
//
// At first glance, this is not how I would do this. What I would do is have the delegate notify the
// view controller that a row at a given index path was selected. The view controller would then
// query the data source for the Topic object at that index path. Once it had the topic, it could
// present the new VC.
//
// This approach makes more sense to me. The delegate's SINGLE RESPONSIBILITY is to manage the behavior,
// actions, and presentation of the table view. It's the object that really truly drives the how a
// table view behaves, how it looks, etc. There's a clear line drawn between a table view's presentation
// and the data that it actually presents. That's why they're broken out into two diff protocols!
//
// The book's solution is to make the delegate a client of the data source. In actuality, there shouldn't
// be any code in the delegate that has any knowledge of the data source and objects it manages. The only
// time their respective responsibilities interact is when an action on the table view requires some
// knowledge of the data source to perform custom behavior.
//
// That custom behavior should be dictated by the class that coordinates everything for the table view.
// That's the view controller.
//
// Another problem, arises: the purpose of BrowseOverflowViewController was to create a generic table
// view controller that could be reused for Topic, Question, Answer, etc. If it has to handle the model
// object itself to determine how to initialize a new VC and push it onto the stack, can we accomplish
// that without creating some dependency on that model and therefore break its generic purpose?
//
// Oh well, I'm just going to start coding. Worry & refactor this later.
//
// ...
//
// After a bit more research, it turns out that splitting the delegate and the data source makes sense
// logically, but becomes rather difficult in practice because so many of the methods in the delegate
// require access to the data source. Because one is so dependent on the other (i.e. a delegate is
// composed of a data source), and because it makes little sense to have a concrete delegate have an
// abstract data source type to allow different concrete types to be plugged in (i.e. a
// TopicTableDelegate class would *never* use a QuestionTableDataSource), it's far easier and not very
// risky to merge the two into one class.
//
// As far as the second concern -- how BrowseOverflowViewController "knows" how to handle the different
// types of notification objects it receives (e.g. Topic, Question, Answer) -- this can be solved by
// having subclasses of BrowseOverflowViewController, one for each type of notification object, that knows
// how to handle the object and what kind of VC to push onto the nav stack in response.
//

- (void)testDidSelectRowWhenCalledPostsNotificationWithSelectedTopic
{
    topicTableDataSource = [self createDataSource];
    Topic *topic = [[Topic alloc] initWithName:@"iphone" tag:@"iphone"];
    [topicTableDataSource setTopics:@[topic]];
    
    [self startListeningForNotificationName:TopicTableDidSelectTopicNotification
                                 fromObject:nil];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [topicTableDataSource tableView:nil didSelectRowAtIndexPath:indexPath];
    [self stopListening];
    
    XCTAssertEqualObjects(receivedNotification.name, TopicTableDidSelectTopicNotification);
    Topic *topicFromNotification = (Topic *)[receivedNotification object];
    XCTAssertEqualObjects(topicFromNotification, topic);
    // Cleanup
    receivedNotification = nil;
}

@end
