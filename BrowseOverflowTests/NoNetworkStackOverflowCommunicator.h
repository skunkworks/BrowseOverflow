//
//  NoNetworkStackOverflowCommunicator.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "StackOverflowCommunicator.h"

@interface NoNetworkStackOverflowCommunicator : StackOverflowCommunicator

@property (nonatomic, strong) NSData *receivedData;

@end
