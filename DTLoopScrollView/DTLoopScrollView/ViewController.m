//
//  ViewController.m
//  DTLoopScrollView
//
//  Created by dengtao on 2017/6/6.
//  Copyright © 2017年 JingXian. All rights reserved.
//

#import "ViewController.h"
#import "LoopScrollView.h"

@interface ViewController ()

@property (nonatomic, weak) LoopScrollView *loopView;

@end

@implementation ViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.loopView startTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.loopView pauseTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.loopView];
    
}

- (LoopScrollView *)loopView{

    if (_loopView == nil) {
        
        NSArray *images = @[@"http://img2.imgtn.bdimg.com/it/u=2209590589,3022462895&fm=26&gp=0.jpg",
                            @"http://img5.imgtn.bdimg.com/it/u=3040438212,3534222189&fm=26&gp=0.jpg",
                            ];
        CGFloat width = self.view.frame.size.width;
        _loopView = [LoopScrollView loopScrollViewWithFrame:CGRectMake(0, 64, width, 200) imageUrls:images timeInterval:2 didSelect:^(NSInteger atIndex) {
            
            NSLog(@"点击第%ld张图片",atIndex);
        } didScroll:^(NSInteger toIndex) {
            
            NSLog(@"滚动到第%ld张图片",toIndex);
        }];
        _loopView.placeholder = [UIImage imageNamed:@"1-1"];
        _loopView.shouldAutoClipImageToViewSize = NO;
//        _loopView.alignment = kPageControlAlignRight;//kPageControlAlignCenter;
//        _loopView.adTitles = titles;
        
        _loopView.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _loopView.pageControl.pageSize = 10;
        
        _loopView.imageContentMode = UIViewContentModeScaleAspectFill;
        NSLog(@"size: %llu", [_loopView imagesCacheSize]);
        [_loopView clearImagesCache];
        NSLog(@"size: %llu", [_loopView imagesCacheSize]);
        
    }
    return _loopView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
