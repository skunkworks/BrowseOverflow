//
//  QuestionListTableDataSource.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"
#import "QuestionSummaryCell.h"
#import "AvatarStore.h"

@interface QuestionListTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

// TODO: build an initWithTopic: method, and have -init throw error?

extern NSString *const QuestionListTableDidSelectQuestionNotification;

@property (nonatomic, strong) Topic *topic;
@property (nonatomic, strong) AvatarStore *avatarStore;

@end
