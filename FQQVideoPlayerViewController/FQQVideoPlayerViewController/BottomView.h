//
//  PlayViewHUD.h
//  1SecondEveryday
//
//  Created by ChenZhiqiang on 2017/2/27.
//  Copyright © 2017年 gzyzhyx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BottomViewDelegate

- (void)play;

@end

@interface BottomView : UIView

@property (nonatomic, weak) id<BottomViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end
