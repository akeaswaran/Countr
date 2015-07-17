//
//  ColorSelectionViewController.m
//  Countdown
//
//  Created by Akshay Easwaran on 5/6/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import "ColorSelectionViewController.h"

#import <Chameleon.h>

@interface ColorSelectionViewController ()
{
    UIColor *customTint;
    UIColor *customCheckColor;
    UIColor *contrastColor;
    UIColor *bgColor;
}
@end

@implementation ColorSelectionViewController

@synthesize delegate;
@synthesize selectedIndex = _selectedIndex;


- (void)viewDidLoad
{
    [self reloadColors];
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Color Scheme", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadColors) name:@"reloadColors" object:nil];
}

-(void)reloadColors {
    [self.tableView reloadData];
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorScheme"];
    customTint = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"color"]];
    [self.tableView setBackgroundColor:customTint];
    [self.view setBackgroundColor:customTint];
    customCheckColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"separatorColor"]];
    bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorDict[@"bgColor"]];
    [self.tableView setSeparatorColor:customCheckColor];
    contrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:customTint isFlat:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : contrastColor}];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : contrastColor}];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _updateCellselection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(delegate){
        return [[self _colors]count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *color = [self _colors][indexPath.row];
    cell.textLabel.text = color[@"name"];
    cell.tintColor = customCheckColor;
    cell.backgroundColor = customTint;
    [cell.textLabel setTextColor:contrastColor];
    UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
    [bgView setBackgroundColor:bgColor];
    cell.selectedBackgroundView = bgView;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    [self _setSelectedIndex:(int)row];
    [self _updateCellselection];
    
    if ([delegate respondsToSelector:@selector(colorSelectionController:didSelectColorAtIndex:)]) {
        [delegate colorSelectionController:self didSelectColorAtIndex:_selectedIndex];
    }
}

#pragma mark - Internal

- (NSInteger)_selectedIndex
{
    return _selectedIndex;
}

- (void)_setSelectedIndex:(int)theIndex
{
    _selectedIndex = theIndex;
}

- (void)_updateCellselection
{
    NSArray *cells = [self.tableView visibleCells];
    int n = (int)[cells count];
    for(int i=0; i<n; i++)
    {
        UITableViewCell *cell = [cells objectAtIndex:i];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:[self _selectedIndex] inSection:0];
    
    UITableViewCell *cell;
    cell = [self.tableView cellForRowAtIndexPath:path];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.accessoryView.tintColor = customCheckColor;
    cell.tintColor = customCheckColor;
    cell.backgroundColor = customTint;
    
    UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
    [bgView setBackgroundColor:bgColor];
    cell.selectedBackgroundView = bgView;
    
    [cell.detailTextLabel setTextColor:contrastColor];
    [cell.textLabel setTextColor:contrastColor];
    [cell setSelected:NO animated:YES];
}

- (NSArray*)_colors
{
    return (NSArray*)[delegate performSelector:@selector(colors)];
}


@end
