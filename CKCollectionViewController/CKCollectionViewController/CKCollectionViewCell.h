//
//  CKCollectionViewCell.h
//  CommonKit
//
//  Created by Admin on 2017/9/29.
//

#import <UIKit/UIKit.h>

@interface CKCollectionViewCell : UICollectionViewCell

- (void)ck_setView:(UIView *)view
          safeArea:(UIEdgeInsets)safeArea;

@end

