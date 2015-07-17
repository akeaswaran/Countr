//
//  DateHandler.m
//  Countdown
//
//  Created by Akshay Easwaran on 4/30/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "DateHandler.h"
#import <UIKit/UIKit.h>

#define kCDPlistFilePath @"CountdownDatabase.plist"
#define kCDPlistFileName @""

@implementation DateHandler

+(DateHandler*)sharedHandler {
    static DateHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DateHandler alloc] init];
    });
    return instance;
}

-(void)deleteCountdownDatabaseWithCompletion:(CDErrorCompletionBlock)completionBlock {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kCDPlistFilePath];
    
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
    {
        completionBlock(error);
    }
}

-(NSArray*)allCountdowns {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString *credentialsFilePath = [documentsPath stringByAppendingPathComponent:kCDPlistFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:credentialsFilePath]) {
        return [NSArray arrayWithContentsOfFile:credentialsFilePath];
    } else {
        return [NSArray array];
    }
}

-(NSDictionary*)countdownForID:(NSString*)identifier {
    NSDictionary *dateDict = nil;
    NSArray *countdowns = [self allCountdowns];
    for (NSDictionary *dict in countdowns) {
        if ([dict[@"id"] isEqual:identifier]) {
            dateDict = dict;
            break;
        }
    }
    return dateDict;
}

-(NSInteger)_indexOfCountdownForID:(NSString*)identifier {
    NSInteger index;
    NSArray *countdowns = [self allCountdowns];
    NSDictionary *dict = nil;
    for (int i = 0; i < [self allCountdowns].count; i++) {
        dict = countdowns[i];
        if ([dict[@"id"] isEqual:identifier]) {
            index = i;
            break;
        }
    }
    
    return index;
}

-(void)saveCountdown:(NSDictionary*)dateDict {
    NSString *identifier = dateDict[@"id"];
    NSDate *date = dateDict[@"date"];
    NSString *title = dateDict[@"title"];
    NSString *description = dateDict[@"description"];
    
    if (![self countdownForID:identifier]) {
        /*NSMutableDictionary *dateDict = [NSMutableDictionary dictionary];
        [dateDict setObject:date forKey:@"date"];
        [dateDict setObject:description forKey:@"description"];
        [dateDict setObject:identifier forKey:@"id"];
        [dateDict setObject:title forKey:@"title"];*/
        
        NSMutableArray *mutableCountdowns = [[self allCountdowns] mutableCopy];
        [mutableCountdowns addObject:dateDict];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *credentialsFilePath = [documentsPath stringByAppendingPathComponent:kCDPlistFilePath];
        [mutableCountdowns writeToFile:credentialsFilePath atomically:YES];
        
        [self _scheduleNotificationForCountdown:dateDict];
    } else {
        NSMutableDictionary *dateMutable = [NSMutableDictionary dictionaryWithDictionary:[self countdownForID:identifier]];
        [self _cancelNotificationForCountdown:dateDict];
        
        NSInteger countdownIndex = [self _indexOfCountdownForID:identifier];
        [dateMutable setObject:date forKey:@"date"];
        [dateMutable setObject:description forKey:@"description"];
        [dateMutable setObject:title forKey:@"title"];
        
        NSLog(@"DICT AFTER EDIT: %@",dateMutable);
        
        NSMutableArray *mutableCountdowns = [[self allCountdowns] mutableCopy];
        [mutableCountdowns replaceObjectAtIndex:countdownIndex withObject:dateDict];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *credentialsFilePath = [documentsPath stringByAppendingPathComponent:kCDPlistFilePath];
        [mutableCountdowns writeToFile:credentialsFilePath atomically:YES];
        
        [self _scheduleNotificationForCountdown:dateDict];
    }

}

-(void)_scheduleNotificationForCountdown:(NSDictionary*)countdown {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = countdown[@"date"];
    localNotification.alertBody = [NSString stringWithFormat:@"The countdown is over - %@ is finally here!", countdown[@"title"]];
    localNotification.userInfo = @{@"id" : countdown[@"id"]};
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber++;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)_cancelNotificationForCountdown:(NSDictionary*)countdown {
    UILocalNotification *cancelThisNotification = nil;
    BOOL hasNotification = NO;
    
    for (UILocalNotification *someNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if([[someNotification.userInfo objectForKey:@"id"] isEqualToString:countdown[@"id"]]) {
            cancelThisNotification = someNotification;
            hasNotification = YES;
            break;
        }
    }
    if (hasNotification == YES) {
        NSLog(@"%@ ",cancelThisNotification);
        [[UIApplication sharedApplication] cancelLocalNotification:cancelThisNotification];
    }
}

-(void)removeDateWithID:(NSString*)identifier {
    NSDictionary *dateDict = nil;
    for (NSDictionary *dict in [self allCountdowns]) {
        if ([dict[@"id"] isEqual:identifier]) {
            dateDict = dict;
            break;
        }
    }
    
    NSMutableArray *mutableCountdowns = [[self allCountdowns] mutableCopy];
    [mutableCountdowns removeObject:dateDict];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *credentialsFilePath = [documentsPath stringByAppendingPathComponent:kCDPlistFilePath];
    [mutableCountdowns writeToFile:credentialsFilePath atomically:YES];
    
    [self _cancelNotificationForCountdown:dateDict];
}

-(NSString *)_generateCountdownIdentifier:(NSInteger)length {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i=0; i<length; i++) {
        NSUInteger index = arc4random_uniform((u_int32_t)[letters length]);
        [randomString appendFormat: @"%C", [letters characterAtIndex: index]];
    }
    
    return randomString;
}

-(NSString*)generateCountdownIdentifier:(NSInteger)length {
    return [self _generateCountdownIdentifier:length];
}


@end
