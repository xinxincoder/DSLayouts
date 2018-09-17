//
//  DSShufflingView.m
//  ShufflingManager
//
//  Created by  lxx on 2017/4/10.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSShufflingView.h"
#import "DSShufflingCell.h"
#import "DSShufflingCustomLayout.h"
#import "DSShufflingModel.h"

static NSString* const ID = @"DSShufflingCell";

// 每一组最大的行数
#define MCTotalRowsInSection (5000 * self.shufflings.count)
#define MCDefaultRow (NSUInteger)(MCTotalRowsInSection * 0.5)

@interface DSShufflingView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DSShufflingCellDelegate> {
    
    NSInteger _currentIndex;
}

@property (weak, nonatomic) UICollectionView* collectionView;
@property (weak, nonatomic) UIPageControl* pageControl;

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) DSShufflingCustomLayout* layout;

/** 当没有轮播图的时候,让其显示默认图 */
@property (nonatomic, weak) UIImageView* placeholderView;

@end

@implementation DSShufflingView

- (void)dealloc {
    
    [self removeTimer];
}

#pragma mark -
#pragma mark - 构造方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    // 子控件配置
    [self setupDSShuffling];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // 子控件配置
    [self setupDSShuffling];
    self.type = _type;
    self.DSPlaceholder = _DSPlaceholder;
    self.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
    self.pageIndicatorTintColor = _pageIndicatorTintColor;
    self.currentPageImage = _currentPageImage;
    self.pageImage = _pageImage;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        [self setupDSShuffling];
        self.type = _type;
        self.DSPlaceholder = _DSPlaceholder;
        self.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
        self.pageIndicatorTintColor = _pageIndicatorTintColor;
        self.currentPageImage = _currentPageImage;
        self.pageImage = _pageImage;
    }
    return self;
}

// 子控件配置
- (void)setupDSShuffling {
    
    DSShufflingCustomLayout* layout = [DSShufflingCustomLayout shufflingCustomLayout];
    self.layout = layout;
    
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.contentInset = UIEdgeInsetsMake(0, 0.0, 0, 0.0);
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    UIPageControl* pageControl = [[UIPageControl alloc] init];
    pageControl.hidesForSinglePage = YES;
    [self addSubview:pageControl];
    
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor =  DSShufflingRGB(255, 167, 1, 1);
    self.pageControl = pageControl;
    
    [self.collectionView registerClass:[DSShufflingCell class] forCellWithReuseIdentifier:ID];
    
    // addView
    UIImageView* placeholderView = [[UIImageView alloc] init];
    placeholderView.contentMode = UIViewContentModeRedraw;
    placeholderView.clipsToBounds = YES;
    [self addSubview:placeholderView];
    self.placeholderView = placeholderView;
}

#pragma mark - Set方法
- (void)setDSPlaceholder:(UIImage *)DSPlaceholder {
    _DSPlaceholder = DSPlaceholder;
    self.placeholderView.image = DSPlaceholder;
    
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    
    self.pageControl.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    
    _pageIndicatorTintColor = pageIndicatorTintColor;
    self.pageControl.pageIndicatorTintColor = _pageIndicatorTintColor;
}

- (void)setCurrentPageImage:(UIImage *)currentPageImage {
    _currentPageImage = currentPageImage;
    
    if (_currentPageImage) {
        
        [self.pageControl setValue:_currentPageImage forKeyPath:@"currentPageImage"];
    }
}

- (void)setPageImage:(UIImage *)pageImage {
    _pageImage = pageImage;
    
    if (_pageImage) {
        
        [self.pageControl setValue:_pageImage forKeyPath:@"pageImage"];
    }
}

- (void)setType:(DSShufflingViewType)type {
    _type = type;
    
    self.layout.layoutType = (DSShufflingCustomLayoutType)_type;
    
    [self.collectionView reloadData];
}

- (void)setShufflings:(NSArray *)shufflings {
    _shufflings = shufflings;
    
    self.collectionView.scrollEnabled = NO;
    // 总页数
    self.pageControl.numberOfPages = 0;
    
    // 图片总数
    NSInteger count = shufflings.count;
    if (count == 0) {
        [self removeTimer];
        
        self.collectionView.delegate = nil;
        self.collectionView.dataSource = nil;
        
        self.placeholderView.hidden = NO;
    }else if (count == 1) {
        [self removeTimer];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        self.placeholderView.hidden = YES;
        
        // 刷新数据
        [self.collectionView reloadData];
        
    }else {
        
        [self addTimer];
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        // 总页数
        self.pageControl.numberOfPages = count;
        
        // 刷新数据
        [self.collectionView reloadData];
        
        self.placeholderView.hidden = YES;
        
        self.collectionView.scrollEnabled = YES;
        
        self.pageControl.currentPage = 0;
    }
    
    [self setNeedsLayout];
}

#pragma mark - 定时器相关
/** 添加定时器 */
- (void)addTimer {
    // 先移除,再添加
    [self removeTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/** 移除定时器 */
- (void)removeTimer {
    
    [self.timer invalidate];
    self.timer = nil;
}

/** 定时器轮播 */
- (void)nextImage {
   
    if ((_currentIndex % self.shufflings.count)  == 0) { // 第0张图片
        
        [self scrollToItemAtIndex:MCDefaultRow animated:NO];
        
        _currentIndex = MCDefaultRow;
    }
    
    _currentIndex++;
    [self scrollToItemAtIndex:_currentIndex animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    _currentIndex = roundf(scrollView.contentOffset.x/self.layout.itemSize.width);
    self.pageControl.currentPage = _currentIndex % self.shufflings.count;
}

#pragma mark -
#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return MCTotalRowsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DSShufflingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    // 样式设置
    cell.DSPlaceholder = self.DSPlaceholder;
    cell.DSShadeColor = self.DSShadeColor;
    cell.delegate = self;
    cell.model = self.shufflings[indexPath.item % self.shufflings.count];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shufflingView:didSelectWithModel:)]) {
        DSShufflingCell* cell = (DSShufflingCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [self.delegate shufflingView:self didSelectWithModel:cell.model];
    }
}

#pragma mark -
#pragma mark - DSShufflingCellDelegate
- (void)shufflingCell:(DSShufflingCell *)cell showImageView:(UIImageView *)showImageView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shufflingView:showImageView:URLString:)]) {
        [self.delegate shufflingView:self showImageView:showImageView URLString:cell.model.DSImageURL];
    }
}

/** 开始拖拽的时候调用 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 停止定时器(一旦定时器停止了,就不能再使用)
    [self removeTimer];
}

/** 停止拖拽的时候调用 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 开启定时器
    [self addTimer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
#ifdef DEBUG

    if ((_currentPageImage && !_pageImage) || (!_currentPageImage && _pageImage)) {
        
        NSAssert(_currentPageImage && _pageImage, @"设置图片的话,currentPageImage和pageImage需要同时设置");
    }

#if !TARGET_INTERFACE_BUILDER //如果不是xib
    // 没有设置 self.emmPlaceholder 直接以闪退的形式提示.
     NSAssert(self.DSPlaceholder, @"必须要设置 'self.DSPlaceholder 的值' ");
    
#endif
    
#endif
    
    self.collectionView.frame = self.bounds;
    self.placeholderView.frame = self.bounds;
    
    CGFloat pageControlWidth;
    
    if (_pageImage) {
        
        pageControlWidth = (_pageImage.size.width+16)*self.shufflings.count;
        
    }else {
        
        pageControlWidth = 16.0*self.shufflings.count;
    }
    
    
    CGFloat pageCWidth = pageControlWidth;
    CGFloat pageCHeight = 25.0;
    CGFloat pageCY = CGRectGetHeight(self.frame)-pageCHeight;
    CGFloat pageCX = 0;
    
    switch (self.pageControlPosition) {
            
        case DSShufflingViewPageControlPositionRight: {
            
            pageCX = CGRectGetWidth(self.frame) - pageCWidth - 15;
            
            break;
        }
            
        case DSShufflingViewPageControlPositionCenter: {
            
            pageCX = (CGRectGetWidth(self.frame) - pageCWidth)*0.5 ;
            
            break;
        }
        case DSShufflingViewPageControlPositionLeft: {
            
            pageCX = 15;
            break;
        }
    }
    
    CGRect pageCFrame = CGRectMake(pageCX, pageCY, pageCWidth, pageCHeight);
    self.pageControl.frame = pageCFrame;
}

#pragma mark - 自定义方法
/**
 滚到指定位置
 @param index 指定位置的索引
 @param animated 是否需要动画
 */
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    CGFloat contentOffsetX = index * self.layout.itemSpacing;
    
    [self.collectionView setContentOffset:CGPointMake(contentOffsetX, 0) animated:animated];
}

@end
