//
//  AvatarStore.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvatarStore : NSObject

- (void)setData:(NSData *)data forLocation:(NSString *)urlString;
- (NSData *)dataForLocation:(NSString *)location;
- (void)fetchDataForLocation:(NSString *)location onCompletion:(void(^)(NSData *data))completionHandler;

@end
