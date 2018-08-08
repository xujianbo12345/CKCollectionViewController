//
//  UIViewController+CKAssist.h
//  CommonKit
//
//  Created by 徐建波 on 2017/10/10.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CKAssist)

/**
 是否是分页控制器的子视图
 */
@property (nonatomic, assign) BOOL isChildOfPagesController;

//视图即将在pagesController 出现
- (void)viewWillAppearInPagesController;
//视图即将在pagesController 消失
- (void)viewWillDisappearInPagesController;

//安全区域
- (UIEdgeInsets)safeArea;

@end

