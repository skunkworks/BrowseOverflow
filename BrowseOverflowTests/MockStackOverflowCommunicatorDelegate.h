//
//  MockStackOverflowCommunicatorDelegate.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowCommunicator.h"

@interface MockStackOverflowCommunicatorDelegate : NSObject <StackOverflowCommunicatorDelegate>

@property (nonatomic) NSInteger topicFailureErrorCode;
@property (nonatomic, strong) NSString *receivedJSON;

@end
