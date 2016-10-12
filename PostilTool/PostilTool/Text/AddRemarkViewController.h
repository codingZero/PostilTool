//
//  AddRemarkViewController.h
//  批注文字
//
//  Created by 肖睿 on 2016/10/11.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FunctionTypeAdd, //添加文字
    FunctionTypeEdit //修改文字
} FunctionType;

@class AddRemarkViewController;

@protocol AddRemarkViewControllerDelegate<NSObject>
/**
 *  点击完成会回调该方法
 *
 *  @param remark 文字内容
 */
- (void)addRemarkViewController:(AddRemarkViewController *)addRemarkViewController didFinishWithRemark:(NSString *)remark addFunctionType:(FunctionType)functionType;
@end

@interface AddRemarkViewController : UIViewController

@property (nonatomic, weak) id<AddRemarkViewControllerDelegate> delegate;

/**
 *  类型，是添加还是修改
 */
@property (nonatomic, assign) FunctionType functionType;

/**
 *  用来传递要修改的文字
 */
@property (nonatomic, strong) NSString *remark;
@end
