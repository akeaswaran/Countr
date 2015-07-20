//
//  AddCountdownViewController.m
//  Countdown
//
//  Created by Akshay Easwaran on 4/30/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "AddCountdownViewController.h"

#import "DateHandler.h"
#import "ViewController.h"

#import <DateTools.h>
#import <LPlaceholderTextView.h>
#import <Chameleon.h>

@interface AddCountdownViewController () <UIScrollViewDelegate,UITextViewDelegate>
{
    IBOutlet UITableViewCell *titleCell;
    IBOutlet UITextField *titleField;
    
    IBOutlet UITableViewCell *locationCell;
    IBOutlet UITextField *locationField;
    
    IBOutlet UITableViewCell *dateCell;
    IBOutlet UILabel *dateLabel;
    
    IBOutlet UITableViewCell *pickerCell;
    IBOutlet UIDatePicker *datePicker;
    
    IBOutlet UITableViewCell *timeCell;
    IBOutlet UILabel *timeLabel;
    
    IBOutlet UIDatePicker *timePicker;
    IBOutlet UITableViewCell *timePickerCell;
    
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
    
    IBOutlet LPlaceholderTextView *descriptionTextView;
    IBOutlet UITableViewCell *descriptionCell;
}

@end

@implementation AddCountdownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    [self.tableView setBackgroundColor:mainColor];
    [self.view setBackgroundColor:mainColor];
    [self.tableView setSeparatorColor:complmentaryColor];
    
    self.title = @"New";
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [dateLabel setTextColor:self.view.tintColor];
    [timeLabel setTextColor:self.view.tintColor];
    
    dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    timeLabel.text = [timeFormatter stringFromDate:[NSDate date]];
    
    [datePicker setMinimumDate:[NSDate date]];
    
    [descriptionTextView setPlaceholderText:@"Countdown Description"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveCountdown)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissVC)];
}

-(void)saveCountdown {
    if (titleField.text && titleField.text.length != 0 && [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
        
        NSDate *chosenDate = [NSDate dateWithYear:datePicker.date.year month:datePicker.date.month day:datePicker.date.day hour:timePicker.date.hour minute:timePicker.date.minute second:0];
        
        NSMutableDictionary *dateDict = [NSMutableDictionary dictionary];
        [dateDict setObject:chosenDate forKey:@"date"];
        [dateDict setObject:descriptionTextView.text forKey:@"description"];
        [dateDict setObject:[[DateHandler sharedHandler] generateCountdownIdentifier:10] forKey:@"id"];
        [dateDict setObject:titleField.text forKey:@"title"];
        [dateDict setObject:locationField.text forKey:@"location"];
        [[DateHandler sharedHandler] saveCountdown:dateDict];
        
        NSLog(@"SAVED %@ with date %@",titleField.text,chosenDate);
        [(ViewController*)self.presentingViewController.childViewControllers[0] performSelector:@selector(refreshCountdownList) withObject:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You must have a title in order to set this date!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)dateChanged:(UIDatePicker *)sender {
    dateLabel.text = [dateFormatter stringFromDate:sender.date];
}

- (IBAction)timeChanged:(UIDatePicker *)sender {
    timeLabel.text = [timeFormatter stringFromDate:sender.date];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return nil;
    } else if (section == 2) {
        return @"DATE";
    } else {
        return @"TIME";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1)
        return 1;
    else
        return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || (indexPath.section == 2 && indexPath.row == 0) || (indexPath.section == 3 && indexPath.row == 0)) {
        return 44;
    } else if (indexPath.section == 1) {
        return 225;
    } else {
        return 200;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    UIColor *complementaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    UIColor *contrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:mainColor isFlat:NO];
    
    if (indexPath.section == 0) {
        if(indexPath.row == 0) {
            [titleCell setBackgroundColor:mainColor];
            [titleField setTextColor:contrastColor];
            return titleCell;
        } else {
            [locationCell setBackgroundColor:mainColor];
            [locationField setTextColor:contrastColor];
            return locationCell;
        }
    } else if (indexPath.section == 1) {
        [descriptionCell setBackgroundColor:mainColor];
        [descriptionTextView setBackgroundColor:mainColor];
        [descriptionTextView setPlaceholderColor:complementaryColor];
        [descriptionTextView setTextColor:contrastColor];
        return descriptionCell;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [dateCell setBackgroundColor:mainColor];
            [dateLabel setTextColor:contrastColor];
            return dateCell;
        } else {
            [pickerCell setBackgroundColor:mainColor];
            return pickerCell;
        }
    } else {
        if (indexPath.row == 0) {
            [timeCell setBackgroundColor:mainColor];
            [timeLabel setTextColor:contrastColor];
            return timeCell;
        } else {
            [timePickerCell setBackgroundColor:mainColor];
            return timePickerCell;
        }
    }
}

@end
