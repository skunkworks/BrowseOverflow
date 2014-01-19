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

@end

@implementation BrowseOverflowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self.tableViewDataSource;
    self.tableView.delegate = self.tableViewDataSource;
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
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

@end
