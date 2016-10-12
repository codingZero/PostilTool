//
//  RecordButton.h
//  批注文字
//
//  Created by 肖睿 on 2016/10/12.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RecordButton;
@protocol RecordButtonDelegate <NSObject>
- (void)didTouchRecordButon:(RecordButton *)sender event:(UIControlEvents)event;

@end

@interface RecordButton : UIButton
@property (nonatomic, weak) id<RecordButtonDelegate> delegate;
@end
