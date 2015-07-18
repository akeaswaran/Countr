//
//  CountdownImageHeaderView.h
//  Countdown
//
//  Created by Akshay Easwaran on 7/17/15.
//  Copyright © 2015 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountdownImageHeaderView : UIView <UIScrollViewDelegate>
{
    NSArray *images;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
}

-(instancetype)initWithImages:(NSArray*)allImages size:(CGSize)size;
@end
