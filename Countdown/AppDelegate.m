//
//  AppDelegate.m
//  Countdown
//
//  Created by Akshay Easwaran on 4/29/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "CountdownDetailViewController.h"
#import "DateHandler.h"

#import <Chameleon.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"]) {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWhiteColor]];
        NSDictionary *colorDict = @{@"name":@"White",@"color":colorData,@"separatorColor" : [NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWhiteColorDark]],@"bgColor" : [NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWhiteColorDark]]};
        [[NSUserDefaults standardUserDefaults] setObject:colorDict forKey:@"colorScheme"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIColor *tintColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor flatWhiteColor] isFlat:NO];
        [[[UIApplication sharedApplication] keyWindow] setTintColor:tintColor];
        [[UIApplication sharedApplication] setStatusBarStyle:[ChameleonStatusBar statusBarStyleForColor:[NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]]] animated:YES];
    } else {
        NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
        [[UIApplication sharedApplication] setStatusBarStyle:[ChameleonStatusBar statusBarStyleForColor:[NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]]] animated:YES];
        UIColor *tintColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]] isFlat:NO];
        [[[UIApplication sharedApplication] keyWindow] setTintColor:tintColor];
    }
    
    [self reloadColors];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] initWithStyle:UITableViewStylePlain]]];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)reloadColors {
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    NSData *colorData = [colorDict objectForKey:@"color"];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    UIColor *tintColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:color isFlat:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:[ChameleonStatusBar statusBarStyleForColor:color] animated:YES];
    [[UINavigationBar appearance] setBarTintColor:color];
    [[UINavigationBar appearance] setTintColor:tintColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : tintColor}];
    [[[UIApplication sharedApplication] keyWindow] setTintColor:tintColor];
    if ([color isEqual:[UIColor flatBlackColor]]) {
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor darkGrayColor]];
    } else {
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadColors" object:nil];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    CountdownDetailViewController *detailViewController = [[CountdownDetailViewController alloc] initWithCountdown:[[DateHandler sharedHandler] countdownForID:notification.userInfo[@"id"]]];
    detailViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissVC)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}

-(void)dismissVC {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
