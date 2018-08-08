//
//  CKCollectionViewCell.m
//  CommonKit
//
//  Created by Admin on 2017/9/29.
//

#import "CKCollectionViewCell.h"
#import "Masonry.h"

@implementation CKCollectionViewCell

- (void)ck_setView:(UIView *)view
          safeArea:(UIEdgeInsets)safeArea
{
    self.selected = NO;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    [self.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(safeArea.left);
        make.right.mas_equalTo(-safeArea.right);
    }];;
}

@end
