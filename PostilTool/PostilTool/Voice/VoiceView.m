//
//  VoiceView.m
//  批注文字
//
//  Created by 肖睿 on 2016/10/12.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import "VoiceView.h"
@interface VoiceView()
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@end

@implementation VoiceView

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.frame = self.bounds;
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.lineWidth = 1;
        _shapeLayer.strokeColor = [UIColor redColor].CGColor;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_shapeLayer];
    }
    return _shapeLayer;
}


+ (instancetype)voiceViewWithURL:(NSURL *)voiceURL {
    VoiceView *voiceView = [[VoiceView alloc] initWithURL:voiceURL];
    return voiceView;
}

- (instancetype)initWithURL:(NSURL *)voiceURL {
    if (self = [super initWithFrame:CGRectMake(0, 0, 44, 44)]) {
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
        self.layer.cornerRadius = 22;
        self.voiceURL = voiceURL;
        
        _playBtn = [[UIButton alloc] initWithFrame:self.bounds];
        [_playBtn setImage:[UIImage imageNamed:@"voice-s"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playBtn];
        
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)]];
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    }
    return self;
}

- (void)setPlayProgress:(CGFloat)playProgress {
    _playProgress = playProgress;
    
    NSLog(@"%f", playProgress);
    self.shapeLayer.hidden = playProgress == 0;
    CGFloat radius = self.bounds.size.width * 0.5;
    CGPoint center = CGPointMake(radius, radius);
    CGFloat endAngle = -M_PI_2 + _playProgress * 2 * M_PI;
    
    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 3.5 startAngle:-M_PI_2 endAngle:endAngle clockwise:YES].CGPath;
    
    if (playProgress == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_playBtn setImage:[UIImage imageNamed:@"voice-s"] forState:UIControlStateNormal];
            self.shapeLayer.hidden = YES;
            _state = VoiceViewStateNormal;
        });
    }
    
}


- (void)btnClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(voiceView:didClickWithState:)]) {
        [_delegate voiceView:self didClickWithState:_state];
    }
}

- (void)move:(UIPanGestureRecognizer *)pan {
    if ([_delegate respondsToSelector:@selector(voiceView:moveWithGesture:)]) {
        [_delegate voiceView:self moveWithGesture:pan];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (_state == VoiceViewStateDelete) return;
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(voiceViewLongPress:)]) {
            [_delegate voiceViewLongPress:self];
        }
    }
}

- (void)setState:(VoiceViewState)state {
    switch (state) {
        case VoiceViewStateNormal:
            if (_state != VoiceViewStateNormal && _state != VoiceViewStateDelete) self.playProgress = 0;
            [_playBtn setImage:[UIImage imageNamed:@"voice-s"] forState:UIControlStateNormal];
            break;
        case VoiceViewStatePlay:
            [_playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
            break;
        case VoiceViewStatePause:
            [_playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;
        case VoiceViewStateDelete:
            if (_state != VoiceViewStateNormal) self.playProgress = 0;
            [_playBtn setImage:[UIImage imageNamed:@"v-shan"] forState:UIControlStateNormal];
            break;
    }
    _state = state;
}


@end
