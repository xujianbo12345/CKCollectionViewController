//
//  UIViewController+CKAssist.m
//  CommonKit
//
//  Created by 徐建波 on 2017/10/10.
//

#import "UIViewController+CKAssist.h"
#import <objc/runtime.h>

@implementation UIViewController (CKAssist)

//for override
- (void)viewWillAppearInPagesController {}

- (void)viewWillDisappearInPagesController {}

- (void)setIsChildOfPagesController:(BOOL)isChildOfPagesController {
    objc_setAssociatedObject(self, @selector(isChildOfPagesController), @(isChildOfPagesController), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isChildOfPagesController {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UIEdgeInsets)safeArea {
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

@end

