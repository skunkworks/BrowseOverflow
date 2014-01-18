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

- (NSComparisonResult)compare:(Answer *)otherAnswer;

@end
