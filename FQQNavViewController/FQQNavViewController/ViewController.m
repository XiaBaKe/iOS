//
//  ViewController.m
//  FQQNavViewController
//
//  Created by 冯清泉 on 2017/3/13.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import "ViewController.h"
#import "FQQNavViewController.h"

@interface ViewController ()

@property (nonatomic) FQQNavViewController *navVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blueColor];
    
    UIButton *navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navButton setBackgroundImage:[UIImage imageNamed:@"btn_leftbar_default"] forState:UIControlStateNormal];
    navButton.frame = CGRectMake(0, 20, 44, 44);
    [navButton addTarget:self action:@selector(navButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navButton];
    
    _navVC = [FQQNavViewController new];
    _navVC.view.frame = self.view.bounds;
    [self.view addSubview:_navVC.view];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)navButtonClick:(UIButton *)sender{
    [_navVC showNav];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
    [_navVC handlePan:recognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
