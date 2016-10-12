//
//  RecordButton.m
//  批注文字
//
//  Created by 肖睿 on 2016/10/12.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import "RecordButton.h"

@implementation RecordButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget];
    }
    return self;
}

- (void)awakeFromNib {
    [self addTarget];
}

- (void)addTarget {
    [self addTarget:self action:@selector(dragExit) forControlEvents:UIControlEventTouchDragExit];
    [self addTarget:self action:@selector(dragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(upInside) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(upOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
}

- (void)dragExit {
    if ([_delegate respondsToSelector:@selector(didTouchRecordButon:event:)]) {
        [_delegate didTouchRecordButon:self event:UIControlEventTouchDragExit];
    }
}

- (void)dragEnter {
    if ([_delegate respondsToSelector:@selector(didTouchRecordButon:event:)]) {
        [_delegate didTouchRecordButon:self event:UIControlEventTouchDragEnter];
    }
}

- (void)upInside {
    if ([_delegate respondsToSelector:@selector(didTouchRecordButon:event:)]) {
        [_delegate didTouchRecordButon:self event:UIControlEventTouchUpInside];
    }
}

- (void)upOutside {
    if ([_delegate respondsToSelector:@selector(didTouchRecordButon:event:)]) {
        [_delegate didTouchRecordButon:self event:UIControlEventTouchUpOutside];
    }
}

- (void)touchDown {
    if ([_delegate respondsToSelector:@selector(didTouchRecordButon:event:)]) {
        [_delegate didTouchRecordButon:self event:UIControlEventTouchDown];
    }
}

@end
