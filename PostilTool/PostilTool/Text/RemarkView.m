//
//  RemarkView.m
//  批注文字
//
//  Created by 肖睿 on 2016/10/11.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import "RemarkView.h"

@interface RemarkView()
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIButton *deleteBtn;
@property (nonatomic, weak) UIButton *editBtn;
@end

@implementation RemarkView

- (instancetype)init {
    if (self = [super init]) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 12, 0, 0)];
        backView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
        backView.layer.cornerRadius = 4;
        [self addSubview:backView];
        _backView = backView;
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 12, 0, 0)];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.numberOfLines = 0;
        [backView addSubview:contentLabel];
        _contentLabel = contentLabel;
        
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [deleteBtn setImage:[UIImage imageNamed:@"shanchu"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.hidden = YES;
        [self addSubview:deleteBtn];
        _deleteBtn = deleteBtn;
        
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [editBtn setImage:[UIImage imageNamed:@"bianji"] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
        [editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchDragExit];
        editBtn.hidden = YES;
        [self addSubview:editBtn];
        _editBtn = editBtn;
        
        [backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenOrShowBtn)]];
        [backView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)]];
    }
    return self;
}

+ (instancetype)remarkViewWithContent:(NSString *)content {
    RemarkView *remarkView = [[RemarkView alloc] init];
    [remarkView layoutSubviewsWithContent:content];
    return remarkView;
}

- (void)layoutSubviewsWithContent:(NSString *)content {
    CGSize size = [content boundingRectWithSize:CGSizeMake(182, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil].size;
    _contentLabel.text = content;
    _contentLabel.width = size.width;
    _contentLabel.height = size.height;
    
    _backView.width = _contentLabel.width + 14;
    _backView.height = _contentLabel.height + 24;
    
    self.width = _backView.width + 12;
    self.height = _backView.height + 24;
    
    _deleteBtn.centerX = self.width - 12;
    _deleteBtn.centerY = 12;
    
    _editBtn.centerX = _deleteBtn.centerX;
    _editBtn.centerY = self.height - 12;
}

- (NSString *)content {
    return _contentLabel.text;
}

- (void)delete {
    [self removeFromSuperview];
}

- (void)edit:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(remarkViewEditContent:)]) {
        [_delegate remarkViewEditContent:self];
    }
}

- (void)move:(UIPanGestureRecognizer *)pan {
    if ([_delegate respondsToSelector:@selector(remarkView:moveWithGesture:)]) {
        [_delegate remarkView:self moveWithGesture:pan];
    }
}

- (void)hiddenOrShowBtn {
    _deleteBtn.hidden = !_deleteBtn.hidden;
    _editBtn.hidden = _deleteBtn.hidden;
}

- (void)hiddenButton {
    _deleteBtn.hidden = YES;
    _editBtn.hidden = YES;
}

@end
