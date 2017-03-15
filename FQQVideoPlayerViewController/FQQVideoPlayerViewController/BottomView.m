//
//  PlayViewHUD.m
//  1SecondEveryday
//
//  Created by ChenZhiqiang on 2017/2/27.
//  Copyright © 2017年 gzyzhyx. All rights reserved.
//

#import "BottomView.h"

@implementation BottomView

- (void)awakeFromNib{
    [super awakeFromNib];
    [_slider setThumbImage:[UIImage imageNamed:@"tab_progress_dot"] forState:UIControlStateNormal];
}

- (IBAction)play:(id)sender {
    [_delegate play];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
