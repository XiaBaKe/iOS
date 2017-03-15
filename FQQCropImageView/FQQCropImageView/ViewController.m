//
//  ViewController.m
//  FQQCropImageView
//
//  Created by 冯清泉 on 2017/3/14.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import "ViewController.h"
#import "FQQCropImageView.h"

@interface ViewController ()

@property (nonatomic) FQQCropImageView *cropImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _cropImageView = [[FQQCropImageView alloc]initWithImage:[UIImage imageNamed:@"教程3"]];
    [self.view addSubview:_cropImageView];
    [self.view sendSubviewToBack:_cropImageView];
}

- (IBAction)reflash:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        _cropImageView.imageView.frame = _cropImageView.imageViewOriginFrame;
        _cropImageView.cropView.frame = _cropImageView.imageViewOriginFrame;
        [_cropImageView layoutCoverViews];
        [_cropImageView layoutDecoraterViews];
        [_cropImageView setTouchRects];
    }];
}

- (IBAction)done:(id)sender {
    UIImage *image = [_cropImageView cropImage];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTouchesRequired = 1;
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:tap];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer{
    [recognizer.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
