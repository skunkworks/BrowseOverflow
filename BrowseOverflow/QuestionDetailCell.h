//
//  QuestionDetailCell.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/20/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *askerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@end
