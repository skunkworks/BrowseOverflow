//
//  QuestionDetailTableDataSource.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/20/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"
#import "AvatarStore.h"

@interface QuestionDetailTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Question *question;
@property (nonatomic, strong) AvatarStore *avatarStore;

@end
