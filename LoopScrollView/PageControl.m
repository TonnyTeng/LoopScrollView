//
//  PageControl.m
//  DTLoopScrollView
//
//  Created by dengtao on 2017/6/7.
//  Copyright © 2017年 JingXian. All rights reserved.
//

#import "PageControl.h"

@implementation PageControl

- (instancetype)init {
    if (self = [super init]) {
        self.defersCurrentPageDisplay = YES;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p =    [touch locationInView:self];
    
    CGFloat px = p.x;
    CGFloat pw = self.frame.size.width / self.numberOfPages;
    NSInteger index = px / pw;
    
    if (self.valueChangedBlock && index != self.currentPage) {
        self.valueChangedBlock(index);
    } else {
        [self updateCurrentPageDisplay];
    }
}

- (void)setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    
    if (self.pageSize > 0) {
        for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
            UIImageView* subview = (UIImageView *)[self.subviews objectAtIndex:subviewIndex];
            CGSize size;
            size.height = self.pageSize;
            size.width = self.pageSize;
            [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y,
                                         size.width,size.height)];
            subview.clipsToBounds = YES;
            subview.layer.cornerRadius = size.width/2;
        }
    }
}

@end
