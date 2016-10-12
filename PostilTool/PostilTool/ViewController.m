//
//  ViewController.m
//  批注文字
//
//  Created by 肖睿 on 2016/10/11.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AddRemarkViewController.h"
#import "RemarkView.h"
#import "RecordButton.h"
#import "VoiceView.h"
#import "VoicePlayer.h"

@interface ViewController ()<AddRemarkViewControllerDelegate, RemarkViewDelegate, RecordButtonDelegate, VoiceViewDelegate>

/**
 *  录音按钮
 */
@property (weak, nonatomic) IBOutlet RecordButton *recordButton;

/**
 *  文字和语音层
 */
@property (nonatomic, weak) UIView *remarkAndVoiceView;

/**
 *  添加文字或语音的坐标，即上一次画笔结束的位置
 */
@property (nonatomic, assign) CGPoint addViewPoint;

/**
 *  记录要编辑的remarkView
 */
@property (nonatomic, weak) RemarkView *editRemarkView;

/**
 *  语音播放工具
 */
@property (nonatomic, strong) VoicePlayer *voicePlayer;

/**
 *  正在播放的voiceView
 */
@property (nonatomic, strong) VoiceView *playVoiceView;

/*********************录音相关控件**********************/
@property (nonatomic, weak) UIView *bgView;
@property (nonatomic, weak) UIImageView *promptView;
@property (nonatomic, weak) UILabel *promptLabel;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSURL *recordURL;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isDragExit;
/****************************************************/


@end

@implementation ViewController

- (UIView *)bgView {
    if (!_bgView) {
        UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
        bgView.hidden = YES;
        bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.view addSubview:bgView];
        _bgView = bgView;
        
        UIImageView *promptView = [[UIImageView alloc] init];
        promptView.center = CGPointMake(bgView.width * 0.5, bgView.height * 0.5);
        promptView.bounds = CGRectMake(0, 0, 100, 100);
        [bgView addSubview:promptView];
        _promptView = promptView;
        
        UILabel *promptLabel = [[UILabel alloc] init];
        promptLabel.textColor = [UIColor whiteColor];
        promptLabel.x = promptView.x;
        promptLabel.y = CGRectGetMaxY(promptView.frame);
        promptLabel.width = promptView.width;
        promptLabel.height = 30;
        promptLabel.font = [UIFont systemFontOfSize:13];
        promptLabel.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:promptLabel];
        _promptLabel = promptLabel;
    }
    return _bgView;
}

- (VoicePlayer *)voicePlayer {
    if (!_voicePlayer) {
        _voicePlayer = [VoicePlayer defaultVoicePlayer];
        __weak typeof(self) weakSelf = self;
        [_voicePlayer setUpdateProgressBlock:^(CGFloat progerss) {
            weakSelf.playVoiceView.playProgress = progerss;
        }];
    }
    return _voicePlayer;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    [self setupView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hiddenOperation];
}


- (void)setupView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, NaviBarH, ScreenWidth - 60, ScreenHeight - NaviBarH - 50)];
    imageView.userInteractionEnabled = YES;
    imageView.image = [UIImage imageNamed:@"0.jpeg"];
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenOperation)]];
    [self.view addSubview:imageView];
    
    UIView *remarkAndVoiceView = [[UIView alloc] initWithFrame:imageView.bounds];
    remarkAndVoiceView.backgroundColor = [UIColor clearColor];
    [imageView addSubview:remarkAndVoiceView];
    _remarkAndVoiceView = remarkAndVoiceView;
    
    _recordButton.delegate = self;
}


- (void)hiddenOperation {
    for (UIView *view in _remarkAndVoiceView.subviews) {
        if ([view isKindOfClass:[RemarkView class]]) {
            RemarkView *remarkView = (RemarkView *)view;
            [remarkView hiddenButton];
        }
        
        if ([view isKindOfClass:[VoiceView class]]) {
            VoiceView *voiceView = (VoiceView *)view;
            if (voiceView.state == VoiceViewStateDelete)
                voiceView.state = VoiceViewStateNormal;
        }
    }
}


/**
 *  添加文字
 *
 */
- (IBAction)addRemark {
    AddRemarkViewController *addRemark = [AddRemarkViewController new];
    addRemark.functionType = FunctionTypeAdd;
    addRemark.delegate = self;
    [self.navigationController pushViewController:addRemark animated:YES];
}

/**
 *  添加语音
 *
 */
#pragma mark- RecordButtonDelegate
- (void)didTouchRecordButon:(RecordButton *)sender event:(UIControlEvents)event {
    [self hiddenOperation];
    self.bgView.hidden = NO;
    _isDragExit = (event == UIControlEventTouchDragExit);
    if (event == UIControlEventTouchDown || event == UIControlEventTouchDragEnter) {
        if (event == UIControlEventTouchDown) [self startRecord];
        _promptView.image = [UIImage imageNamed:@"recording0"];
        _promptLabel.text = @"上滑取消录音";
    } else if (event == UIControlEventTouchDragExit) {
        _promptView.image = [UIImage imageNamed:@"cancel"];
        _promptLabel.text = @"松开取消录音";
    } else if (event == UIControlEventTouchUpInside) {
        NSTimeInterval duration = _audioRecorder.currentTime;
        [self.audioRecorder stop];
        if (duration < 0.2) {
            _promptView.image = [UIImage imageNamed:@"warning"];
            _promptLabel.text = @"说话时间太短";
            [_audioRecorder deleteRecording];
            [UIView animateWithDuration:0.3 delay:0.3 options:kNilOptions animations:^{
                self.bgView.alpha = 0;
            } completion:^(BOOL finished){
                self.bgView.hidden = YES;
                self.bgView.alpha = 1;
            }];
        } else {
            self.bgView.hidden = YES;
            VoiceView *voiceView = [VoiceView voiceViewWithURL:_recordURL];
            voiceView.delegate = self;
            if (CGPointEqualToPoint(_addViewPoint, CGPointZero)) {
                voiceView.centerX = _remarkAndVoiceView.width * 0.5;
                voiceView.centerY = _remarkAndVoiceView.height * 0.5;
            } else {
                voiceView.x = _addViewPoint.x;
                voiceView.y = _addViewPoint.y;
            }
            [self.remarkAndVoiceView addSubview:voiceView];
            [self layoutView:voiceView];
        }
        [_timer invalidate];
    } else {
        [self.audioRecorder stop];
        self.bgView.hidden = YES;
        [_audioRecorder deleteRecording];
        [_timer invalidate];
    }
}

#pragma mark 录音
- (void)startRecord {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    //AVAudioSessionCategoryPlayAndRecord用于录音和播放
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(sessionError) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    } else {
        [session setActive:YES error:nil];
    }
    
    
    NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                               AVSampleRateKey: @8000.00f,
                               AVNumberOfChannelsKey: @1,
                               AVLinearPCMBitDepthKey: @16,
                               AVLinearPCMIsNonInterleaved: @NO,
                               AVLinearPCMIsFloatKey: @NO,
                               AVLinearPCMIsBigEndianKey: @NO};
    
    NSString *fileName = [NSString stringWithFormat:@"%f.wav", [NSDate date].timeIntervalSince1970];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    _recordURL = [NSURL fileURLWithPath:filePath];
    //根据存放路径及录音设置创建录音对象
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_recordURL settings:settings error:nil];
    _audioRecorder.meteringEnabled = YES;
    [_audioRecorder prepareToRecord];
    [_audioRecorder record];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}

- (void)detectionVoice {
    [_audioRecorder updateMeters];//刷新音量数据
    double result = pow(10, (0.05 * [_audioRecorder averagePowerForChannel:0]));
    if (!_isDragExit) {
        if (result < 0.01) {
            _promptView.image = [UIImage imageNamed:@"recording0"];
        } else if (result < 0.1) {
            _promptView.image = [UIImage imageNamed:@"recording1"];
        } else if (result < 0.3){
            _promptView.image = [UIImage imageNamed:@"recording2"];
        } else {
            _promptView.image = [UIImage imageNamed:@"recording3"];
        }
    }
}


#pragma mark- AddRemarkViewControllerDelegate
- (void)addRemarkViewController:(AddRemarkViewController *)addRemarkViewController didFinishWithRemark:(NSString *)remark addFunctionType:(FunctionType)functionType {
    if (functionType == FunctionTypeAdd) {
        RemarkView *remarkView = [RemarkView remarkViewWithContent:remark];
        remarkView.delegate = self;
        if (CGPointEqualToPoint(_addViewPoint, CGPointZero)) {
            remarkView.centerX = _remarkAndVoiceView.width * 0.5;
            remarkView.centerY = _remarkAndVoiceView.height * 0.5;
        } else {
            remarkView.x = _addViewPoint.x;
            remarkView.y = _addViewPoint.y;
        }
        [self.remarkAndVoiceView addSubview:remarkView];
        [self layoutView:remarkView];
    } else {
        [_editRemarkView layoutSubviewsWithContent:remark];
        [self layoutView:_editRemarkView];
    }
}

#pragma mark- RemarkViewDelegate
- (void)remarkViewEditContent:(RemarkView *)remarkView {
    _editRemarkView = remarkView;
    AddRemarkViewController *addRemark = [[AddRemarkViewController alloc] init];
    addRemark.remark = remarkView.content;
    addRemark.functionType = FunctionTypeEdit;
    addRemark.delegate = self;
    [self.navigationController pushViewController:addRemark animated:YES];
}

- (void)remarkView:(RemarkView *)remarkView moveWithGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view];
    remarkView.x += translation.x;
    remarkView.y += translation.y;
    [self layoutView:remarkView];
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

#pragma mark- VoiceViewDelegate
- (void)voiceView:(VoiceView *)voiceView moveWithGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view];
    voiceView.x += translation.x;
    voiceView.y += translation.y;
    [self layoutView:voiceView];
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

- (void)voiceViewLongPress:(VoiceView *)voiceView {
    //长按时停止播放并进入删除状态
    [self.voicePlayer stop];
    for (UIView *view in _remarkAndVoiceView.subviews) {
        if ([view isKindOfClass:[VoiceView class]]) {
            VoiceView *voiceView = (VoiceView *)view;
            voiceView.state = VoiceViewStateDelete;
        }
    }
}


- (void)voiceView:(VoiceView *)voiceView didClickWithState:(VoiceViewState)state{
    
    if (state == VoiceViewStateNormal) {
        _playVoiceView.state = VoiceViewStateNormal;
        [self.voicePlayer playWithURL:voiceView.voiceURL];
        voiceView.state = VoiceViewStatePlay;
    } else if (state == VoiceViewStatePause) {
        [self.voicePlayer play];
        voiceView.state = VoiceViewStatePlay;
    } else if (state == VoiceViewStatePlay) {
        [self.voicePlayer pause];
        voiceView.state = VoiceViewStatePause;
    } else {
        [voiceView removeFromSuperview];
        [[NSFileManager defaultManager] removeItemAtURL:voiceView.voiceURL error:nil];
    }
    _playVoiceView = voiceView;
}


#pragma mark- 防止控件超出范围
- (void)layoutView:(UIView *)view {
    CGFloat maxX = CGRectGetMaxX(view.frame);
    CGFloat maxY = CGRectGetMaxY(view.frame);
    if (maxX > _remarkAndVoiceView.width) {
        view.x = _remarkAndVoiceView.width - view.width;
    }
    
    if (maxY > _remarkAndVoiceView.height) {
        view.y = _remarkAndVoiceView.height - view.height;
    }
    
    if (view.x < 0) view.x = 0;
    if (view.y < 0) view.y = 0;
}

@end
