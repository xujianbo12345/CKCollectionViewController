//
//  UIScrollView+CKFullScreenPop.m
//  CommonKit
//
//  Created by 徐建波 on 2017/10/19.
//

#import "UIScrollView+CKFullScreenPop.h"

@implementation UIScrollView (CKFullScreenPop)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSArray *Localizations = [[NSBundle mainBundle] preferredLocalizations];
    NSString * language = nil;
    if (Localizations.count > 0) {
        language = Localizations[0];
    }
    if ([language isEqualToString:@"ar"]) {
        if (self.contentOffset.x >= self.contentSize.width - self.frame.size.width) {
            if ([otherGestureRecognizer.delegate isKindOfClass:NSClassFromString(@"_FDFullscreenPopGestureRecognizerDelegate")] && self.tag == kCKFullScreenPopTag) {
                return YES;
            }
        }
    } else {
        if (self.contentOffset.x <= 0) {
            if ([otherGestureRecognizer.delegate isKindOfClass:NSClassFromString(@"_FDFullscreenPopGestureRecognizerDelegate")] && self.tag == kCKFullScreenPopTag) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end

