//
//  FakeUITableView.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "FakeUITableView.h"

@interface FakeUITableView ()
@property (nonatomic, readwrite) BOOL didReceiveReloadData;
@property (nonatomic, readwrite) BOOL didReceiveReloadRows;
@property (nonatomic, readwrite) NSArray *indexPathsFromReloadRows;

@end

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

- (void)reloadData {
    self.didReceiveReloadData = YES;
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    self.didReceiveReloadRows = YES;
    self.indexPathsFromReloadRows = indexPaths;
}

@end
