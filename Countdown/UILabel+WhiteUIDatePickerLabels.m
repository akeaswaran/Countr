//
//  UILabel+WhiteUIDatePickerLabels.m
//  Countdown
//
//  Created by Akshay Easwaran on 4/30/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

//Solution to make UIDatePicker selection labels white from http://stackoverflow.com/a/20963739

#import "UILabel+WhiteUIDatePickerLabels.h"
#import <objc/runtime.h>
#import <Chameleon.h>

@implementation UILabel (WhiteUIDatePickerLabels)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceSelector:@selector(setTextColor:)
                      withNewSelector:@selector(swizzledSetTextColor:)];
        [self swizzleInstanceSelector:@selector(willMoveToSuperview:)
                      withNewSelector:@selector(swizzledWillMoveToSuperview:)];
    });
}

// Forces the text colour of the lable to be white only for UIDatePicker and its components
-(void) swizzledSetTextColor:(UIColor *)textColor {
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    //if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        if([self view:self hasSuperviewOfClass:[UIDatePicker class]] ||
           [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerWeekMonthDayView")] ||
           [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerContentView")]){
            [self swizzledSetTextColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:[NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]] isFlat:NO]];
        } else {
            //Carry on with the default
            [self swizzledSetTextColor:textColor];
        }
    /*} else {
        //Carry on with the default
        [self swizzledSetTextColor:textColor];
    }*/
}

// Some of the UILabels haven't been added to a superview yet so listen for when they do.
- (void) swizzledWillMoveToSuperview:(UIView *)newSuperview {
    [self swizzledSetTextColor:self.textColor];
    [self swizzledWillMoveToSuperview:newSuperview];
}

// -- helpers --
- (BOOL) view:(UIView *) view hasSuperviewOfClass:(Class) class {
    if(view.superview){
        if ([view.superview isKindOfClass:class]){
            return true;
        }
        return [self view:view.superview hasSuperviewOfClass:class];
    }
    return false;
}

+ (void) swizzleInstanceSelector:(SEL)originalSelector
                 withNewSelector:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end