//
//  InspectableStackOverflowCommunicator.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/14/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "InspectableStackOverflowCommunicator.h"

@implementation InspectableStackOverflowCommunicator

- (NSURL *)fetchingURL {
    return fetchingURL;
}

- (NSURLConnection *)currentURLConnection {
    return fetchingConnection;
}

@end
