//
//  QuestionListTableDataSource.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "QuestionListTableDataSource.h"

@interface QuestionListTableDataSource ()
@property (nonatomic, strong) NSMutableArray *questions;
@end

@implementation QuestionListTableDataSource

- (NSMutableArray *)questions {
    if (!_questions) _questions = [NSMutableArray array];
    return _questions;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger questionCount = [self.questions count];
    return questionCount == 0 ? 1 : questionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.questions count] == 0) {
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

    Question *question = self.questions[indexPath.row];
    questionCell.titleLabel.text = question.title;
    questionCell.scoreLabel.text = [NSString stringWithFormat:@"%d", question.score];
    questionCell.questionIDLabel.text = [NSString stringWithFormat:@"%d", question.questionID];
    
    NSData *avatarImageData = [self.avatarStore dataForLocation:[question.asker.avatarURL absoluteString]];
    // If the Avatar Store already has the image, set the thumbnail.
    if (avatarImageData) {
        questionCell.avatarView.image = [UIImage imageWithData:avatarImageData];
    } else {
        // Avatar Store doesn't have this thumbnail. Initiate a fetch request to have it set the avatar
        // once it's been retrieved.
        // Optimized to fetch only if the table view is not being scrolled
        if (!tableView.isDecelerating && !tableView.isDragging) {
            [self.avatarStore fetchDataForLocation:[question.asker.avatarURL absoluteString]
                                      onCompletion:^(NSData *data) {
                                          UIImage *avatarImage = [UIImage imageWithData:data];
                                          questionCell.avatarView.image = avatarImage;
                                      }];
        }
    }
    
    return questionCell;
}

- (void)addQuestion:(Question *)question
{
    [self.questions addObject:question];
}

@end
