//
//  Person.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *avatarURL;

- (id)initWithName:(NSString *)name
         avatarURL:(NSURL *)url;

@end
