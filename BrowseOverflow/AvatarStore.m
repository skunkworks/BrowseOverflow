//
//  AvatarStore.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/18/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "AvatarStore.h"

@interface AvatarStore ()
@property (nonatomic, strong) NSMutableDictionary *avatarDictionary;
@end

@implementation AvatarStore

- (NSMutableDictionary *)avatarDictionary {
    if (!_avatarDictionary) _avatarDictionary = [NSMutableDictionary dictionary];
    return _avatarDictionary;
}

- (void)setData:(NSData *)data forLocation:(NSString *)location
{
    [self.avatarDictionary setObject:data forKey:location];
}

- (NSData *)dataForLocation:(NSString *)location
{
    return [self.avatarDictionary objectForKey:location];
}

- (void)fetchDataForLocation:(NSString *)location
                onCompletion:(void (^)(NSData *))completionHandler
{
    NSURL *url = [NSURL URLWithString:location];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               if (httpResponse.statusCode == 200) {
                                   completionHandler(data);
                               }
                           }];
}

@end
