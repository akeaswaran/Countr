//
//  SettingsViewController.m
//  Countdown
//
//  Created by Akshay Easwaran on 4/30/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "SettingsViewController.h"

#import <ChameleonFramework/Chameleon.h>

#import "DateHandler.h"
#import "ColorSelectionViewController.h"
#import "AppDelegate.h"

@import MessageUI;

@interface SettingsViewController () <ColorSelectionDelegate,MFMailComposeViewControllerDelegate>
{
    NSInteger _selectedColorIndex;
    IBOutlet UIView* _footerView;
    IBOutlet UILabel *_versionLabel;
}
@end

@implementation SettingsViewController

#pragma mark - Color Selection

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

-(void)colorSelectionController:(ColorSelectionViewController *)colorSelectionController didSelectColorAtIndex:(NSInteger)selectedIndex {
    _selectedColorIndex = selectedIndex;
    NSDictionary *colorDict = [self colors][selectedIndex];
    [[NSUserDefaults standardUserDefaults] setObject:colorDict forKey:@"colorScheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSData *colorData = [colorDict objectForKey:@"color"];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] reloadColors];
    [self reloadColors];
    [[UIApplication sharedApplication] setStatusBarStyle:[ChameleonStatusBar statusBarStyleForColor:color] animated:YES];
    [[UINavigationBar appearance] setBarTintColor:color];
    [self.navigationController.navigationBar setBarTintColor:color];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:color isFlat:NO]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:color isFlat:NO]];
    NSMutableDictionary *textAtts = [NSMutableDictionary dictionaryWithDictionary:self.navigationController.navigationBar.titleTextAttributes];
    [textAtts setObject:[UIColor colorWithContrastingBlackOrWhiteColorOn:color isFlat:NO] forKey:NSForegroundColorAttributeName];
    [self.navigationController.navigationBar setTitleTextAttributes:textAtts];
    
    [self.tableView reloadData];
}

- (NSString*)_selectedColor
{
    NSDictionary *colorDict;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"]) {
        colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    } else {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWhiteColor]];
        colorDict = @{@"name":@"White",@"color":colorData,@"separatorColor" : [NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWhiteColorDark]]};
        [[NSUserDefaults standardUserDefaults] setObject:colorDict forKey:@"colorScheme"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return colorDict[@"name"];
}

-(UIColor*)separatorColorGenerator:(UIColor*)mainColor index:(NSInteger)index{
    return [NSArray arrayOfColorsWithColorScheme:ColorSchemeComplementary with:mainColor flatScheme:YES][index];
}

-(NSArray*)colors {
    static NSArray *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *colorPact = @[
          @{@"name":@"Black",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatBlackColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor darkGrayColor]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatBlackColorDark]]},
          @{@"name":@"White",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWhiteColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWhiteColorDark]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWhiteColorDark]]},
          @{@"name":@"Red",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatRedColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatRedColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatRedColorDark]]},
          @{@"name":@"Orange",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatOrangeColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatOrangeColorDark]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatOrangeColorDark]]},
          @{@"name":@"Yellow",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatYellowColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatYellowColorDark]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatYellowColorDark]]},
          @{@"name":@"Sand",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatSandColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatSandColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatSandColorDark]]},
          @{@"name":@"Navy Blue",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatNavyBlueColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatNavyBlueColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatNavyBlueColorDark]]},
          @{@"name":@"Magenta",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatMagentaColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatMagentaColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatMagentaColorDark]]},
          @{@"name":@"Teal",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatTealColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatTealColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatTealColorDark]]},
          @{@"name":@"Sky Blue",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatSkyBlueColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatSkyBlueColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatSkyBlueColorDark]]},
          @{@"name":@"Green",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatGreenColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatGreenColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatGreenColorDark]]},
          @{@"name":@"Mint",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatMintColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatMintColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatMintColorDark]]},
          @{@"name":@"Gray",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatGrayColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor grayColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatGrayColorDark]]},
          @{@"name":@"Forest Green",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatForestGreenColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor greenColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatForestGreenColorDark]]},
          @{@"name":@"Purple",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPurpleColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPurpleColorDark]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPurpleColorDark]]},
          @{@"name":@"Brown",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatBrownColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor brownColor] index:1]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatBrownColorDark]]},
          @{@"name":@"Plum",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPlumColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPlumColorDark]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPlumColorDark]]},
          @{@"name":@"Watermelon",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWatermelonColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatWatermelonColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatWatermelonColorDark]]},
          @{@"name":@"Lime",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatLimeColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor greenColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatLimeColorDark]]},
          @{@"name":@"Pink",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPinkColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPinkColorDark]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPinkColorDark]]},
          @{@"name":@"Maroon",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatMaroonColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatMaroonColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatMaroonColorDark]]},
          @{@"name":@"Coffee",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatCoffeeColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[self separatorColorGenerator:[UIColor flatCoffeeColor] index:0]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatCoffeeColorDark]]},
          @{@"name":@"Powder Blue",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPowderBlueColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPowderBlueColorDark]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatPowderBlueColorDark]]},
          @{@"name":@"Blue",@"color":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatBlueColor]],@"separatorColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatBlueColorDark]],@"bgColor":[NSKeyedArchiver archivedDataWithRootObject:[UIColor flatBlueColorDark]]}];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending: YES];
        instance = [colorPact sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
    });
    return instance;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    for (int i = 0; i < [self colors].count; i++) {
        if ([colorDict isEqualToDictionary:[self colors][i]]) {
            _selectedColorIndex = i;
        }
    }
    NSData *colorData = [colorDict objectForKey:@"color"];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    return [ChameleonStatusBar statusBarStyleForColor:color];
}

- (void)viewDidLoad {
    
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    for (int i = 0; i < [self colors].count; i++) {
        if ([colorDict isEqualToDictionary:[self colors][i]]) {
            _selectedColorIndex = i;
        }
    }
    
    NSData *colorData = [colorDict objectForKey:@"color"];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    [[UIApplication sharedApplication] setStatusBarStyle:[ChameleonStatusBar statusBarStyleForColor:color] animated:NO];
    
    
    [super viewDidLoad];
    NSDictionary *defaultColorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:defaultColorDict[@"color"]];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:defaultColorDict[@"separatorColor"]];
    
    [self.tableView setBackgroundColor:mainColor];
    [self.view setBackgroundColor:mainColor];
    [self.tableView setSeparatorColor:complmentaryColor];
    
    self.title = @"Settings";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(dismissVC)];
    
    [self reloadColors];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadColors) name:@"reloadColors" object:nil];

}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"CUSTOMIZATION";
    } else if (section == 1) {
        return @"DEVELOPER";
    } else if (section == 2) {
        return @"CREDITS";
    } else {
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section != 3) {
        return [super tableView:tableView heightForFooterInSection:section];
    } else {
        return 50;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != 3) {
        return nil;
    } else {
        NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
        UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
        UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
        [_footerView setBackgroundColor:mainColor];
        [_versionLabel setTextColor:complmentaryColor];
        [_versionLabel setText:[NSString stringWithFormat:@"Version %@ (%@)\n© 2015 Akshay Easwaran",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        return _footerView;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 2) {
        return 4;
    } else if (section == 3 || section == 1) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    UIColor *mainColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    UIColor *complmentaryColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    UIColor *bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"bgColor"]];
    UIColor *contrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:mainColor isFlat:NO];
    
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];

            [cell.textLabel setTextColor:contrastColor];

            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.backgroundColor = mainColor;
        
        UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
        [bgView setBackgroundColor:bgColor];
        cell.selectedBackgroundView = bgView;
        
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"Gear image provided by Icons8"];
            [cell.textLabel setTextColor:contrastColor];
        } else if (indexPath.row == 1) {
            [cell.textLabel setText:@"Theme support via Chameleon"];
            [cell.textLabel setTextColor:contrastColor];
        } else if (indexPath.row == 2) {
            [cell.textLabel setText:@"Date calculations performed using DateTools"];
            [cell.textLabel setTextColor:contrastColor];
        } else {
            [cell.textLabel setText:@"Descriptions shown using LPlaceholderTextView"];
            [cell.textLabel setFont:[UIFont systemFontOfSize:15.0]];
            [cell.textLabel setTextColor:contrastColor];
        }
        
        return cell;
    } else if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.backgroundColor = mainColor;
        
        UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
        [bgView setBackgroundColor:bgColor];
        cell.selectedBackgroundView = bgView;
        
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"Clear All Notifications"];
            [cell.textLabel setTextColor:[UIColor flatRedColorDark]];
    
        } else {
            [cell.textLabel setText:@"Delete Countdown Database"];
            [cell.textLabel setTextColor:[UIColor flatRedColorDark]];
          
        }
        return cell;
    } else if (indexPath.section == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ColorSchemeCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ColorSchemeCell"];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.tintColor = complmentaryColor;
            }
            
            cell.backgroundColor = mainColor;
            
            UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
            [bgView setBackgroundColor:bgColor];
            cell.selectedBackgroundView = bgView;
            [cell.detailTextLabel setTextColor:contrastColor];
            [cell.textLabel setTextColor:contrastColor];
            
            [cell.textLabel setText:@"Color Scheme"];
            [cell.detailTextLabel setText:[self _selectedColor]];
            return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WebsiteCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WebsiteCell"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.backgroundColor = mainColor;
        [cell.textLabel setTextColor:contrastColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
        [bgView setBackgroundColor:bgColor];
        cell.selectedBackgroundView = bgView;
        
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"Visit Website"];
        } else {
            [cell.textLabel setText:@"Questions, Comments, Concerns?"];
        }
        return cell;
    }

}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to open this link in Safari?" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://icons8.com/"]];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to open this link in Safari?" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/VAlexander/Chameleon"]];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else if (indexPath.row == 2) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to open this link in Safari?" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/MatthewYork/DateTools"]];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to open this link in Safari?" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/lukagabric/LPlaceholderTextView"]];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notifications cancelled successfully!" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertController *alertMaster = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"If you delete the database, you will not be able to view any of your countdowns again. Are you sure you want to delete it?" preferredStyle:UIAlertControllerStyleAlert];
            [alertMaster addAction:[UIAlertAction actionWithTitle:@"Yes, delete them all." style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [[DateHandler sharedHandler] deleteCountdownDatabaseWithCompletion:^(NSError *error) {
                    if (error) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error deleting the database" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    } else {
                        [[UIApplication sharedApplication] cancelAllLocalNotifications];
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Database deleted successfully!" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }];
            }]];
            
            [alertMaster addAction:[UIAlertAction actionWithTitle:@"No, I want to keep the database." style:UIAlertActionStyleCancel handler:nil]];
            [self.navigationController presentViewController:alertMaster animated:YES completion:nil];
        }
    } else if (indexPath.section == 0) {
        ColorSelectionViewController *colorSelect = [[ColorSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];
        colorSelect.delegate = self;
        colorSelect.selectedIndex = _selectedColorIndex;
        [self.navigationController pushViewController:colorSelect animated:YES];
    } else {
        if (indexPath.row == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to open this link in Safari?" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://akeaswaran.me/countr"]];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
            [composer setMailComposeDelegate:self];
            [composer setToRecipients:@[@"countrdevelopers@gmail.com"]];
            [composer setSubject:[NSString stringWithFormat:@"Nimbus v%@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
            [self presentViewController:composer animated:YES completion:nil];
        }
    }
        
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultFailed:
            [self dismissViewControllerAnimated:YES completion:nil];
            [self emailFail:error];
            break;
        case MFMailComposeResultSent:
            [self dismissViewControllerAnimated:YES completion:nil];
            [self emailSuccess];
        default:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

-(void)emailSuccess {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your email was sent successfully!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)emailFail:(NSError*)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your email was unable to be sent." message:[NSString stringWithFormat:@"Sending failed with the following error: \"%@\".",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
