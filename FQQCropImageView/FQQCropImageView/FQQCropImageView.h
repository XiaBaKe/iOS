//
//  FQQCropImageView.h
//  FQQCropImageView
//
//  Created by 冯清泉 on 2017/3/14.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define TouchRectSide 40.0
#define MinBoxSide 100.0

@interface FQQCropImageView : UIView

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) CGRect imageViewOriginFrame;

@property (nonatomic) UIView *cropView;
@property (nonatomic) NSMutableArray<UIView *> *coverViews;
@property (nonatomic) NSMutableArray<UIView *> *decoraterViews;

@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGRect concer1;
@property (nonatomic) CGRect concer2;
@property (nonatomic) CGRect concer3;
@property (nonatomic) CGRect concer4;
@property (nonatomic) CGRect topBorder;
@property (nonatomic) CGRect leftBorder;
@property (nonatomic) CGRect rightBorder;
@property (nonatomic) CGRect buttomBorder;

- (instancetype)initWithImage:(UIImage *)image;
- (UIImage *)cropImage;
- (void)setTouchRects;
- (void)layoutDecoraterViews;
- (void)layoutCoverViews;

@end
