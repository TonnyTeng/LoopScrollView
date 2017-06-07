//
//  PageControl.h
//  DTLoopScrollView
//
//  Created by dengtao on 2017/6/7.
//  Copyright © 2017年 JingXian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PageControlValueChangedBlock)(NSInteger clickAtIndex);

@interface PageControl : UIPageControl

@property (nonatomic, assign) CGFloat pageSize;

@property (nonatomic, copy) PageControlValueChangedBlock valueChangedBlock;

@end
