//
//  FQQNavViewController.h
//  FQQNavViewController
//
//  Created by 冯清泉 on 2017/3/13.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DURATION 0.2
#define NAV_WIDTH 250
#define GAP 50
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface FQQNavViewController : UIViewController

@property (nonatomic) BOOL didShown;
@property (nonatomic) UIView *navView;

- (void)showNav;
- (void)hideNav;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

@end
