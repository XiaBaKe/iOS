//
//  ViewController.m
//  FQQWebViewController
//
//  Created by 冯清泉 on 2017/3/13.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import "ViewController.h"
#import "FQQWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)push:(id)sender {
    FQQWebViewController *vc = [FQQWebViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
