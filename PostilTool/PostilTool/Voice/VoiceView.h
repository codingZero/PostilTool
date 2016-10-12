//
//  VoiceView.h
//  批注文字
//
//  Created by 肖睿 on 2016/10/12.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VoiceView;

typedef enum {
    VoiceViewStateNormal,
    VoiceViewStatePlay,
    VoiceViewStatePause,
    VoiceViewStateDelete
} VoiceViewState;

@protocol VoiceViewDelegate <NSObject>

/**
 *  点击非删除按钮时的回调方法
 */
- (void)voiceView:(VoiceView *)voiceView didClickWithState:(VoiceViewState)state;

/**
 *  拖拽控件时的回调方法
 *
 */
- (void)voiceView:(VoiceView *)voiceView moveWithGesture:(UIPanGestureRecognizer *)gesture;

/**
 *  长按时的回调方法
 *
 */
- (void)voiceViewLongPress:(VoiceView *)voiceView;

@end

@interface VoiceView : UIView
@property (nonatomic, weak) id<VoiceViewDelegate> delegate;
@property (nonatomic, strong) NSURL *voiceURL;
@property (nonatomic, assign) CGFloat playProgress;
@property (nonatomic, assign) VoiceViewState state;
+ (instancetype)voiceViewWithURL:(NSURL *)voiceURL;
@end
