//
//  LoopScrollView.h
//  DTLoopScrollView
//
//  Created by dengtao on 2017/6/6.
//  Copyright © 2017年 JingXian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageControl.h"
#import "LoadImageView.h"

typedef NS_ENUM(NSInteger, PageControlAlignment) {

    kPageControlAlignCenter = 1 << 1,
    kPageControlAlignRight  = 1 << 2
};

typedef NS_ENUM(NSUInteger, FlowLayoutType) {
    kFlowLayoutTypeDefault,
    kFlowLayoutTypeScaleHorizontal
};

typedef void (^LoopScrollViewDidSelectItemBlock)(NSInteger atIndex);
typedef void (^LoopScrollViewDidScrollBlock)(NSInteger toIndex);

@interface LoopScrollView : UIView

@property (nonatomic, strong) UIImage *placeholder;

@property (nonatomic, assign) UIViewContentMode imageContentMode;

@property (nonatomic, strong, readonly) PageControl *pageControl;

@property (nonatomic, assign) PageControlAlignment alignment;


@property (nonatomic, strong) NSArray *imageUrls;


@property (nonatomic, assign) BOOL pageControlEnabled;

@property (nonatomic, strong) NSArray *adTitles;

@property (nonatomic, assign) BOOL shouldAutoClipImageToViewSize;


+ (instancetype)loopScrollViewWithFrame:(CGRect)frame
                              imageUrls:(NSArray *)imageUrls
                           timeInterval:(NSTimeInterval)timeInterval
                              didSelect:(LoopScrollViewDidSelectItemBlock)didSelect
                              didScroll:(LoopScrollViewDidScrollBlock)didScroll;

- (void)pauseTimer;

- (void)startTimer;

- (void)clearImagesCache;

- (unsigned long long)imagesCacheSize;


@end
