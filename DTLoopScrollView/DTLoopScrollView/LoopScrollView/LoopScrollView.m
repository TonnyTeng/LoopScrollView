
//
//  LoopScrollView.m
//  DTLoopScrollView
//
//  Created by dengtao on 2017/6/6.
//  Copyright © 2017年 JingXian. All rights reserved.
//

#import "LoopScrollView.h"
#import <objc/message.h>

NSString * const kCellIdentifier = @"ReuseCellIdentifier";

@interface CollectionCell : UICollectionViewCell

@property (nonatomic, strong) LoadImageView *imageView;
@property (nonatomic, strong) UILabel          *titleLabel;
@property (nonatomic, assign) BOOL             isDragging;

@end

@implementation CollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.imageView = [[LoadImageView alloc] init];
        [self addSubview:self.imageView];
        self.imageView.isCircle = YES;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.titleLabel.hidden = YES;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.titleLabel];
        self.titleLabel.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.titleLabel.frame = CGRectMake(0, self.height - 30, self.width, 30);
    self.titleLabel.hidden = self.titleLabel.text.length > 0 ? NO : YES;
}

@end

@interface LoopScrollView()<UICollectionViewDataSource, UICollectionViewDelegate> {
    PageControl *_pageControl;
}

@property (nonatomic, copy) LoopScrollViewDidSelectItemBlock didSelectItemBlock;
@property (nonatomic, copy) LoopScrollViewDidScrollBlock didScrollBlock;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, assign) CFRunLoopTimerRef timer;
@property (nonatomic, assign) NSInteger totalPageCount;
@property (nonatomic, assign) NSInteger previousPageIndex;
@property (nonatomic, assign) NSTimeInterval timeInterval;


@end

@implementation LoopScrollView

- (void)dealloc {
    //  NSLog(@"hybloopscrollview dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:[UIApplication sharedApplication]
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}

- (void)pauseTimer {
    if (self.timer) {
        CFRunLoopTimerInvalidate(self.timer);
        CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), self.timer, kCFRunLoopCommonModes);
    }
}

- (void)startTimer {
    [self configTimer];
}

- (PageControl *)pageControl {
    return _pageControl;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    [super setBackgroundColor:backgroundColor];
    self.collectionView.backgroundColor = backgroundColor;
}

- (void)removeFromSuperview {
    [self pauseTimer];
    
    [super removeFromSuperview];
}

+ (instancetype)loopScrollViewWithFrame:(CGRect)frame
                              imageUrls:(NSArray *)imageUrls
                           timeInterval:(NSTimeInterval)timeInterval
                              didSelect:(LoopScrollViewDidSelectItemBlock)didSelect
                              didScroll:(LoopScrollViewDidScrollBlock)didScroll {
    LoopScrollView *loopView = [[LoopScrollView alloc] initWithFrame:frame];
    loopView.imageUrls = imageUrls;
    loopView.timeInterval = timeInterval;
    loopView.didScrollBlock = didScroll;
    loopView.didSelectItemBlock = didSelect;
    
    return loopView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.timeInterval = 5.0;
        self.alignment = kPageControlAlignCenter;
        [self configCollectionView];
        self.imageContentMode = UIViewContentModeScaleToFill;
        
        [[NSNotificationCenter defaultCenter] addObserver:[UIApplication sharedApplication]
                                                 selector:NSSelectorFromString(@"clearCache")
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.layout.itemSize = frame.size;
}

- (void)configCollectionView {
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout .itemSize = self.bounds.size;
    self.layout .minimumLineSpacing = 0;
    self.layout .scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame
                                             collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView  registerClass:[CollectionCell class]
             forCellWithReuseIdentifier:kCellIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self addSubview:self.collectionView];
}

- (void)configTimer {
    if (self.imageUrls.count <= 1) {
        return;
    }
    
    if (self.timer) {
        CFRunLoopTimerInvalidate(self.timer);
        CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), self.timer, kCFRunLoopCommonModes);
    }
    
    __weak __typeof(self) weakSelf = self;
    CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + _timeInterval, _timeInterval, 0, 0, ^(CFRunLoopTimerRef timer) {
        [weakSelf autoScroll];
    });
    
    self.timer = timer;
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
}

- (void)setPageControlEnabled:(BOOL)pageControlEnabled {
    if (_pageControlEnabled != pageControlEnabled) {
        _pageControlEnabled = pageControlEnabled;
        
        if (_pageControlEnabled) {
            __weak __typeof(self) weakSelf = self;
            self.pageControl.valueChangedBlock = ^(NSInteger clickedAtIndex) {
                // 往左
                NSInteger count = clickedAtIndex - weakSelf.pageControl.currentPage;
                
                NSInteger toIndex = count + self.previousPageIndex;
                NSIndexPath *indexPath = nil;
                if (toIndex == weakSelf.totalPageCount) {
                    toIndex = weakSelf.totalPageCount * 0.5;
                    
                    // scroll to the middle without animation, and scroll to middle with animation, so that it scrolls
                    // more smoothly.
                    indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                    [weakSelf.collectionView scrollToItemAtIndexPath:indexPath
                                                    atScrollPosition:UICollectionViewScrollPositionNone
                                                            animated:NO];
                } else {
                    indexPath = [NSIndexPath indexPathForItem:count > 0 ? toIndex - 1 : toIndex + 1 inSection:0];
                    [weakSelf.collectionView scrollToItemAtIndexPath:indexPath
                                                    atScrollPosition:UICollectionViewScrollPositionNone
                                                            animated:NO];
                    
                    indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                }
                
                [weakSelf.collectionView scrollToItemAtIndexPath:indexPath
                                                atScrollPosition:UICollectionViewScrollPositionNone
                                                        animated:YES];
                
                [weakSelf.pageControl updateCurrentPageDisplay];
            };
        } else {
            self.pageControl.valueChangedBlock = nil;
        }
    }
}

- (void)configPageControl {
    if (self.pageControl == nil) {
        _pageControl = [[PageControl alloc] init];
        self.pageControl.hidesForSinglePage = YES;
        [self addSubview:self.pageControl];
        self.pageControlEnabled = YES;
    }
    
    [self bringSubviewToFront:self.pageControl];
    self.pageControl.numberOfPages = self.imageUrls.count;
    CGSize size = [self.pageControl sizeForNumberOfPages:self.imageUrls.count + 2];
    self.pageControl.size = size;
    
    if (self.alignment == kPageControlAlignCenter) {
        self.pageControl.x = (self.width - self.pageControl.width) / 2.0;
    } else if (self.alignment == kPageControlAlignRight) {
        self.pageControl.x = self.width;
    }
    self.pageControl.y = self.height - self.pageControl.height + 5;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    
    [self configTimer];
}

- (void)autoScroll {
    
    NSInteger curIndex = (self.collectionView.contentOffset.x + self.layout.itemSize.width * 0.5) / self.layout.itemSize.width;
    NSInteger toIndex = curIndex + 1;
    
    NSIndexPath *indexPath = nil;
    if (toIndex == self.totalPageCount) {
        toIndex = self.totalPageCount * 0.5;
        
        // scroll to the middle without animation, and scroll to middle with animation, so that it scrolls
        // more smoothly.
        indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:NO];
    } else {
        indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
    }
    
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:YES];
    
}

- (void)setImageUrls:(NSArray *)imageUrls {
    if (![imageUrls isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if (imageUrls == nil || imageUrls.count == 0) {
        self.collectionView.scrollEnabled = NO;
        [self pauseTimer];
        self.totalPageCount = 0;
        [self.collectionView reloadData];
        return;
    }
    
    if (_imageUrls != imageUrls) {
        _imageUrls = imageUrls;
        
        if (imageUrls.count > 1) {
            self.totalPageCount = imageUrls.count * 50;
            [self configTimer];
            [self configPageControl];
            self.collectionView.scrollEnabled = YES;
        } else {
            // If there is only one page, stop the timer and make scroll enabled to be NO.
            [self pauseTimer];
            
            self.totalPageCount = 1;
            [self configPageControl];
            self.collectionView.scrollEnabled = NO;
        }
        
        [self.collectionView reloadData];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.totalPageCount == 0) {
        return;
    }
    
    self.layout.itemSize = self.size;
    
    self.collectionView.frame = self.bounds;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.totalPageCount * 0.5
                                                 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
    
    [self configPageControl];
}

- (void)setAlignment:(PageControlAlignment)alignment {
    if (_alignment != alignment) {
        _alignment = alignment;
        
        [self configPageControl];
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.totalPageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                                        forIndexPath:indexPath];
    
    // 先取消之前的请求
    LoadImageView *preImageView = cell.imageView;
    cell.imageView.contentMode = self.imageContentMode;
    preImageView.shouldAutoClipImageToViewSize = self.shouldAutoClipImageToViewSize;
    
    if ([preImageView isKindOfClass:[LoadImageView class]]) {
        [preImageView cancelRequest];
    }
    
    NSInteger itemIndex = indexPath.item % self.imageUrls.count;
    if (itemIndex < self.imageUrls.count) {
        
        NSString *urlString = self.imageUrls[itemIndex];
        if ([urlString isKindOfClass:[UIImage class]]) {
            cell.imageView.image = (UIImage *)urlString;
        } else if ([urlString hasPrefix:@"http://"]
                   || [urlString hasPrefix:@"https://"]
                   || [urlString rangeOfString:@"/"].location != NSNotFound) {
            [cell.imageView setImageWithURLString:urlString placeholder:self.placeholder];
        } else {
            cell.imageView.image = [UIImage imageNamed:urlString];
        }
    }
    
    if (self.alignment == kPageControlAlignRight && itemIndex < self.adTitles.count) {
        cell.titleLabel.text = [NSString stringWithFormat:@"   %@", self.adTitles[itemIndex]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.totalPageCount == 0) {
        return;
    }
    
    if (self.didSelectItemBlock) {
        self.didSelectItemBlock(indexPath.item % self.imageUrls.count);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.totalPageCount == 0) {
        return;
    }
    
    int itemIndex = (scrollView.contentOffset.x +
                     self.collectionView.width * 0.5) / self.collectionView.width;
    itemIndex = itemIndex % self.imageUrls.count;
    _pageControl.currentPage = itemIndex;
    
    // record
    self.previousPageIndex = itemIndex;
    
    CGFloat x = scrollView.contentOffset.x - self.collectionView.width;
    NSUInteger index = fabs(x) / self.collectionView.width;
    CGFloat fIndex = fabs(x) / self.collectionView.width;
    
    if (self.didScrollBlock && fabs(fIndex - (CGFloat)index) <= 0.00001) {
        self.didScrollBlock(itemIndex);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

- (void)clearImagesCache {
    // 放在了非公开的扩展中，但是方法是存在的
    if ([[UIApplication sharedApplication] respondsToSelector:NSSelectorFromString(@"s_clearDiskCaches")]) {
        
        ((void (*)(id, SEL))objc_msgSend)([UIApplication sharedApplication],
                                          NSSelectorFromString(@"s_clearDiskCaches"));
    }
}

- (unsigned long long)imagesCacheSize {
    NSString *directoryPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/LoopScollViewImages"];
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                          error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    
    return total;
}


@end
