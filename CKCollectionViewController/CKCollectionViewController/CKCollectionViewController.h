//
//  CKCollectionViewController.h
//  CommonKit
//
//  Created by Admin on 2017/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CKCollectionViewDelegate, CKCollectionViewDataSource;

@interface CKCollectionViewController : UIViewController<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
/** 当前选中的标签 */
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, assign) BOOL shouldAutoRotate;//是否自动旋转  默认NO
/** 代理 */
@property (nonatomic, weak, nullable) id<CKCollectionViewDelegate>delegate;
@property (nonatomic, weak, nullable) id<CKCollectionViewDataSource>dataSource;

/** 滚动到任意视图 */
- (void)scrollToItemAtIndex:(NSInteger)index atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)scrollToItemAtIndex:(NSInteger)index atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated delay:(NSTimeInterval)delay;
/** 刷新视图 */
- (void)reloadData;
@end

@protocol CKCollectionViewDelegate <NSObject>
@optional

- (void)collectionViewController:(CKCollectionViewController *)collectionViewController willTransitionToViewControllerAtIndex:(NSInteger)index;

@end

@protocol CKCollectionViewDataSource <NSObject>
@required
/** 要显示的数量 */
- (NSInteger)presentationCountForCollectionViewController:(CKCollectionViewController *)collectionViewController;
/** 要显示的视图 */
- (nonnull UIViewController *)collectionViewController:(CKCollectionViewController *)collectionViewController presentationAtIndex:(NSInteger)index;
@optional
/** 默认显示 */
- (nonnull UIView *)collectionViewController:(CKCollectionViewController *)collectionViewController placeholderAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END

