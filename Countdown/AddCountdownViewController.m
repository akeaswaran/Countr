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
#import <CRMediaPickerController.h>
#import <TOCropViewController.h>

@interface AddCountdownViewController () <UIScrollViewDelegate,UITextViewDelegate,CRMediaPickerControllerDelegate,TOCropViewControllerDelegate>
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
    
    IBOutlet UITableViewCell *imageCell;
    IBOutlet UILabel *imageLabel;
    
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
    
    IBOutlet LPlaceholderTextView *descriptionTextView;
    IBOutlet UITableViewCell *descriptionCell;
    
    NSMutableArray *images;
}

@property (strong, nonatomic) CRMediaPickerController *mediaPickerController;
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
    
    images = [NSMutableArray array];
}

-(void)saveCountdown {
    if (titleField.text && titleField.text.length != 0 && [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
        
        NSDate *chosenDate = [NSDate dateWithYear:datePicker.date.year month:datePicker.date.month day:datePicker.date.day hour:timePicker.date.hour minute:timePicker.date.minute second:0];
        
        NSMutableDictionary *dateDict = [NSMutableDictionary dictionary];
        [dateDict setObject:chosenDate forKey:@"date"];
        [dateDict setObject:descriptionTextView.text forKey:@"description"];
        [dateDict setObject:[[DateHandler sharedHandler] generateCountdownIdentifier:10] forKey:@"id"];
        [dateDict setObject:titleField.text forKey:@"title"];
        if (images.count > 0) {
            NSMutableArray *imageFileNames = [NSMutableArray array];
            for (UIImage *image in images) {
                NSString *fileName = [[DateHandler sharedHandler] generateImageNameForCountdown:dateDict];
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
        [(ViewController*)self.presentingViewController.childViewControllers[0] performSelector:@selector(refreshCountdownList) withObject:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You must have a title in order to set this date!" preferredStyle:UIAlertControllerStyleAlert];
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
    if (section <= 2)
        return 1;
    else
        return 2;
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
        [imageCell setBackgroundColor:mainColor];
        [imageLabel setTextColor:contrastColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:imageCell.bounds];
        [bgView setBackgroundColor:bgColor];
        imageCell.selectedBackgroundView = bgView;
        return imageCell;
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

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.mediaPickerController = [[CRMediaPickerController alloc] init];
        self.mediaPickerController.delegate = self;
        self.mediaPickerController.mediaType = CRMediaPickerControllerMediaTypeImage;
        self.mediaPickerController.sourceType = (CRMediaPickerControllerSourceTypePhotoLibrary | CRMediaPickerControllerSourceTypeCamera | CRMediaPickerControllerSourceTypeSavedPhotosAlbum | CRMediaPickerControllerSourceTypeLastPhotoTaken);
        [self.mediaPickerController show];
    }
}

- (void)CRMediaPickerController:(CRMediaPickerController *)mediaPickerController didFinishPickingAsset:(ALAsset *)asset error:(NSError *)error {
    if([[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        UIImage *img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage
                                           scale:asset.defaultRepresentation.scale
                                     orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        TOCropViewController *cropper = [[TOCropViewController alloc] initWithImage:img];
        [cropper setDelegate:self];
        [self presentViewController:cropper animated:YES completion:nil];
    }
}

- (void)CRMediaPickerControllerDidCancel:(CRMediaPickerController *)mediaPickerController {
    NSLog(@"CANCEL");
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
    NSLog(@"CROPPED IMAGE TO: %@", NSStringFromCGRect(cropRect));
    [images addObject:image];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *imageString = @"Images";
    if (images.count == 1) {
        imageString = @"Image";
    }
    [imageLabel setText:[NSString stringWithFormat:@"%lu %@ Selected",(unsigned long)images.count,imageString]];
    [self.tableView reloadData];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled {
    NSLog(@"CANCEL FROM CROPPER");
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
