//
//  CountdownDetailViewController.h
//  Countdown
//
//  Created by Akshay Easwaran on 4/30/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountdownDetailViewController : UITableViewController
-(instancetype)initWithCountdown:(NSDictionary*)countdown;
-(void)reloadCountdown;
@end
