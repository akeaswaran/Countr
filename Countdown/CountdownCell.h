//
//  CountdownCell.h
//  Countdown
//
//  Created by Akshay Easwaran on 4/30/15.
//  Copyright (c) 2015 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountdownCell : UITableViewCell
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
