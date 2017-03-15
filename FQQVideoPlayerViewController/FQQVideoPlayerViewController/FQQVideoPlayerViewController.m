//
//  FQQVideoPlayerViewController.m
//  FQQVideoPlayerViewController
//
//  Created by 冯清泉 on 2017/3/14.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import "FQQVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BottomView.h"

typedef NS_ENUM(NSInteger, PlayerStatu){
    None,
    End,
    Play,
    Pause
};

@interface FQQVideoPlayerViewController () <BottomViewDelegate>

@property (nonatomic) CGFloat duration;
@property (nonatomic) CGFloat fps;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) id playerObserve;
@property (nonatomic) BottomView *bottomView;
@property (nonatomic) PlayerStatu playerStatu;
@property (nonatomic) BOOL isSliding;
@property (nonatomic) UITapGestureRecognizer *tap;

@end

@implementation FQQVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //如果不是ios10.1
    if(![self isIOS10_1]){
        [self initAVPlayer];
    }
    
    [self initBottomView];
}

- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    if([self isIOS10_1]){
        [self initAVPlayer];
        [self.view bringSubviewToFront:_bottomView];
    }
    [_player play];
    _playerStatu = Play;
}

- (void)initAVPlayer{
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:_url];
    _duration = CMTimeGetSeconds(item.asset.duration);
    _fps = [[[item.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
    _player = [[AVPlayer alloc]initWithPlayerItem:item];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    layer.frame = self.view.bounds;
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:layer];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playDidFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    
    __weak typeof(self) weakSelf = self;
    CMTime interval = _duration > 60 ? CMTimeMake(1, 1) : CMTimeMake(1, 30);
    _playerObserve = [_player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if(!weakSelf.isSliding){
            CGFloat currentTime = CMTimeGetSeconds(time);
            NSString *timeText = [NSString stringWithFormat:@"%@/%@", [weakSelf convert:currentTime], [weakSelf convert:weakSelf.duration]];
            weakSelf.bottomView.timeLabel.text = timeText;
            
            weakSelf.bottomView.slider.value = currentTime / weakSelf.duration;
        }
    }];
}

- (void)initBottomView{
    _bottomView = [[[NSBundle mainBundle]loadNibNamed:@"BottomView" owner:self options:nil]firstObject];
    _bottomView.frame = CGRectMake(0, 667 - 125, 375, 125);
    _bottomView.delegate = self;
    [self.view addSubview:_bottomView];

    [_bottomView.slider addTarget:self action:@selector(handleTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_bottomView.slider addTarget:self action:@selector(handleSlide:) forControlEvents:UIControlEventValueChanged];
    [_bottomView.slider addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.slider addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [_tap setNumberOfTouchesRequired:1];
    [_bottomView.slider addGestureRecognizer:_tap];
}

#pragma mark - SliederAction
- (void)handleTouchDown:(UISlider *)slider{
    NSLog(@"TouchDown");
    _tap.enabled = NO;
    _isSliding = YES;
    if(_playerStatu == Play){
        [_player pause];
    }
}

- (void)handleTouchUp:(UISlider *)slider{
    NSLog(@"TouchUp");
    _tap.enabled = YES;
    _isSliding = NO;
    if(_playerStatu == Play){
        [_player play];
    }
}

- (void)handleSlide:(UISlider *)slider{
    CMTime time = CMTimeMakeWithSeconds(_duration * slider.value, _fps);
    
    NSString *timeText = [NSString stringWithFormat:@"%@/%@", [self convert:_duration * slider.value], [self convert:_duration]];
    _bottomView.timeLabel.text = timeText;
    
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer{
    NSLog(@"Tap");
    CGPoint touchPoint = [recognizer locationInView:_bottomView.slider];
    CGFloat value = touchPoint.x / CGRectGetWidth(_bottomView.slider.frame);
    [_bottomView.slider setValue:value animated:YES];
    
    if(_playerStatu == Play){
        [_player pause];
    }
    CMTime time = CMTimeMakeWithSeconds(_duration * value, _fps);
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if(_playerStatu == Play){
            [_player play];
        }
    }];
}

- (void)playDidFinished:(NSNotification *)notification{
    [_bottomView.playButton setBackgroundImage:[UIImage imageNamed:@"btn_video_play"] forState:UIControlStateNormal];
    [_player pause];
    _playerStatu = End;
}

- (void)play{
    if(_playerStatu == End){
        [_player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [_bottomView.playButton setBackgroundImage:[UIImage imageNamed:@"btn_video_stop"] forState:UIControlStateNormal];
            [_player play];
            _playerStatu = Play;
        }];
    }else if(_playerStatu == Play){
        [_bottomView.playButton setBackgroundImage:[UIImage imageNamed:@"btn_video_play"] forState:UIControlStateNormal];
        [_player pause];
        _playerStatu = Pause;
    }else if(_playerStatu == Pause){
        [_bottomView.playButton setBackgroundImage:[UIImage imageNamed:@"btn_video_stop"] forState:UIControlStateNormal];
        [_player play];
        _playerStatu = Play;
    }
}

- (NSString *)convert:(CGFloat)time{
    int minute = time / 60;
    int second = time - minute * 60;
    NSString *minuteString;
    NSString *secondString;
    if(minute < 10){
        minuteString = [NSString stringWithFormat:@"0%d", minute];
    }else{
        minuteString = [NSString stringWithFormat:@"%d", minute];
    }
    if(second < 10){
        secondString = [NSString stringWithFormat:@"0%d", second];
    }else{
        secondString = [NSString stringWithFormat:@"%d", second];
    }
    return [NSString stringWithFormat:@"%@:%@", minuteString, secondString];
}

- (BOOL)isIOS10_1{
    //TODO
    return NO;
}

-(void)dealloc{
    [_player removeTimeObserver:_playerObserve];
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
