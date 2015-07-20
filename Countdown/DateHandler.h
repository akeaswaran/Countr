//
//  DateHandler.h
//  Countdown
//
//  Created by Akshay Easwaran on 4/30/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CDErrorCompletionBlock)(NSError *error);

@interface DateHandler : NSObject
+(DateHandler*)sharedHandler;
-(void)deleteCountdownDatabaseWithCompletion:(CDErrorCompletionBlock)completionBlock;
-(NSArray*)allCountdowns;
-(NSDictionary*)countdownForID:(NSString*)identifier;
-(void)removeDateWithID:(NSString*)identifier;
-(void)saveCountdown:(NSDictionary*)dateDict;
-(NSString*)generateCountdownIdentifier:(NSInteger)length;
@end
