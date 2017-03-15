//
//  FQQCropImageView.m
//  FQQCropImageView
//
//  Created by 冯清泉 on 2017/3/14.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import "FQQCropImageView.h"

typedef NS_ENUM(NSInteger, PanType){
    PanNone,
    PanImage,
    PanCropView,
    PanCropViewConcer1,
    PanCropViewConcer2,
    PanCropViewConcer3,
    PanCropViewConcer4,
    PanCropViewTopBorder,
    PanCropViewButtomBorder,
    PanCropViewLeftBorder,
    PanCropViewRightBorder
};

@interface FQQCropImageView()

@property (nonatomic) PanType panType;
@property (nonatomic) CGRect cropViewPreFrame;

@end

@implementation FQQCropImageView

- (instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self setImageViewWithImage:image];
        [self initCropView];
        [self initCoverViews];
        [self setTouchRects];
        [self bindGestureRecognizer];
        _imageViewOriginFrame = _imageView.frame;
    }
    return self;
}

- (UIImage *)cropImage{
    CGRect imageFrame = _imageView.frame;
    CGRect cropFrame = _cropView.frame;
    CGRect targetFrame = CGRectMake(CGRectGetMinX(cropFrame) - CGRectGetMinX(imageFrame), CGRectGetMinY(cropFrame) - CGRectGetMinY(imageFrame), CGRectGetWidth(cropFrame), CGRectGetHeight(cropFrame));
    float scale = _imageView.image.size.width / imageFrame.size.width;
    targetFrame.origin.x *= scale;
    targetFrame.origin.y *= scale;
    targetFrame.size.width *= scale;
    targetFrame.size.height *= scale;
    return [UIImage imageWithCGImage:CGImageCreateWithImageInRect(_imageView.image.CGImage, targetFrame)];
}

#pragma mark - Init
- (void)setImageViewWithImage:(UIImage *)image{
    CGFloat ratio = image.size.width / image.size.height;
    CGFloat width = SCREEN_WIDTH - 100;
    CGFloat height = width / ratio;
    if(height > SCREEN_HEIGHT - 164){
        height = SCREEN_HEIGHT - 164;
        width = height * ratio;
    }
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    _imageView.image = image;
    _imageView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 32);
    [self addSubview:_imageView];
}

- (void)initCropView{
    _cropView = [[UIView alloc]initWithFrame:_imageView.frame];
    _cropView.layer.borderWidth = 0.5;
    _cropView.layer.borderColor = [UIColor greenColor].CGColor;
    _decoraterViews = [NSMutableArray arrayWithCapacity:8];
    for(int i = 0; i < 8; i++){
        UIView *decoraterView = [self getDecoraterView];
        [_decoraterViews addObject:decoraterView];
        [_cropView addSubview:decoraterView];
    }
    [self layoutDecoraterViews];
    [self addSubview:_cropView];
}

- (void)initCoverViews{
    _coverViews = [NSMutableArray arrayWithCapacity:4];
    for(int i = 0; i < 4; i++){
        UIView *coverView = [self getCoverView];
        [_coverViews addObject:coverView];
        [self addSubview:coverView];
        [self sendSubviewToBack:coverView];
    }
    [self layoutCoverViews];
}

- (UIView *)getDecoraterView{
    UIView *decoraterView = [UIView new];
    decoraterView.backgroundColor = [UIColor greenColor];
    return decoraterView;
}

- (UIView *)getCoverView{
    UIView *coverView = [UIView new];
    coverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    return coverView;
}

#pragma mark - Layout
- (void)layoutDecoraterViews{
    _decoraterViews[0].frame = CGRectMake(-3, -3, 18, 3);
    _decoraterViews[1].frame = CGRectMake(-3, 0, 3, 15);
    _decoraterViews[2].frame = CGRectMake(_cropView.frame.size.width - 15, -3, 18, 3);
    _decoraterViews[3].frame = CGRectMake(_cropView.frame.size.width, 0, 3, 15);
    _decoraterViews[4].frame = CGRectMake(-3, _cropView.frame.size.height, 18, 3);
    _decoraterViews[5].frame = CGRectMake(-3, _cropView.frame.size.height - 15, 3, 15);
    _decoraterViews[6].frame = CGRectMake(_cropView.frame.size.width - 15, _cropView.frame.size.height, 18, 3);
    _decoraterViews[7].frame = CGRectMake(_cropView.frame.size.width, _cropView.frame.size.height - 15, 3, 15);
}

- (void)layoutCoverViews{
    CGRect frame = _cropView.frame;
    _coverViews[0].frame = CGRectMake(0, 0, CGRectGetMaxX(frame), CGRectGetMinY(frame));
    _coverViews[1].frame = CGRectMake(0, CGRectGetMinY(frame), CGRectGetMinX(frame), SCREEN_HEIGHT - CGRectGetMinY(frame));
    _coverViews[2].frame = CGRectMake(CGRectGetMaxX(frame), 0, SCREEN_WIDTH - CGRectGetMaxX(frame), CGRectGetMaxY(frame));
    _coverViews[3].frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame), SCREEN_WIDTH - CGRectGetMinX(frame), SCREEN_HEIGHT - CGRectGetMaxY(frame));
}

- (void)setTouchRects{
    CGPoint point = _cropView.frame.origin;
    
    _concer1 = CGRectMake(point.x - TouchRectSide / 2, point.y - TouchRectSide / 2, TouchRectSide, TouchRectSide);
    point.x += _cropView.frame.size.width;
    _concer2 = CGRectMake(point.x - TouchRectSide / 2, point.y - TouchRectSide / 2, TouchRectSide, TouchRectSide);
    point.y += _cropView.frame.size.height;
    _concer4 = CGRectMake(point.x - TouchRectSide / 2, point.y - TouchRectSide / 2, TouchRectSide, TouchRectSide);
    point.x -= _cropView.frame.size.width;
    _concer3 = CGRectMake(point.x - TouchRectSide / 2, point.y - TouchRectSide / 2, TouchRectSide, TouchRectSide);
    
    _topBorder = CGRectMake(_concer1.origin.x + _concer1.size.width, _concer1.origin.y, _cropView.frame.size.width - TouchRectSide, TouchRectSide);
    CGRect temp = _topBorder;
    temp.origin.y += _cropView.frame.size.height;
    _buttomBorder = temp;
    _leftBorder = CGRectMake(_concer1.origin.x, _concer1.origin.y + _concer1.size.height, TouchRectSide, _cropView.frame.size.height - TouchRectSide);
    temp = _leftBorder;
    temp.origin.x += _cropView.frame.size.width;
    _rightBorder = temp;
    
    _cropRect = CGRectMake(self.concer1.origin.x + TouchRectSide, self.concer1.origin.y + TouchRectSide, _cropView.frame.size.width - TouchRectSide, _cropView.frame.size.height - TouchRectSide);
}

#pragma mark - GestureRecognizer
- (void)bindGestureRecognizer{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:pinch];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        CGPoint touchPoint = [recognizer locationInView:self];
        _cropViewPreFrame = _cropView.frame;
        if(CGRectContainsPoint(_cropRect, touchPoint)) _panType = PanCropView;
        else if(CGRectContainsPoint(_concer1, touchPoint)) _panType = PanCropViewConcer1;
        else if(CGRectContainsPoint(_concer2, touchPoint)) _panType = PanCropViewConcer2;
        else if(CGRectContainsPoint(_concer3, touchPoint)) _panType = PanCropViewConcer3;
        else if(CGRectContainsPoint(_concer4, touchPoint)) _panType = PanCropViewConcer4;
        else if(CGRectContainsPoint(_topBorder, touchPoint)) _panType = PanCropViewTopBorder;
        else if(CGRectContainsPoint(_buttomBorder, touchPoint)) _panType = PanCropViewButtomBorder;
        else if(CGRectContainsPoint(_leftBorder, touchPoint)) _panType = PanCropViewLeftBorder;
        else if(CGRectContainsPoint(_rightBorder, touchPoint)) _panType = PanCropViewRightBorder;
        else _panType = PanImage;
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        CGRect nextFrame;
        CGPoint transPoint;
        if(_panType == PanImage){
            transPoint = [recognizer translationInView:self];
            nextFrame = _imageView.frame;
            nextFrame.origin.x += transPoint.x;
            nextFrame.origin.y += transPoint.y;
            
            if(CGRectGetMinY(nextFrame) > CGRectGetMinY(_cropViewPreFrame)) nextFrame.origin.y = CGRectGetMinY(_cropViewPreFrame);
            if(CGRectGetMinX(nextFrame) > CGRectGetMinX(_cropViewPreFrame)) nextFrame.origin.x = CGRectGetMinX(_cropViewPreFrame);
            if(CGRectGetMaxX(nextFrame) < CGRectGetMaxX(_cropViewPreFrame)) nextFrame.origin.x = CGRectGetMaxX(_cropViewPreFrame) - CGRectGetWidth(nextFrame);
            if(CGRectGetMaxY(nextFrame) < CGRectGetMaxY(_cropViewPreFrame)) nextFrame.origin.y = CGRectGetMaxY(_cropViewPreFrame) - CGRectGetHeight(nextFrame);
            
            _imageView.frame = nextFrame;
            [recognizer setTranslation:CGPointZero inView:self];
        }else{
            transPoint = [recognizer translationInView:self];
            nextFrame = _cropView.frame;
            
            CGFloat maxTop = MAX(64, CGRectGetMinY(_imageView.frame));
            CGFloat maxLeft = MAX(0, CGRectGetMinX(_imageView.frame));
            CGFloat minRight = MIN(SCREEN_WIDTH, CGRectGetMaxX(_imageView.frame));
            CGFloat minButtom = MIN(SCREEN_HEIGHT, CGRectGetMaxY(_imageView.frame));
            
            if(_panType == PanCropView){
                nextFrame.origin.x += transPoint.x;
                nextFrame.origin.y += transPoint.y;
                
                if(CGRectGetMinY(nextFrame) < maxTop) nextFrame.origin.y = maxTop;
                if(CGRectGetMinX(nextFrame) < maxLeft) nextFrame.origin.x = maxLeft;
                if(CGRectGetMaxX(nextFrame) > minRight){
                    nextFrame.origin.x = minRight - CGRectGetWidth(_cropViewPreFrame);
                }
                if(CGRectGetMaxY(nextFrame) > minButtom){
                    nextFrame.origin.y = minButtom - CGRectGetHeight(_cropViewPreFrame);
                }
            }else if(_panType == PanCropViewConcer1){
                nextFrame.origin.x += transPoint.x;
                nextFrame.origin.y += transPoint.y;
                nextFrame.size.width -= transPoint.x;
                nextFrame.size.height -= transPoint.y;
                if(CGRectGetWidth(nextFrame) < MinBoxSide){
                    nextFrame.size.width = MinBoxSide;
                    nextFrame.origin.x = CGRectGetMaxX(_cropViewPreFrame) - MinBoxSide;
                }
                if(CGRectGetHeight(nextFrame) < MinBoxSide){
                    nextFrame.size.height = MinBoxSide;
                    nextFrame.origin.y = CGRectGetMaxY(_cropViewPreFrame) - MinBoxSide;
                }
                if(CGRectGetMinX(nextFrame) < maxLeft){
                    nextFrame.origin.x = maxLeft;
                    nextFrame.size.width = CGRectGetMaxX(_cropViewPreFrame) - maxLeft;
                }
                if(CGRectGetMinY(nextFrame) < maxTop){
                    nextFrame.origin.y = maxTop;
                    nextFrame.size.height = CGRectGetMaxY(_cropViewPreFrame) - maxTop;
                }
            }else if(_panType == PanCropViewConcer2){
                nextFrame.origin.y += transPoint.y;
                nextFrame.size.width += transPoint.x;
                nextFrame.size.height -= transPoint.y;
                if(CGRectGetWidth(nextFrame) < MinBoxSide){
                    nextFrame.size.width = MinBoxSide;
                }
                if(CGRectGetHeight(nextFrame) < MinBoxSide){
                    nextFrame.size.height = MinBoxSide;
                    nextFrame.origin.y = CGRectGetMaxY(_cropViewPreFrame) - MinBoxSide;
                }
                if(CGRectGetMaxX(nextFrame) > minRight){
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                }
                if(CGRectGetMinY(nextFrame) < maxTop){
                    nextFrame.origin.y = maxTop;
                    nextFrame.size.height = CGRectGetMaxY(_cropViewPreFrame) - maxTop;
                }
            }else if(_panType == PanCropViewConcer3){
                nextFrame.origin.x += transPoint.x;
                nextFrame.size.width -= transPoint.x;
                nextFrame.size.height += transPoint.y;
                if(CGRectGetWidth(nextFrame) < MinBoxSide){
                    nextFrame.size.width = MinBoxSide;
                    nextFrame.origin.x = CGRectGetMaxX(_cropViewPreFrame) - MinBoxSide;
                }
                if(CGRectGetHeight(nextFrame) < MinBoxSide){
                    nextFrame.size.height = MinBoxSide;
                }
                if(CGRectGetMinX(nextFrame) < maxLeft){
                    nextFrame.origin.x = maxLeft;
                    nextFrame.size.width = CGRectGetMaxX(_cropViewPreFrame) - maxLeft;
                }
                if(CGRectGetMaxY(nextFrame) > minButtom){
                    nextFrame.size.height = minButtom - CGRectGetMinY(_cropViewPreFrame);
                }
            }else if(_panType == PanCropViewConcer4){
                nextFrame.size.width += transPoint.x;
                nextFrame.size.height += transPoint.y;
                if(CGRectGetWidth(nextFrame) < MinBoxSide) nextFrame.size.width = MinBoxSide;
                if(CGRectGetHeight(nextFrame) < MinBoxSide) nextFrame.size.height = MinBoxSide;
                if(CGRectGetMaxX(nextFrame) > minRight){
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                }
                if(CGRectGetMaxY(nextFrame) > minButtom){
                    nextFrame.size.height = minButtom - CGRectGetMinY(_cropViewPreFrame);
                }
            }else if(_panType == PanCropViewTopBorder){
                nextFrame.origin.y += transPoint.y;
                nextFrame.size.height -= transPoint.y;
                if(CGRectGetHeight(nextFrame) < MinBoxSide){
                    nextFrame.size.height = MinBoxSide;
                    nextFrame.origin.y = CGRectGetMaxY(_cropViewPreFrame) - MinBoxSide;
                }
                if(CGRectGetMinY(nextFrame) < maxTop){
                    nextFrame.origin.y = maxTop;
                    nextFrame.size.height = CGRectGetMaxY(_cropViewPreFrame) - maxTop;
                }
            }else if(_panType == PanCropViewLeftBorder){
                nextFrame.origin.x += transPoint.x;
                nextFrame.size.width -= transPoint.x;
                if(CGRectGetWidth(nextFrame) < MinBoxSide){
                    nextFrame.size.width = MinBoxSide;
                    nextFrame.origin.x =  CGRectGetMaxX(_cropViewPreFrame) - MinBoxSide;
                }
                if(CGRectGetMinX(nextFrame) < maxLeft){
                    nextFrame.origin.x = maxLeft;
                    nextFrame.size.width = CGRectGetMaxX(_cropViewPreFrame) - maxLeft;
                }
            }else if(_panType == PanCropViewRightBorder){
                nextFrame.size.width += transPoint.x;
                if(CGRectGetWidth(nextFrame) < MinBoxSide){
                    nextFrame.size.width = MinBoxSide;
                }
                if(CGRectGetMaxX(nextFrame) > minRight){
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                }
            }else if(_panType == PanCropViewButtomBorder){
                nextFrame.size.height += transPoint.y;
                if(CGRectGetHeight(nextFrame) < MinBoxSide){
                    nextFrame.size.height = MinBoxSide;
                }
                if(CGRectGetMaxY(nextFrame) > minButtom){
                    nextFrame.size.height = minButtom - CGRectGetMinY(_cropViewPreFrame);
                }
            }
            
            _cropView.frame = nextFrame;
            [self layoutCoverViews];
            [self layoutDecoraterViews];
            [recognizer setTranslation:CGPointZero inView:self];
        }
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        [self setTouchRects];
        _panType = PanNone;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer{
    CGRect currentImageFrame = _imageView.frame;
    CGRect nextImageFrame = currentImageFrame;
    CGFloat scale = recognizer.scale;
    CGFloat nextWidth = scale * CGRectGetWidth(currentImageFrame);
    CGFloat nextHeight = scale * CGRectGetHeight(currentImageFrame);
    if(nextWidth > CGRectGetWidth(_imageViewOriginFrame) * 3){
        nextWidth = CGRectGetWidth(_imageViewOriginFrame) * 3;
    }
    if(nextHeight > CGRectGetHeight(_imageViewOriginFrame) * 3){
        nextHeight = CGRectGetHeight(_imageViewOriginFrame) * 3;
    }
    if(nextWidth < CGRectGetWidth(_imageViewOriginFrame) * 1){
        nextWidth = CGRectGetWidth(_imageViewOriginFrame) * 1;
    }
    if(nextHeight < CGRectGetHeight(_imageViewOriginFrame) * 1){
        nextHeight = CGRectGetHeight(_imageViewOriginFrame) * 1;
    }
    
    nextImageFrame.size.width = nextWidth;
    nextImageFrame.size.height = nextHeight;
    nextImageFrame.origin.x -= (CGRectGetWidth(nextImageFrame) - CGRectGetWidth(currentImageFrame)) / 2;
    nextImageFrame.origin.y -= (CGRectGetHeight(nextImageFrame) - CGRectGetHeight(currentImageFrame)) / 2;
    
    CGRect cropViewFrame = _cropView.frame;
    if(scale < 1 && !CGRectContainsRect(nextImageFrame, cropViewFrame)){
        if(CGRectGetWidth(nextImageFrame) <= CGRectGetWidth(cropViewFrame) || CGRectGetHeight(nextImageFrame) <= CGRectGetHeight(cropViewFrame)){
            if(CGRectGetWidth(nextImageFrame) <= CGRectGetWidth(cropViewFrame)){
                cropViewFrame.size.width = CGRectGetWidth(nextImageFrame);
                cropViewFrame.origin.x = CGRectGetMinX(nextImageFrame);
                if(CGRectGetMinY(nextImageFrame) > CGRectGetMinY(cropViewFrame)){
                    nextImageFrame.origin.y = CGRectGetMinY(currentImageFrame);
                }
                if(CGRectGetMaxY(nextImageFrame) < CGRectGetMaxY(cropViewFrame)){
                    nextImageFrame.origin.y = CGRectGetMaxY(cropViewFrame) - CGRectGetHeight(nextImageFrame);
                }
            }
            if(CGRectGetHeight(nextImageFrame) <= CGRectGetHeight(cropViewFrame)){
                cropViewFrame.size.height = CGRectGetHeight(nextImageFrame);
                cropViewFrame.origin.y = CGRectGetMinY(nextImageFrame);
                if(CGRectGetMinX(nextImageFrame) > CGRectGetMinX(cropViewFrame)){
                    nextImageFrame.origin.x = CGRectGetMinX(currentImageFrame);
                }
                if(CGRectGetMaxX(nextImageFrame) < CGRectGetMaxX(cropViewFrame)){
                    nextImageFrame.origin.x = CGRectGetMaxX(cropViewFrame) - CGRectGetWidth(nextImageFrame);
                }
            }
            _cropView.frame = cropViewFrame;
            [self layoutCoverViews];
            [self layoutDecoraterViews];
        }else{
            if(CGRectGetMinX(nextImageFrame) > CGRectGetMinX(cropViewFrame)){
                nextImageFrame.origin.x = CGRectGetMinX(currentImageFrame);
            }
            if(CGRectGetMinY(nextImageFrame) > CGRectGetMinY(cropViewFrame)){
                nextImageFrame.origin.y = CGRectGetMinY(currentImageFrame);
            }
            if(CGRectGetMaxX(nextImageFrame) < CGRectGetMaxX(cropViewFrame)){
                nextImageFrame.origin.x = CGRectGetMaxX(cropViewFrame) - CGRectGetWidth(nextImageFrame);
            }
            if(CGRectGetMaxY(nextImageFrame) < CGRectGetMaxY(cropViewFrame)){
                nextImageFrame.origin.y = CGRectGetMaxY(cropViewFrame) - CGRectGetHeight(nextImageFrame);
            }
        }
    }
    
    _imageView.frame = nextImageFrame;
    recognizer.scale = 1.0;
}

@end
