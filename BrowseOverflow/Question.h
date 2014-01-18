//
//  Question.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Answer.h"

@interface Question : NSObject
{
    NSMutableSet *answers;
}

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger questionID;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, strong) Person *asker;


- (NSArray *)answers;
- (void)addAnswer:(Answer *)answer;

@end
