//
//  FQQNavViewController.m
//  FQQNavViewController
//
//  Created by 冯清泉 on 2017/3/13.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import "FQQNavViewController.h"

@interface FQQNavViewController ()

@property (nonatomic) BOOL isMoving;

@end

@implementation FQQNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    _didShown = NO;
    
    _navView = [[UIView alloc]initWithFrame:CGRectMake(-NAV_WIDTH, 0, NAV_WIDTH, SCREEN_HEIGHT)];
    _navView.backgroundColor = [UIColor redColor];
    self.view.hidden = YES;
    [self.view addSubview:_navView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer{
    CGPoint touchPoint = [recognizer locationInView:self.view];
    if(_didShown && touchPoint.x > NAV_WIDTH){
        [self hideNav];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
    CGPoint touchPoint = [recognizer locationInView:self.view];
    CGPoint transPoint = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        if(!_didShown && touchPoint.x < 50 && velocity.x > 0){
            _isMoving = YES;
            self.view.hidden = NO;
        }else if(_didShown && velocity.x < 0){
            _isMoving = YES;
        }
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        if(_isMoving){
            CGRect nextFrame = _navView.frame;
            nextFrame.origin.x += transPoint.x;
            if(CGRectGetMinX(nextFrame) > 0) nextFrame.origin.x = 0;
            if(CGRectGetMinX(nextFrame) < -NAV_WIDTH) nextFrame.origin.x = -NAV_WIDTH;
            _navView.frame = nextFrame;
            
            CGFloat alpha = CGRectGetMaxX(nextFrame) / NAV_WIDTH * 0.5;
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
            
            [recognizer setTranslation:CGPointZero inView:self.view];
        }else{
            return;
        }
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        CGFloat maxX = CGRectGetMaxX(_navView.frame);
        if(_didShown){
            if(maxX > NAV_WIDTH - GAP){
                [self showNav];
            }else{
                [self hideNav];
            }
        }else{
            if(maxX < GAP){
                [self hideNav];
            }else{
                [self showNav];
            }
        }
    }
}

- (void)showNav{
    self.view.hidden = NO;
    [UIView animateWithDuration:DURATION animations:^{
        [self setNavX:0];
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    } completion:^(BOOL finished) {
        _isMoving = NO;
        _didShown = YES;
    }];
}

- (void)hideNav{
    [UIView animateWithDuration:DURATION animations:^{
        [self setNavX:-NAV_WIDTH];
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        _isMoving = NO;
        _didShown = NO;
        self.view.hidden = YES;
    }];
}

- (void)setNavX:(CGFloat)x{
    CGRect frame = _navView.frame;
    frame.origin.x = x;
    _navView.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
