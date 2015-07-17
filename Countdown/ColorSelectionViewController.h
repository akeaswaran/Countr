//
//  ColorSelectionViewController.h
//  Countdown
//
//  Created by Akshay Easwaran on 5/6/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorSelectionViewController : UITableViewController
{
    NSInteger _selectedIndex;
}

@property (assign, nonatomic) id delegate;
@property (assign, nonatomic) NSInteger selectedIndex;

@end

@protocol ColorSelectionDelegate <NSObject>

- (void)colorSelectionController:(ColorSelectionViewController *)colorSelectionController didSelectColorAtIndex:(NSInteger)selectedIndex;

@end
