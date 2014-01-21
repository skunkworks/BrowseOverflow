//
//  TopicTableDataSource.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/17/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "TopicTableDataSource.h"

@implementation TopicTableDataSource

NSString *const TopicTableDidSelectTopicNotification = @"TopicTableDidSelectTopicNotification";
NSString *const topicCellReuseIdentifier = @"TopicCell";

- (void)setTopics:(NSArray *)topics
{
    _topics = topics;
}

- (Topic *)topicAtIndexPath:(NSIndexPath *)indexPath
{
    return _topics[indexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(section == 0);
    return [_topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath.section == 0);
    NSParameterAssert(indexPath.row < [_topics count]);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:topicCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:topicCellReuseIdentifier];
    }
    
    Topic *topic = [self topicAtIndexPath:indexPath];
    cell.textLabel.text = topic.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TopicTableDidSelectTopicNotification
                                                        object:[self topicAtIndexPath:indexPath]];
}

@end
