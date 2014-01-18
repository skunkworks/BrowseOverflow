//
//  TopicTableDataSource.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/17/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"

@interface TopicTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_topics;
}

extern NSString *const TopicTableDidSelectTopicNotification;

- (void)setTopics:(NSArray *)topics;

- (Topic *)topicAtIndexPath:(NSIndexPath *)indexPath;

@end
