//
//  QuestionDetailTableDataSource.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/20/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "QuestionDetailTableDataSource.h"
#import "QuestionDetailCell.h"
#import "AnswerCell.h"

@implementation QuestionDetailTableDataSource

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 0) return 0;
    return [self.question.answers count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) return nil;
    
    if (indexPath.row == 0) {
        QuestionDetailCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"QuestionDetailCell"];
        if (!questionCell) {
            // Load cell from nib
            NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"QuestionDetailCell"
                                                          owner:nil
                                                        options:nil];
            questionCell = (QuestionDetailCell *)objs[0];
        }
        
        questionCell.titleLabel.text = self.question.title;
        questionCell.bodyLabel.text = self.question.body;
        questionCell.askerNameLabel.text = self.question.asker.name;
        questionCell.scoreLabel.text = [NSString stringWithFormat:@"%d", self.question.score];
        questionCell.avatarView.image = nil;
        [self loadAvatarView:questionCell.avatarView withImageFromLocation:[self.question.asker.avatarURL absoluteString]];
        
        return questionCell;
    }
    
    AnswerCell *answerCell = [tableView dequeueReusableCellWithIdentifier:@"AnswerCell"];
    if (!answerCell) {
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"AnswerCell"
                                                      owner:nil
                                                    options:nil];
        answerCell = (AnswerCell *)objs[0];
    }
    
    Answer *a = self.question.answers[indexPath.row-1];
    answerCell.textLabel.text = a.text;
    answerCell.answererNameLabel.text = a.answerer.name;
    answerCell.scoreLabel.text = [NSString stringWithFormat:@"%d", a.score];
    answerCell.acceptedLabel.text = @"✓";
    answerCell.avatarView.image = nil;
    [self loadAvatarView:answerCell.avatarView withImageFromLocation:[a.answerer.avatarURL absoluteString]];
    
    return answerCell;
}

#pragma mark - UITableViewDelegate

// Calculate height of cell dynamically by figuring out height needed to display all elements correctly
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat total = 0;
    
    if (indexPath.row == 0) {
        // Height in pixels:
        // title (?) + body (?) + image (40) + top margin (8) + bottom margin (8) + space (8) + space (8)
        QuestionDetailCell *questionCell = (QuestionDetailCell *)cell;
        total = questionCell.titleLabel.bounds.size.height + questionCell.bodyLabel.bounds.size.height +
                questionCell.imageView.bounds.size.height + 4*8;
        return total;
    }
    
    // Height in pixels:
    // text (?) + image (40) + top margin (8) + bottom margin (8) + space (8)
    AnswerCell *answerCell = (AnswerCell *)cell;
    total = answerCell.textLabel.bounds.size.height + answerCell.imageView.bounds.size.height + 3*8;
    return total;
}

#pragma mark - Private methods

- (void)loadAvatarView:(UIImageView *)avatarView withImageFromLocation:(NSString *)avatarLocation
{
    NSData *avatarImageData = [self.avatarStore dataForLocation:avatarLocation];
    
    // If the Avatar Store already has the image, set the thumbnail.
    if (avatarImageData) {
        avatarView.image = [UIImage imageWithData:avatarImageData];
    } else {
        // Avatar Store doesn't have this thumbnail. Initiate a fetch request to have it set the avatar
        // once it's been retrieved.
        [self.avatarStore fetchDataForLocation:avatarLocation
                                  onCompletion:^(NSData *data) {
                                      UIImage *avatarImage = [UIImage imageWithData:data];
                                      avatarView.image = avatarImage;
                                  }];
    }
}
@end
