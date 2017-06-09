//
//  LoadImageView.h
//  DTLoopScrollView
//
//  Created by dengtao on 2017/6/7.
//  Copyright © 2017年 JingXian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadImageView;

typedef void (^TapImageViewBlock)(LoadImageView *imageView);
typedef void (^ImageBlock)(UIImage *image);

@interface LoadImageView : UIImageView

@property (nonatomic, assign) BOOL animated;//下载图片动画 默认Yes

@property (nonatomic, assign) BOOL isCircle;//默认NO

@property (nonatomic, copy) ImageBlock completion;

@property (nonatomic, copy) TapImageViewBlock tapImageViewBlock;

@property (nonatomic, assign) NSUInteger attemptToReloadTimesForFailedURL;//下载失败次数

@property (nonatomic, assign) BOOL shouldAutoClipImageToViewSize;//是否自动将下载到的图片裁剪为UIImageView的size。默认为NO。

//异步下载图片
- (void)setImageWithURLString:(NSString *)url placeholderImage:(NSString *)placeholderImage;
- (void)setImageWithURLString:(NSString *)url placeholder:(UIImage *)placeholderImage;
- (void)setImageWithURLString:(NSString *)url
                  placeholder:(UIImage *)placeholderImage
                   completion:(void (^)(UIImage *image))completion;
- (void)setImageWithURLString:(NSString *)url
             placeholderImage:(NSString *)placeholderImage
                   completion:(void (^)(UIImage *image))completion;

- (void)cancelRequest;

+ (UIImage *)clipImage:(UIImage *)image toSize:(CGSize)size isScaleToMax:(BOOL)isScaleToMax;//等比例剪裁图片大小到指定的size

@end

@interface UIView (XT)

- (CGPoint)origin;
- (void)setOrigin:(CGPoint) point;

- (CGSize)size;
- (void)setSize:(CGSize) size;

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGFloat)tail;
- (void)setTail:(CGFloat)tail;

- (CGFloat)bottom;
- (void)setBottom:(CGFloat)bottom;

- (CGFloat)right;
- (void)setRight:(CGFloat)right;

@end
