//
//  CKCollectionViewController.m
//  CommonKit
//
//  Created by Admin on 2017/9/29.
//

#import "CKCollectionViewController.h"
#import "CKCollectionViewCell.h"
#import "UIViewController+CKAssist.h"
#import "Masonry.h"
#import "UIScrollView+CKFullScreenPop.h"

//判断是否是iPhone X
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (\
CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) || \
CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) || \
CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) || \
CGSizeEqualToSize(CGSizeMake(750, 1624), [[UIScreen mainScreen] currentMode].size)) : NO)

@interface CKCollectionViewController ()

@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL didLoad;//是否是视图刚刚创建调用viewDidLoad

@end

@implementation CKCollectionViewController

static NSString * const cellReuseIdentifier = @"CellReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.didLoad = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //回到界面刷新布局
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self resizeColectionViewWithSize:self.collectionView.frame.size];
}

- (void)viewWillAppearInPagesController {
    [super viewWillAppearInPagesController];
    //是二级 界面的时候刷新视图 防止二级界面获取的高度异常
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self resizeColectionViewWithSize:self.collectionView.frame.size];
}

//屏幕旋转的时候iPhoneX 改变边距在重新设置
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if (self.navigationController.viewControllers.count > 1) {
        return;
    }
    [self setVisibleViewController];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (_shouldAutoRotate) {
        [self resizeColectionViewWithSize:size];
    }
}

- (void)delaySetCollectionViewSize:(NSValue *)value {
    CGSize size = value.CGSizeValue;
    self.isScrolling = NO;
    if (self.didLoad) {
        CGSize collectionSize = self.collectionView.frame.size;
        if (size.width == collectionSize.width) {
            //要先判断width 相等再赋值是考虑到旋转的时候 size 不能跟collectionSize一样 因为旋转过来后collectionView size 还是原先的size 所以旋转的时候是用代理里面给的 将要旋转成的size
            //第一次进入的时候延时后取collectionView 的size 因为size之后可能会被约束调整到合适的大小 不然会导致高度异常
            size.height = collectionSize.height;
        }
        [self resizeColectionViewWithSize:size];
        self.didLoad = NO;
    }
}

- (void)resizeColectionViewWithSize:(CGSize)size {
    
    if (self.isScrolling) {
        //点击滚动的话也可以不重新设置itemSize 因为size其实并没有发生变化 等发生变化后会触发次方法 设置contentOffset 在滚动中有概率影响后面根据contentOffset 取index 但是第一次加载的时候要根据父视图调整size 所以要延时一会再调整
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delaySetCollectionViewSize:) object:[NSValue valueWithCGSize:size]];
        [self performSelector:@selector(delaySetCollectionViewSize:) withObject:[NSValue valueWithCGSize:size] afterDelay:0.5];
        return;
    }
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    flow.itemSize = size;
    self.collectionView.collectionViewLayout = flow;
    [self.collectionView.collectionViewLayout invalidateLayout];
    CKCollectionViewCell *currentCell = (CKCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    
    CGRect frame = currentCell.frame;
    frame.size = flow.itemSize;
    currentCell.frame = frame;
    self.collectionView.contentSize = CGSizeMake(frame.size.width * [self.dataSource presentationCountForCollectionViewController:self], frame.size.height);
    CGPoint newContentOffset = CGPointMake([self correctionSelectedIndex:_selectedIndex] * frame.size.width, 0);
    self.collectionView.contentOffset = newContentOffset;
}

- (void)scrollToItemAtIndex:(NSInteger)index atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [self scrollToItemAtIndex:index atScrollPosition:scrollPosition animated:animated delay:0.0];
}

- (void)scrollToItemAtIndex:(NSInteger)index atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated delay:(NSTimeInterval)delay
{
    self.isScrolling = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setLastViewControllerEndEditing];
        self.selectedIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        @try {
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:scrollPosition
                                                animated:animated];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        if (!animated) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setVisibleViewController) object:nil];
            [self performSelector:@selector(setVisibleViewController) withObject:nil afterDelay:0.1];
        }
    });
}

- (void)reloadData
{
    if ([self.dataSource presentationCountForCollectionViewController:self] > 0) {
        [self.collectionView reloadData];
        [self scrollToItemAtIndex:self.selectedIndex atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dataSource presentationCountForCollectionViewController:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier
                                                                           forIndexPath:indexPath];
    
    UIViewController *viewController = [_dataSource collectionViewController:self
                                                         presentationAtIndex:indexPath.row];
    if (viewController && viewController.isViewLoaded) {
        if (![self.childViewControllers containsObject:viewController]) {
            [self addChildViewController:viewController];
        }
        [cell ck_setView:viewController.view safeArea:self.safeArea];
    } else if ([_dataSource respondsToSelector:@selector(collectionViewController:placeholderAtIndex:)]) {
        UIView *placeholder = [_dataSource collectionViewController:self
                                                 placeholderAtIndex:indexPath.row];
        [cell ck_setView:placeholder safeArea:self.safeArea];
    } else {
        [cell ck_setView:nil safeArea:self.safeArea];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = [_dataSource collectionViewController:self
                                                         presentationAtIndex:indexPath.row];
    if (viewController && viewController.isViewLoaded) {
        [viewController viewWillDisappearInPagesController];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout nonnull CGPoint *)targetContentOffset {
    self.selectedIndex = [self correctionSelectedIndex:targetContentOffset->x / scrollView.frame.size.width];
    if ([_delegate respondsToSelector:@selector(collectionViewController:willTransitionToViewControllerAtIndex:)]) {
        [_delegate collectionViewController:self willTransitionToViewControllerAtIndex:self.selectedIndex];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setLastViewControllerEndEditing];
    if (indexPath.row == 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setVisibleViewController) object:nil];
        [self performSelector:@selector(setVisibleViewController) withObject:nil afterDelay:0.35];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setVisibleViewController) object:nil];
    [self performSelector:@selector(setVisibleViewController) withObject:nil afterDelay:0.1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setVisibleViewController) object:nil];
    [self performSelector:@selector(setVisibleViewController) withObject:nil afterDelay:0.1];
}

//RTL 语言的时候用contentOffset 计算index 要反过来
- (NSInteger)correctionSelectedIndex:(NSInteger)selectedIndex {
    
    if ([self isRTL]) {
        selectedIndex = [_dataSource presentationCountForCollectionViewController:self] - 1 - selectedIndex;
    }
    return selectedIndex;
}

- (BOOL)isRTL {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        UIUserInterfaceLayoutDirection direction = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.view.semanticContentAttribute];
        return direction == UIUserInterfaceLayoutDirectionRightToLeft;
    }
    return NO;
}

- (void)setLastViewControllerEndEditing {
    UIViewController *viewController = [_dataSource collectionViewController:self
                                                         presentationAtIndex:self.selectedIndex];
    if (viewController && viewController.isViewLoaded) {
        [viewController.view endEditing:YES];
    }
}

- (void)setVisibleViewController {
    
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    self.selectedIndex = [self correctionSelectedIndex:floor(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)] ;
    
    
    CKCollectionViewCell * cell = (CKCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
    if (!cell && self.collectionView.visibleCells.count > 0) {
        //万一匹配出错取后面的cell 因为前面的有很大概率已经加载过了，所以一般显示不正常的会出现在后面
        cell = self.collectionView.visibleCells.lastObject;
    }
    
    UIViewController *viewController = [_dataSource collectionViewController:self
                                                         presentationAtIndex:self.selectedIndex];
    if (viewController && cell) {
        if (![self.childViewControllers containsObject:viewController]) {
            [self addChildViewController:viewController];
        }
        viewController.isChildOfPagesController = YES;
        [cell ck_setView:viewController.view safeArea:self.safeArea];
        [viewController viewWillAppearInPagesController];
    }
    NSArray *Localizations = [[NSBundle mainBundle] preferredLocalizations];
    NSString * language = nil;
    
    if (Localizations.count > 0) {
        language = Localizations[0];
    }
    if (([language isEqualToString:@"ar"] != [self isRTL])) {
        self.collectionView.bounces = self.selectedIndex != [_dataSource presentationCountForCollectionViewController:self] - 1;
    } else {
        self.collectionView.bounces = self.selectedIndex != 0;
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = self.view.frame.size;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollsToTop = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.allowsMultipleSelection = NO;
        _collectionView.allowsSelection = NO;
        //标记成支持滑动返回的tag
        _collectionView.tag = kCKFullScreenPopTag;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            _collectionView.semanticContentAttribute = [UIView appearance].semanticContentAttribute;
        }
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
            //iOS10 新增 prefetching  会导致调用 scrollToItemAtIndexPath 时 触发两次scrollViewDidEndScrollingAnimation 回到 导致用contentOffset可能计算index 异常
            _collectionView.prefetchingEnabled = NO;
        }
        [_collectionView registerClass:[CKCollectionViewCell class]
            forCellWithReuseIdentifier:cellReuseIdentifier];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
    return _collectionView;
}

@end

