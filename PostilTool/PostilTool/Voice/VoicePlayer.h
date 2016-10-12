//
//  VoicePlayer.h
//  批注文字
//
//  Created by 肖睿 on 2016/10/12.
//  Copyright © 2016年 肖睿. All rights reserved.
//



@interface VoicePlayer : NSObject

@property (nonatomic, strong) void(^updateProgressBlock)(CGFloat progress);

+ (instancetype)defaultVoicePlayer;

/**
 *  重新播放新的语音
 *
 */
- (void)playWithURL:(NSURL *)voiceURL;
/**
 *  继续播放
 */
- (void)play;
/**
 *  暂停
 */
- (void)pause;
/**
 *  停止
 */
- (void)stop;
@end
