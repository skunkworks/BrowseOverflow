//
//  Answer.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Answer : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSInteger score;
@property (nonatomic, strong) Person *answerer;
@property (nonatomic, getter = isAccepted) BOOL accepted;

// TODO: need to add an answer ID property and implement answer uniqueness checking in Question -addAnswer

- (NSComparisonResult)compare:(Answer *)otherAnswer;

@end
