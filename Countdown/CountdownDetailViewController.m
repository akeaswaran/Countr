//
//  CountdownDetailViewController.m
//  Countdown
//
//  Created by Akshay Easwaran on 4/30/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import"CountdownDetailViewController.h"

#import "DateHandler.h"
#import "EditCountdownViewController.h"

#import <DateTools.h>
#import <LPlaceholderTextView.h>
#import <Chameleon.h>

@interface CountdownDetailViewController () <UITextViewDelegate>
{
    NSDictionary *storedCountdown;
    NSTimer *timer;
    IBOutlet UITableViewCell *countdownCell;
    
    IBOutlet LPlaceholderTextView *descriptionTextView;
    IBOutlet UITableViewCell *descriptionCell;
    
    IBOutlet UILabel *formattedDateLabel;
    IBOutlet UITableViewCell *formattedDateCell;
    IBOutlet UILabel *countdownTitleLabel;
    IBOutlet UILabel *countdownLocationLabel;
    IBOutlet UILabel *leftLabel;
    
    NSDateFormatter *dateFormatter;
    CGFloat heightForTitle;
}

@property (strong, nonatomic) IBOutlet UILabel *generalTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lessGeneralTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *specificTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailedTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *generalTimeDenotation;
@property (strong, nonatomic) IBOutlet UILabel *lessGeneralTimeDenotation;
@property (strong, nonatomic) IBOutlet UILabel *specificTimeDenotation;
@property (strong, nonatomic) IBOutlet UILabel *detailedTimeDenotation;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation CountdownDetailViewController

-(instancetype)initWithCountdown:(NSDictionary*)countdown {
    self = [super init];
    if (self) {
        storedCountdown = countdown;
    }
    return self;
}

- (void)viewDidLoad {
    
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    [self.tableView setBackgroundColor:mainColor];
    [self.view setBackgroundColor:mainColor];
    [self.tableView setSeparatorColor:complmentaryColor];
    [self.tableView reloadData];
    
    [super viewDidLoad];
    self.title = @"Countdown";
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadCountdown) userInfo:nil repeats:YES];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"EEEE, MMMM d, YYYY"]];
    
    NSDictionary *dateDict = storedCountdown;
    NSDate *countdownToDate = dateDict[@"date"];
    [countdownTitleLabel setText:dateDict[@"title"]];
    [formattedDateLabel setText:[dateFormatter stringFromDate:countdownToDate]];
    [countdownLocationLabel setText:[NSString stringWithFormat:@"%@", dateDict[@"location"]]];
    [countdownTitleLabel sizeToFit];
    [countdownLocationLabel sizeToFit];
    [countdownCell layoutIfNeeded];
    heightForTitle = countdownCell.frame.size.height;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
}

-(void)reloadCountdown {
    if (![storedCountdown isEqual:[[DateHandler sharedHandler] countdownForID:storedCountdown[@"id"]]]) {
        storedCountdown = [[DateHandler sharedHandler] countdownForID:storedCountdown[@"id"]];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:0 inSection:1],[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return @"DESCRIPTION";
    } else {
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1 || section == 2) {
        return 1;
    } else {
        return 3;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return heightForTitle;
    } else if (indexPath.section == 1) {
        return 105;
    } else if (indexPath.section == 3) {
        return 44;
    } else {
        return 225;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dateDict = storedCountdown;
    NSDate *countdownToDate = dateDict[@"date"];
    
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    UIColor *contrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:mainColor isFlat:NO];
    UIColor *bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"bgColor"]];
    
    if (indexPath.section == 0) {
        [countdownTitleLabel setTextColor:contrastColor];
        [formattedDateLabel setTextColor:contrastColor];
        [countdownLocationLabel setTextColor:complmentaryColor];
        [countdownTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [countdownTitleLabel setText:dateDict[@"title"]];
        [formattedDateLabel setText:[dateFormatter stringFromDate:countdownToDate]];
        formattedDateCell.backgroundColor = mainColor;
        return formattedDateCell;
    } else if (indexPath.section == 1) {
        [self.titleLabel setText:storedCountdown[@"title"]];
        [self.titleLabel setTextColor:contrastColor];
        [self.generalTimeLabel setTextColor:contrastColor];
        [self.lessGeneralTimeLabel setTextColor:contrastColor];
        [self.specificTimeLabel setTextColor:contrastColor];
        [self.detailedTimeLabel setTextColor:contrastColor];
        [leftLabel setTextColor:contrastColor];
        
        if ([mainColor isEqual:[UIColor flatBlackColor]]) {
            [self.generalTimeDenotation setTextColor:[UIColor darkGrayColor]];
            [self.lessGeneralTimeDenotation setTextColor:[UIColor darkGrayColor]];
            [self.specificTimeDenotation setTextColor:[UIColor darkGrayColor]];
            [self.detailedTimeDenotation setTextColor:[UIColor darkGrayColor]];
        } else {
            [self.generalTimeDenotation setTextColor:complmentaryColor];
            [self.lessGeneralTimeDenotation setTextColor:complmentaryColor];
            [self.specificTimeDenotation setTextColor:complmentaryColor];
            [self.detailedTimeDenotation setTextColor:complmentaryColor];
        }
        
        if ([countdownToDate isLaterThan:[NSDate date]]) {
            unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:unitFlags fromDate:[NSDate date]  toDate:countdownToDate  options:0];
            NSInteger years = [comps year];
            NSInteger months = [comps month];
            NSInteger days = [comps day];
            NSInteger hours = [comps hour];
            NSInteger minutes = [comps minute];
            NSInteger seconds = [comps second];
            
            if (years > 0) {
                [self.generalTimeLabel setText:[NSString stringWithFormat:@"%li",(long)years]];
                if (years == 1) {
                    [self.generalTimeDenotation setText:@"year"];
                } else {
                    [self.generalTimeDenotation setText:@"years"];
                }
                
                [self.lessGeneralTimeLabel setText:[NSString stringWithFormat:@"%li",(long)months]];
                if (months == 1) {
                    [self.lessGeneralTimeDenotation setText:@"month"];
                } else {
                    [self.lessGeneralTimeDenotation setText:@"months"];
                }
                
                [self.specificTimeLabel setText:[NSString stringWithFormat:@"%li",(long)days]];
                if (days == 1) {
                    [self.specificTimeDenotation setText:@"day"];
                } else {
                    [self.specificTimeDenotation setText:@"days"];
                }
                
                [self.detailedTimeLabel setText:[NSString stringWithFormat:@"%li",(long)hours]];
                if (hours == 1) {
                    [self.detailedTimeDenotation setText:@"hour"];
                } else {
                    [self.detailedTimeDenotation setText:@"hours"];
                }
            } else if (months > 0) {
                [self.generalTimeLabel setText:[NSString stringWithFormat:@"%li",(long)months]];
                if (months == 1) {
                    [self.generalTimeDenotation setText:@"month"];
                } else {
                    [self.generalTimeDenotation setText:@"months"];
                }
                
                [self.lessGeneralTimeLabel setText:[NSString stringWithFormat:@"%li",(long)days]];
                if (days == 1) {
                    [self.lessGeneralTimeDenotation setText:@"day"];
                } else {
                    [self.lessGeneralTimeDenotation setText:@"days"];
                }
                
                [self.specificTimeLabel setText:[NSString stringWithFormat:@"%li",(long)hours]];
                if (hours == 1) {
                    [self.specificTimeDenotation setText:@"hour"];
                } else {
                    [self.specificTimeDenotation setText:@"hours"];
                }
                
                [self.detailedTimeLabel setText:[NSString stringWithFormat:@"%li",(long)minutes]];
                if (minutes == 1) {
                    [self.detailedTimeDenotation setText:@"minute"];
                } else {
                    [self.detailedTimeDenotation setText:@"minutes"];
                }
            } else if (days >= 0) {
                [self.generalTimeLabel setText:[NSString stringWithFormat:@"%li",(long)days]];
                if (days == 1) {
                    [self.generalTimeDenotation setText:@"day"];
                } else {
                    [self.generalTimeDenotation setText:@"days"];
                }
                
                [self.lessGeneralTimeLabel setText:[NSString stringWithFormat:@"%li",(long)hours]];
                if (hours == 1) {
                    [self.lessGeneralTimeDenotation setText:@"hour"];
                } else {
                    [self.lessGeneralTimeDenotation setText:@"hours"];
                }
                
                [self.specificTimeLabel setText:[NSString stringWithFormat:@"%li",(long)minutes]];
                if (minutes == 1) {
                    [self.specificTimeDenotation setText:@"minute"];
                } else {
                    [self.specificTimeDenotation setText:@"minutes"];
                }
                
                [self.detailedTimeLabel setText:[NSString stringWithFormat:@"%li",(long)seconds]];
                if (seconds == 1) {
                    [self.detailedTimeDenotation setText:@"second"];
                } else {
                    [self.detailedTimeDenotation setText:@"seconds"];
                }
            }
            
        } else {
            
            UIColor *disabledColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            
            [self.generalTimeLabel setTextColor:disabledColor];
            [self.lessGeneralTimeLabel setTextColor:disabledColor];
            [self.specificTimeLabel setTextColor:disabledColor];
            [self.detailedTimeLabel setTextColor:disabledColor];
            [self.titleLabel setTextColor:disabledColor];
            
            [self.generalTimeLabel setText:@"0"];
            [self.lessGeneralTimeLabel setText:@"0"];
            [self.specificTimeLabel setText:@"0"];
            [self.detailedTimeLabel setText:@"0"];
            
            [self.generalTimeDenotation setText:@"days"];
            [self.lessGeneralTimeDenotation setText:@"hours"];
            [self.specificTimeDenotation setText:@"minutes"];
            [self.detailedTimeDenotation setText:@"seconds"];
        }
        countdownCell.backgroundColor = mainColor;
        return countdownCell;
    } else if (indexPath.section == 3) {
        UITableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        if (!buttonCell) {
            buttonCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
            [buttonCell.textLabel setTextAlignment:NSTextAlignmentCenter];
            UIView *bgView = [[UIView alloc] initWithFrame:buttonCell.bounds];
            [bgView setBackgroundColor:bgColor];
            buttonCell.selectedBackgroundView = bgView;
            buttonCell.backgroundColor = mainColor;
        }
        
        if (indexPath.row == 0) {
            [buttonCell.textLabel setTextColor:contrastColor];
            [buttonCell.textLabel setText:@"Edit"];
        } else if (indexPath.row == 1) {
            [buttonCell.textLabel setTextColor:contrastColor];
            [buttonCell.textLabel setText:@"Share"];
        } else {
            [buttonCell.textLabel setTextColor:[UIColor flatRedColorDark]];
            [buttonCell.textLabel setText:@"Delete"];
        }
        return buttonCell;
    } else {
        [descriptionCell setBackgroundColor:mainColor];
        [descriptionTextView setText:dateDict[@"description"]];
        [descriptionTextView setTextColor:contrastColor];
        [descriptionTextView setPlaceholderText:@"No description."];
        return descriptionCell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[[EditCountdownViewController alloc] initWithCountdown:storedCountdown]] animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            NSString *shareString = [NSString stringWithFormat:@"Only %@ %@, %@ %@, %@ %@, and %@ %@ until %@!",_generalTimeLabel.text,_generalTimeDenotation.text,_lessGeneralTimeLabel.text,_lessGeneralTimeDenotation.text,_specificTimeLabel.text,_specificTimeDenotation.text,_detailedTimeLabel.text,_detailedTimeDenotation.text,storedCountdown[@"title"]];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareString] applicationActivities:nil];
            [activityVC setExcludedActivityTypes:@[UIActivityTypeAddToReadingList,UIActivityTypeAirDrop,UIActivityTypeAssignToContact,UIActivityTypePostToVimeo,UIActivityTypeSaveToCameraRoll,UIActivityTypePrint]];
            [self presentViewController:activityVC animated:YES completion:nil];
        } else {
            UIAlertController *alertMaster = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"If you delete this countdown, you will not be able to view it again. Are you sure you want to delete it?" preferredStyle:UIAlertControllerStyleAlert];
            [alertMaster addAction:[UIAlertAction actionWithTitle:@"Yes, delete this countdown." style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [timer invalidate];
                [[DateHandler sharedHandler] removeDateWithID:storedCountdown[@"id"]];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }]];
            [alertMaster addAction:[UIAlertAction actionWithTitle:@"No, I want to keep this countdown." style:UIAlertActionStyleCancel handler:nil]];
            [self.navigationController presentViewController:alertMaster animated:YES completion:nil];
    
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
