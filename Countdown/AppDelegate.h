//
//  AppDelegate.h
//  Countdown
//
//  Created by Akshay Easwaran on 4/29/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
-(void)reloadColors;

@end

