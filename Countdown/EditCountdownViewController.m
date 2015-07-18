//
//  EditCountdownViewController.m
//  Countdown
//
//  Created by Akshay Easwaran on 5/1/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "EditCountdownViewController.h"

#import "ViewController.h"
#import "DateHandler.h"
#import "CountdownDetailViewController.h"
#import "AppDelegate.h"

#import <LPlaceholderTextView.h>
#import <DateTools.h>
#import <Chameleon.h> 

@interface EditCountdownViewController () <UITextViewDelegate, UIScrollViewDelegate>
{
    IBOutlet UITableViewCell *titleCell;
    IBOutlet UITextField *titleField;
    IBOutlet UILabel *nameLabel;
    
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
    
    NSDictionary *storedCountdown;
    NSMutableArray *images;
    NSMutableArray *imageFiles;
    NSMutableArray *removedImageFiles;
}

@end

@implementation EditCountdownViewController

-(instancetype)initWithCountdown:(NSDictionary*)countdown {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        storedCountdown = countdown;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    [self.tableView setBackgroundColor:mainColor];
    [self.view setBackgroundColor:mainColor];
    [self.tableView setSeparatorColor:complmentaryColor];
    
    self.title = @"Edit";
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [dateLabel setTextColor:self.view.tintColor];
    [timeLabel setTextColor:self.view.tintColor];
    
    NSDate *countdownDate = storedCountdown[@"date"];
    
    dateLabel.text = [dateFormatter stringFromDate:countdownDate];
    timeLabel.text = [timeFormatter stringFromDate:countdownDate];
    
    //[datePicker setMinimumDate:[NSDate date]];
    [datePicker setDate:countdownDate animated:YES];
    [timePicker setDate:countdownDate animated:YES];
    
    [titleField setText:storedCountdown[@"title"]];
    [descriptionTextView setPlaceholderText:@"Countdown Description"];
    [descriptionTextView setText:storedCountdown[@"description"]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveCountdown)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissVC)];
    imageFiles = storedCountdown[@"images"];
    images = [NSMutableArray array];
    for (NSString *fileName in imageFiles) {
        [images addObject:[self loadImageWithFileName:fileName]];
    }
    removedImageFiles = [NSMutableArray array];
    
}

- (UIImage*)loadImageWithFileName:(NSString*)name
{
    NSLog(@"LOADING FILE W NAME: %@",name);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      name];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

-(void)saveCountdown {
    if (titleField.text && titleField.text.length != 0 && [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
        
        NSDate *chosenDate = [NSDate dateWithYear:datePicker.date.year month:datePicker.date.month day:datePicker.date.day hour:timePicker.date.hour minute:timePicker.date.minute second:0];
        
        NSMutableDictionary *dateDict = [NSMutableDictionary dictionary];
        [dateDict setObject:chosenDate forKey:@"date"];
        [dateDict setObject:descriptionTextView.text forKey:@"description"];
        [dateDict setObject:storedCountdown[@"id"] forKey:@"id"];
        [dateDict setObject:titleField.text forKey:@"title"];
        if (removedImageFiles.count > 0) {
            for (NSString *fileName in removedImageFiles) {
                [[DateHandler sharedHandler] removeImage:fileName];
            }
        }
        
        if (images.count > 0 && imageFiles.count > 0) {
            NSMutableArray *imageFileNames = [NSMutableArray array];
            for (int i = 0; i < images.count; i++) {
                UIImage *image = images[i];
                NSString *fileName = [[DateHandler sharedHandler] generateImageNameForCountdown:dateDict];
                if (imageFiles[i]) {
                    fileName = imageFiles[i];
                }
                
                NSLog(@"SAVING %@ TO DISK", fileName);
                [imageFileNames addObject:fileName];
                [self saveImage:image fileName:fileName];
            }
            if(imageFileNames.count > 0) {
                [dateDict setObject:imageFileNames forKey:@"images"];
            }
        }
        
        [[DateHandler sharedHandler] saveCountdown:dateDict];

        NSLog(@"SAVED %@ with date %@",titleField.text,chosenDate);
        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] viewController] refreshCountdownList];
        [[[(UINavigationController*)self.navigationController.presentingViewController viewControllers] lastObject] performSelector:@selector(reloadCountdown) withObject:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You must have a title in order to edit this countdown!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)saveImage:(UIImage*)image fileName:(NSString*)name
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          name];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}

- (IBAction)dateChanged:(UIDatePicker *)sender {
    dateLabel.text = [dateFormatter stringFromDate:sender.date];
}

- (IBAction)timeChanged:(UIDatePicker *)sender {
    timeLabel.text = [timeFormatter stringFromDate:sender.date];
}

-(void)dismissVC {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Do you want to discard your changes to this countdown?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes, discard them." style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No, I'm still making changes." style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
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
    return 5;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < 2) {
        return nil;
    } else if (section == 2) {
        return @"IMAGES";
    } else if (section == 3) {
        return @"DATE";
    } else {
        return @"TIME";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 | section == 1)
        return 1;
    else if (section >= 3)
        return 2;
    else
        return imageFiles.count + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 2 || (indexPath.section == 3 && indexPath.row == 0) || (indexPath.section == 4 && indexPath.row == 0)) {
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
    UIColor *bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"bgColor"]];
    
    if (indexPath.section == 0) {
        [titleCell setBackgroundColor:mainColor];
        [titleField setTextColor:contrastColor];
        [nameLabel setTextColor:contrastColor];
        return titleCell;
    } else if (indexPath.section == 1) {
        [descriptionCell setBackgroundColor:mainColor];
        [descriptionTextView setBackgroundColor:mainColor];
        [descriptionTextView setPlaceholderColor:complementaryColor];
        [descriptionTextView setTextColor:contrastColor];
        return descriptionCell;
    } else if (indexPath.section == 2) {
        if (imageFiles.count > 0 && indexPath.row <= (imageFiles.count - 1)) {
            NSString *imageName = imageFiles[indexPath.row];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageCell"];
                [cell setBackgroundColor:mainColor];
                [cell.textLabel setTextColor:contrastColor];
                UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
                [bgView setBackgroundColor:bgColor];
                cell.selectedBackgroundView = bgView;
            }
            [cell.textLabel setText:imageName];
            
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
                [cell setBackgroundColor:mainColor];
                [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                [cell.textLabel setTextColor:contrastColor];
                UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
                [bgView setBackgroundColor:bgColor];
                cell.selectedBackgroundView = bgView;
            }
            [cell.textLabel setText:@"Select Images..."];
            
            return cell;
        }
    } else if (indexPath.section == 3) {
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

-(void)tableView:(nonnull UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 2 && imageFiles.count > 0 && indexPath.row <= (imageFiles.count - 1) &&  editingStyle == UITableViewCellEditingStyleDelete) {
        [removedImageFiles addObject:imageFiles[indexPath.row]];
        [images removeObjectAtIndex:indexPath.row];
        [imageFiles removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

-(BOOL)tableView:(nonnull UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (imageFiles.count > 0 && indexPath.section == 2 && indexPath.row <= (imageFiles.count - 1)) {
        return YES;
    }
    return NO;
}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (imageFiles.count > 0 && indexPath.row <= (imageFiles.count - 1)) {
            NSLog(@"SHOW IMAGE %@", imageFiles[indexPath.row]);
        } else {
            NSLog(@"Select Image");
        }
    }
}


@end
