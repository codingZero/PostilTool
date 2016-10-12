//
//  AddRemarkViewController.m
//  批注文字
//
//  Created by 肖睿 on 2016/10/11.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import "AddRemarkViewController.h"

#define MAXWORDCOUNT 100

@interface AddRemarkViewController ()<UITextViewDelegate>
@property (nonatomic, weak) UITextView *textView;
@end

@implementation AddRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finish)];
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finish {
    if ([_delegate respondsToSelector:@selector(addRemarkViewController:didFinishWithRemark:addFunctionType:)]) {
        [_delegate addRemarkViewController:self didFinishWithRemark:_textView.text addFunctionType:_functionType];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupView {
     UITextView *textView = [[UITextView alloc] init];
    textView.frame = CGRectMake(15, NaviBarH + 16, ScreenWidth - 30, ScreenHeight - NaviBarH - 32);
    textView.font = [UIFont systemFontOfSize:16];
    textView.delegate = self;
    [self.view addSubview:textView];
    _textView = textView;
    
    if (_functionType == FunctionTypeEdit) {
        _textView.text = _remark;
    }
}

#pragma mark- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    //限制输入的字数为100
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position && toBeString.length > MAXWORDCOUNT) {
            textView.text = [toBeString substringToIndex:MAXWORDCOUNT];
        }
    } else if(toBeString.length > MAXWORDCOUNT) {
        textView.text = [toBeString substringToIndex:MAXWORDCOUNT];
    }
}
@end
