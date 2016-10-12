//
//  VoicePlayer.m
//  批注文字
//
//  Created by 肖睿 on 2016/10/12.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import "VoicePlayer.h"
#import <AVFoundation/AVFoundation.h>

static VoicePlayer *_instance;

@interface VoicePlayer()<AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation VoicePlayer

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)defaultVoicePlayer {
    return [[self alloc]init];
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}


- (void)playWithURL:(NSURL *)voiceURL {
    if (_audioPlayer.isPlaying) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceURL error:nil];
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    [self startTimer];
}

- (void)updateProgress {
    if (_updateProgressBlock) {
        _updateProgressBlock(_audioPlayer.currentTime / _audioPlayer.duration);
    }
}

- (void)play {
    [_audioPlayer play];
    [self startTimer];
}

- (void)pause {
    [_audioPlayer pause];
    [self stopTimer];
}

- (void)stop {
    [_audioPlayer stop];
    [self stopTimer];
}

- (void)startTimer {
    [self stopTimer];
    [self handleNotification:YES];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    [self handleNotification:NO];
    [_timer invalidate];
    _timer = nil;
}

#pragma mark- AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopTimer];
    if (_updateProgressBlock) {
        _updateProgressBlock(1);
    }
}


#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification; {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}
@end
