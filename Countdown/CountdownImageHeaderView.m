//
//  CountdownImageHeaderView.m
//  Countdown
//
//  Created by Akshay Easwaran on 7/17/15.
//  Copyright © 2015 Akshay Easwaran. All rights reserved.
//

#import "CountdownImageHeaderView.h"

@implementation CountdownImageHeaderView

-(instancetype)initWithImages:(NSArray *)allImages size:(CGSize)size {
    self = [super init];
    if (self) {
        
        assert(allImages);
        images = allImages;
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        self.frame = frame;
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setPagingEnabled:YES];
        [scrollView setDelegate:self];
        [scrollView setScrollEnabled:YES];
        [scrollView setCanCancelContentTouches:YES];
        [scrollView setUserInteractionEnabled:YES];
        [scrollView setDelaysContentTouches:YES];
        [scrollView setDirectionalLockEnabled:YES];
        
        for (int i = 0; i < images.count; i++) {
            UIImage *image = images[i];
            [scrollView addSubview:[self _createPageWithImage:image atIndex:i]];
        }
        
        scrollView.contentSize = CGSizeMake(size.width * images.count, size.height);
        [self addSubview:scrollView];
        
        if (images.count > 1) {
            pageControl = [[UIPageControl alloc] init];
            [pageControl setNumberOfPages:images.count];
            [pageControl setCenter:CGPointMake(scrollView.center.x, size.height - 10 - pageControl.frame.size.height)];
            [self addSubview:pageControl];
        }
        
        self.alpha = 0.0;
    }
    return self;
}

-(UIView *)_createPageWithImage:(UIImage*)image atIndex:(NSInteger)index {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setClipsToBounds:YES];
    [imageView.layer setMasksToBounds:YES];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setFrame:CGRectMake(scrollView.frame.size.width * index, imageView.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    return imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if ([sender isEqual:scrollView] && images.count > 1) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;
    }
}

@end
