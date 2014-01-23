//
//  FakeUITableView.h
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FakeUITableView : UITableView
{
    BOOL isDecelerating, isDragging;
}

- (void)setIsDecelerating:(BOOL)decelerating;
- (void)setIsDragging:(BOOL)dragging;

@property (nonatomic, readonly) BOOL didReceiveReloadData;
@property (nonatomic, readonly) BOOL didReceiveReloadRows;
@property (nonatomic, readonly) NSArray *indexPathsFromReloadRows;

@end
