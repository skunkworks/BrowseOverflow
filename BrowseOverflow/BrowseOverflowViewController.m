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
#import "QuestionDetailTableDataSource.h"

@interface BrowseOverflowViewController ()
@property (nonatomic, strong) StackOverflowManager *manager;
@end

@implementation BrowseOverflowViewController

#pragma mark - View controller lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self.tableViewDataSource;
    self.tableView.delegate = self.tableViewDataSource;
    if ([self.tableViewDataSource isKindOfClass:[QuestionListTableDataSource class]]) {
        QuestionListTableDataSource *dataSource = (QuestionListTableDataSource *)self.tableViewDataSource;
        dataSource.avatarStore = [self.configuration avatarStore];
    } else if ([self.tableViewDataSource isKindOfClass:[QuestionDetailTableDataSource class]]) {
        QuestionDetailTableDataSource *dataSource = (QuestionDetailTableDataSource *)self.tableViewDataSource;
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
    } else if ([self.tableViewDataSource isKindOfClass:[QuestionDetailTableDataSource class]]) {
        Question *question = [(QuestionDetailTableDataSource *)self.tableViewDataSource question];
        [self.manager fetchBodyForQuestion:question];
        [self.manager fetchAnswersForQuestion:question];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSelectTopicNotification:) name:TopicTableDidSelectTopicNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSelectQuestionNotification:) name:QuestionListTableDidSelectQuestionNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public methods

- (void)userDidSelectTopicNotification:(NSNotification *)notification
{
    BrowseOverflowViewController *viewController = [[BrowseOverflowViewController alloc] init];
    QuestionListTableDataSource *questionListDataSource = [[QuestionListTableDataSource alloc] init];
    questionListDataSource.topic = (Topic *)notification.object;
    viewController.tableViewDataSource = questionListDataSource;
    viewController.configuration = self.configuration;
    viewController.title = [NSString stringWithFormat:@"%@ Questions", questionListDataSource.topic.name];
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

- (void)userDidSelectQuestionNotification:(NSNotification *)notification
{
    BrowseOverflowViewController *viewController = [[BrowseOverflowViewController alloc] init];
    Question *question = (Question *)notification.object;
    QuestionDetailTableDataSource *dataSource = [[QuestionDetailTableDataSource alloc] init];
    dataSource.question = question;
    viewController.tableViewDataSource = dataSource;
    viewController.configuration = self.configuration;
    viewController.title = [NSString stringWithFormat:@"Question %ld", (long)question.questionID];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - StackOverflowManagerDelegate


- (void)fetchQuestionsForTopicFailedWithError:(NSError *)error
{
    // TODO: is there a good way to handle errors?
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
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)fetchAnswersForQuestionFailedWithError:(NSError *)error
{
    
}

- (void)didReceiveAnswers:(NSArray *)answers
{
    Question *question = ((QuestionDetailTableDataSource *)self.tableViewDataSource).question;
    for (Answer *answer in answers) {
        [question addAnswer:answer];
    }
    [self.tableView reloadData];
}

@end
