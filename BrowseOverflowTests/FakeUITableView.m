//
//  FakeUITableView.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "FakeUITableView.h"

@implementation FakeUITableView

- (BOOL)isDecelerating {
    return isDecelerating;
}

- (BOOL)isDragging {
    return isDragging;
}

- (void)setIsDecelerating:(BOOL)decelerating {
    isDecelerating = decelerating;
}

- (void)setIsDragging:(BOOL)dragging {
    isDragging = dragging;
}

@end
