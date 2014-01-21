//
//  BrowseOverflowViewController.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/16/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseOverflowConfiguration.h"

@interface BrowseOverflowViewController : UIViewController <StackOverflowManagerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) BrowseOverflowConfiguration *configuration;

// Strong pointer because it's the delegate and data source for the table view, not this class
@property (nonatomic, strong) id<UITableViewDataSource, UITableViewDelegate> tableViewDataSource;

- (void)userDidSelectTopicNotification:(NSNotification *)notification;

@end
