//
//  PersonBuilder.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface PersonBuilder : NSObject

// Returns nil if jsonObject is nil or is missing data
- (Person *)personFromJSONObject:(id)jsonObject;

@end
