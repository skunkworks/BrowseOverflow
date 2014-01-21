//
//  QuestionListTableDataSource.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "QuestionListTableDataSource.h"

@interface QuestionListTableDataSource ()
@end

@implementation QuestionListTableDataSource

NSString *const QuestionListTableDidSelectQuestionNotification = @"QuestionListTableDidSelectQuestionNotification";

- (AvatarStore *)avatarStore {
    if (!_avatarStore) {
        _avatarStore = [[AvatarStore alloc] init];
    }
    return _avatarStore;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger questionCount = [[self.topic recentQuestions] count];
    return questionCount == 0 ? 1 : questionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.topic recentQuestions] count] == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeholder"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"placeholder"];
        }
        cell.textLabel.text = @"Failed to connect to network";
        return cell;
    }
    
    QuestionSummaryCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QuestionSummaryCell"];
    if (!questionCell) {
        // Load cell from nib
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"QuestionSummaryCell"
                                                      owner:nil
                                                    options:nil];
        questionCell = (QuestionSummaryCell *)objs[0];
    }

    Question *question = [self questionForCellAtIndexPath:indexPath];
    questionCell.titleLabel.text = question.title;
    questionCell.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)question.score];
    questionCell.personNameLabel.text = question.asker.name;
    // Have to clear out out avatar, since cells are reused and it could have someone else's avatar set.
    questionCell.avatarView.image = nil;
    
    [self loadCell:questionCell withAvatarFromLocation:[question.asker.avatarURL absoluteString]];
    
    return questionCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Question *question = [self questionForCellAtIndexPath:indexPath];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:QuestionListTableDidSelectQuestionNotification
                      object:question];
}

#pragma mark - Private methods

- (void)loadCell:(QuestionSummaryCell *)cell withAvatarFromLocation:(NSString *)avatarLocation
{
    NSData *avatarImageData = [self.avatarStore dataForLocation:avatarLocation];
    
    // If the Avatar Store already has the image, set the thumbnail.
    if (avatarImageData) {
        cell.avatarView.image = [UIImage imageWithData:avatarImageData];
    } else {
        // Avatar Store doesn't have this thumbnail. Initiate a fetch request to have it set the avatar
        // once it's been retrieved.
        [self.avatarStore fetchDataForLocation:avatarLocation
                                  onCompletion:^(NSData *data) {
                                      UIImage *avatarImage = [UIImage imageWithData:data];
                                      cell.avatarView.image = avatarImage;
                                  }];
    }
}

- (Question *)questionForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.topic recentQuestions][indexPath.row];
}

@end
