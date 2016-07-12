//
//  ViewController.m
//  Countdown
//
//  Created by Akshay Easwaran on 4/29/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "ViewController.h"

#import "DateHandler.h"
#import "AddCountdownViewController.h"
#import "CountdownCell.h"
#import "CountdownDetailViewController.h"
#import "SettingsViewController.h"

#import <DateTools/DateTools.h>
#import <Chameleon.h>

@interface ViewController ()
{
    NSArray *countdowns;
    NSTimer *dateTimer;
    UITapGestureRecognizer *tapRecog;
    NSDateFormatter *dateFormatter;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    [self.tableView setBackgroundColor:mainColor];
    [self.view setBackgroundColor:mainColor];
    [self.tableView setSeparatorColor:complmentaryColor];
    
    self.title = @"Countr";
    self.tableView.estimatedRowHeight = 126;
    self.tableView.rowHeight = 126;
    
    [self refreshCountdownList];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewCountdown)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CountdownCell" bundle:nil] forCellReuseIdentifier:@"CountdownCell"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    
    dateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshCountdownList) userInfo:nil repeats:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(popViewControllerAnimated:)];
    
    [self reloadColors];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadColors) name:@"reloadColors" object:nil];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"MMMM d, YYYY"]];
}

-(void)reloadColors {
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    [[UINavigationBar appearance] setBarTintColor:mainColor];
    [self.navigationController.navigationBar setBarTintColor:mainColor];
    UIColor *tintColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:mainColor isFlat:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : tintColor}];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : tintColor}];
    [[UIApplication sharedApplication] setStatusBarStyle:[ChameleonStatusBar statusBarStyleForColor:mainColor] animated:YES];
    [self.tableView setBackgroundColor:mainColor];
    [self.view setBackgroundColor:mainColor];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    [self.tableView setSeparatorColor:complmentaryColor];
    [self.tableView reloadData];
}

-(void)openSettings {
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]] animated:YES completion:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.navigationController.navigationBar removeGestureRecognizer:tapRecog];
}

-(void)refreshCountdownList {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending: YES];
    countdowns = [[[DateHandler sharedHandler] allCountdowns] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.tableView reloadData];
}

-(void)addNewCountdown {
    NSLog(@"Add New");
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[[AddCountdownViewController alloc] initWithStyle:UITableViewStyleGrouped]] animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    countdowns = nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return countdowns.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CountdownCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountdownCell"];
    NSDictionary *dateDict = countdowns[indexPath.row];
    NSDate *countdownToDate = dateDict[@"date"];
    [cell.titleLabel setText:dateDict[@"title"]];
    [cell.titleLabel sizeToFit];
    [cell.locationLabel setText:[NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:countdownToDate],dateDict[@"location"]]];
    [cell.locationLabel sizeToFit];
    
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    UIColor *bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"bgColor"]];
    cell.backgroundColor = mainColor;
    
    UIColor *contrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:mainColor isFlat:NO];
    
    UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
    [bgView setBackgroundColor:bgColor];
    cell.selectedBackgroundView = bgView;
    
    [cell.titleLabel setTextColor:contrastColor];
    [cell.generalTimeLabel setTextColor:contrastColor];
    [cell.lessGeneralTimeLabel setTextColor:contrastColor];
    [cell.specificTimeLabel setTextColor:contrastColor];
    [cell.detailedTimeLabel setTextColor:contrastColor];
    
    if ([mainColor isEqual:[UIColor flatBlackColor]]) {
        [cell.generalTimeDenotation setTextColor:[UIColor darkGrayColor]];
        [cell.lessGeneralTimeDenotation setTextColor:[UIColor darkGrayColor]];
        [cell.specificTimeDenotation setTextColor:[UIColor darkGrayColor]];
        [cell.detailedTimeDenotation setTextColor:[UIColor darkGrayColor]];
        [cell.locationLabel setTextColor:[UIColor darkGrayColor]];
    } else {
        [cell.generalTimeDenotation setTextColor:complmentaryColor];
        [cell.lessGeneralTimeDenotation setTextColor:complmentaryColor];
        [cell.specificTimeDenotation setTextColor:complmentaryColor];
        [cell.detailedTimeDenotation setTextColor:complmentaryColor];
        [cell.locationLabel setTextColor:complmentaryColor];
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
            [cell.generalTimeLabel setText:[NSString stringWithFormat:@"%li",(long)years]];
            if (years == 1) {
                [cell.generalTimeDenotation setText:@"year"];
            } else {
                [cell.generalTimeDenotation setText:@"years"];
            }
            
            [cell.lessGeneralTimeLabel setText:[NSString stringWithFormat:@"%li",(long)months]];
            if (months == 1) {
                [cell.lessGeneralTimeDenotation setText:@"month"];
            } else {
                [cell.lessGeneralTimeDenotation setText:@"months"];
            }
            
            [cell.specificTimeLabel setText:[NSString stringWithFormat:@"%li",(long)days]];
            if (days == 1) {
                [cell.specificTimeDenotation setText:@"day"];
            } else {
                [cell.specificTimeDenotation setText:@"days"];
            }
            
            [cell.detailedTimeLabel setText:[NSString stringWithFormat:@"%li",(long)hours]];
            if (hours == 1) {
                [cell.detailedTimeDenotation setText:@"hour"];
            } else {
                [cell.detailedTimeDenotation setText:@"hours"];
            }
        } else if (months > 0) {
            [cell.generalTimeLabel setText:[NSString stringWithFormat:@"%li",(long)months]];
            if (months == 1) {
                [cell.generalTimeDenotation setText:@"month"];
            } else {
                [cell.generalTimeDenotation setText:@"months"];
            }
            
            [cell.lessGeneralTimeLabel setText:[NSString stringWithFormat:@"%li",(long)days]];
            if (days == 1) {
                [cell.lessGeneralTimeDenotation setText:@"day"];
            } else {
                [cell.lessGeneralTimeDenotation setText:@"days"];
            }
            
            [cell.specificTimeLabel setText:[NSString stringWithFormat:@"%li",(long)hours]];
            if (hours == 1) {
                [cell.specificTimeDenotation setText:@"hour"];
            } else {
                [cell.specificTimeDenotation setText:@"hours"];
            }
            
            [cell.detailedTimeLabel setText:[NSString stringWithFormat:@"%li",(long)minutes]];
            if (minutes == 1) {
                [cell.detailedTimeDenotation setText:@"minute"];
            } else {
                [cell.detailedTimeDenotation setText:@"minutes"];
            }
        } else if (days >= 0) {
            [cell.generalTimeLabel setText:[NSString stringWithFormat:@"%li",(long)days]];
            if (days == 1) {
                [cell.generalTimeDenotation setText:@"day"];
            } else {
                [cell.generalTimeDenotation setText:@"days"];
            }
            
            [cell.lessGeneralTimeLabel setText:[NSString stringWithFormat:@"%li",(long)hours]];
            if (hours == 1) {
                [cell.lessGeneralTimeDenotation setText:@"hour"];
            } else {
                [cell.lessGeneralTimeDenotation setText:@"hours"];
            }
            
            [cell.specificTimeLabel setText:[NSString stringWithFormat:@"%li",(long)minutes]];
            if (minutes == 1) {
                [cell.specificTimeDenotation setText:@"minute"];
            } else {
                [cell.specificTimeDenotation setText:@"minutes"];
            }
            
            [cell.detailedTimeLabel setText:[NSString stringWithFormat:@"%li",(long)seconds]];
            if (seconds == 1) {
                [cell.detailedTimeDenotation setText:@"second"];
            } else {
                [cell.detailedTimeDenotation setText:@"seconds"];
            }
        }
    } else {
        UIColor *disabledColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        [cell.generalTimeLabel setTextColor:disabledColor];
        [cell.lessGeneralTimeLabel setTextColor:disabledColor];
        [cell.specificTimeLabel setTextColor:disabledColor];
        [cell.detailedTimeLabel setTextColor:disabledColor];
        [cell.titleLabel setTextColor:disabledColor];

        [cell.generalTimeLabel setText:@"0"];
        [cell.lessGeneralTimeLabel setText:@"0"];
        [cell.specificTimeLabel setText:@"0"];
        [cell.detailedTimeLabel setText:@"0"];
        
        [cell.generalTimeDenotation setText:@"days"];
        [cell.lessGeneralTimeDenotation setText:@"hours"];
        [cell.specificTimeDenotation setText:@"minutes"];
        [cell.detailedTimeDenotation setText:@"seconds"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dateDict = countdowns[indexPath.row];
    NSLog(@"Details - saved date %@ name %@",dateDict[@"date"],dateDict[@"title"]);
    [self.navigationController pushViewController:[[CountdownDetailViewController alloc] initWithCountdown:countdowns[indexPath.row]] animated:YES];
}

@end
