//
//  BOAppDelegate.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseOverflowViewController.h"
#import "TopicTableDataSource.h"
#import "BrowseOverflowConfiguration.h"

@interface BOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;

@end