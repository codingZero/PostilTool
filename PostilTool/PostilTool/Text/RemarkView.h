//
//  RemarkView.h
//  批注文字
//
//  Created by 肖睿 on 2016/10/11.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  RemarkView;

@protocol RemarkViewDelegate <NSObject>

/**
 *  点击编辑按钮时的回调方法
 */
- (void)remarkViewEditContent:(RemarkView *)remarkView;

/**
 *  拖拽控件时的回调方法
 *
 *  @param remarkView 控件本身
 *  @param gesture    手势
 */
- (void)remarkView:(RemarkView *)remarkView moveWithGesture:(UIPanGestureRecognizer *)gesture;

@end

@interface RemarkView : UIView

@property (nonatomic, weak) id<RemarkViewDelegate> delegate;
/**
 *  获取文本内容
 */
@property (nonatomic, strong) NSString *content;

/**
 *  创建控件，并根据文本内容布局子控件
 */
+ (instancetype)remarkViewWithContent:(NSString *)content;

/**
 *  更新文本内容并重新布局
 *
 */
- (void)layoutSubviewsWithContent:(NSString *)content;

/**
 *  隐藏控件所有按钮
 */
- (void)hiddenButton;
@end
