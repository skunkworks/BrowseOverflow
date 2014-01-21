//
//  BrowseOverflowViewController.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/16/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "BrowseOverflowViewController.h"
#import "TopicTableDataSource.h"
#import "QuestionListTableDataSource.h"

@interface BrowseOverflowViewController ()
@property (nonatomic, strong) StackOverflowManager *manager;
@end

@implementation BrowseOverflowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self.tableViewDataSource;
    self.tableView.delegate = self.tableViewDataSource;
    if ([self.tableViewDataSource isKindOfClass:[QuestionListTableDataSource class]]) {
        QuestionListTableDataSource *dataSource = (QuestionListTableDataSource *)self.tableViewDataSource;
        dataSource.avatarStore = [self.configuration avatarStore];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.manager = [self.configuration createManager];
    self.manager.delegate = self;
    if ([self.tableViewDataSource isKindOfClass:[QuestionListTableDataSource class]]) {
        Topic *topic = [(QuestionListTableDataSource *)self.tableViewDataSource topic];
        [self.manager fetchQuestionsForTopic:topic];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSelectTopicNotification:) name:TopicTableDidSelectTopicNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userDidSelectTopicNotification:(NSNotification *)notification {
    BrowseOverflowViewController *viewController = [[BrowseOverflowViewController alloc] init];
    QuestionListTableDataSource *questionListDataSource = [[QuestionListTableDataSource alloc] init];
    questionListDataSource.topic = (Topic *)notification.object;
    viewController.tableViewDataSource = questionListDataSource;
    viewController.configuration = self.configuration;
    viewController.title = [NSString stringWithFormat:@"%@ Questions", questionListDataSource.topic.name];
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

#pragma mark - StackOverflowManagerDelegate


- (void)fetchQuestionsForTopicFailedWithError:(NSError *)error
{
    
}

- (void)didReceiveQuestions:(NSArray *)questions
{
    Topic *topic = ((QuestionListTableDataSource *)self.tableViewDataSource).topic;
    for (Question *question in questions) {
        [topic addQuestion:question];
    }
    [self.tableView reloadData];
}

- (void)fetchBodyForQuestionFailedWithError:(NSError *)error
{
    
}

- (void)didReceiveQuestionBodyForQuestion:(Question *)question
{
    
}

- (void)fetchAnswersForQuestionFailedWithError:(NSError *)error
{
    
}

- (void)didReceiveAnswers:(NSArray *)answers
{
    
}

@end
