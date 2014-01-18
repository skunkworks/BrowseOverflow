//
//  Topic.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"

@interface Topic : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *tag;

- (id)initWithName:(NSString *)name tag:(NSString *)tag;
- (NSArray *)recentQuestions;
- (void)addQuestion:(Question *)question;

@end
