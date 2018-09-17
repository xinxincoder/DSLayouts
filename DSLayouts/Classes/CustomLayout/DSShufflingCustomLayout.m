//
//  DSShufflingCustomLayout.m
//  LineLayout
//
//  Created by XXL on 2017/5/3.
//
//

#import "DSShufflingCustomLayout.h"

#define MCTotalRowsInSection (5000 * 3)

#define MCDefaultRow (NSUInteger)(MCTotalRowsInSection * 0.5)


@interface DSShufflingCustomLayout () {
    
    CGFloat   _edgeSpacing;                      //最左边和最右边的与cell的间距
    NSInteger _numberOfItems;                    // 总共多少个cell
    CGFloat   _contentWidth;                     //collection的contentsize的width
    BOOL      _isNeedUpdateCollectionViewBounds; //是否需要更新collectionview的bounds（第一次启动要刷新）
}

@end

@implementation DSShufflingCustomLayout

#pragma mark - lazyloading
- (CGSize)itemSize {
    
    if (CGSizeEqualToSize(CGSizeZero, _itemSize)) {
        
        _itemSize = self.collectionView.frame.size;
    }
    return _itemSize;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _isNeedUpdateCollectionViewBounds = YES;
    }
    return self;
}

- (instancetype)initWithShufflingCustomLayoutWithLayoutType:(DSShufflingCustomLayoutType)layoutType {
    
    self = [super init];
    if (self) {
        
        _isNeedUpdateCollectionViewBounds = YES;
        self.layoutType = layoutType;
        
    }
    return self;
    
}

/** 初始化类方法（默认线性布局） */
+ (instancetype)shufflingCustomLayout {
    
    return [[self alloc] init];
}

/** 初始化类方法（可选布局） */
+ (instancetype)shufflingCustomLayoutWithLayoutType:(DSShufflingCustomLayoutType)layoutType {
    
    return [[self alloc] initWithShufflingCustomLayoutWithLayoutType:layoutType];
    
}

- (void)prepareLayout {
    [super prepareLayout];
    
    switch (self.layoutType) {
            
        case DSShufflingCustomLayoutTypeFlow:
        case DSShufflingCustomLayoutTypeZoomOut:
        case DSShufflingCustomLayoutTypeCrossFading:
            
            _itemSize = self.collectionView.frame.size;
            break;
    
        case DSShufflingCustomLayoutTypeCoverFlow:
            
            _itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame)-80, CGRectGetHeight(self.collectionView.frame));
            break;
        
        case DSShufflingCustomLayoutTypeLinear:
            
            _itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame)*2/3, CGRectGetHeight(self.collectionView.frame));
            break;
    }
    
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    _edgeSpacing = (CGRectGetWidth(self.collectionView.frame) - self.itemSize.width)*0.5;
    _itemSpacing = self.itemSize.width + self.interitemSpacing;
    _numberOfItems = [self.collectionView numberOfItemsInSection:0];
    
    _contentWidth = _edgeSpacing*2 + _numberOfItems*_itemSpacing + (_numberOfItems-1)*self.interitemSpacing;
    
    if (_isNeedUpdateCollectionViewBounds) {
    
        CGRect newBounds = CGRectMake(_numberOfItems * 0.5 *_itemSpacing, 0, CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame));
        
        self.collectionView.bounds = newBounds;
        
        _isNeedUpdateCollectionViewBounds = NO;
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *attributesArray = [NSMutableArray array];
    
    CGFloat rectMinX = CGRectGetMinX(rect);
    CGFloat rectMaxX = CGRectGetMaxX(rect);
    
    NSInteger startIndex = MAX((rectMinX - _edgeSpacing)/_itemSpacing, 0);
    
    CGFloat startPosition = _edgeSpacing + startIndex * _itemSpacing;
    
    CGFloat endPosition = MIN(rectMaxX, _contentWidth - _itemSpacing - _edgeSpacing);
    
    while (startPosition <= endPosition) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:startIndex inSection:0];
        
        [attributesArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        startIndex += 1;
        startPosition += _itemSpacing;
    }

    return attributesArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    attributes = [self calculateLayoutWithtype:self.layoutType attributes:attributes indexPath:indexPath];
    
    return attributes;
}

- (CGSize)collectionViewContentSize {
    
    CGFloat contentHeight = CGRectGetHeight(self.collectionView.frame);
    return CGSizeMake(_contentWidth, contentHeight);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGFloat startOffsetX = roundf(self.collectionView.contentOffset.x/_itemSpacing) * _itemSpacing;
    
    CGFloat proposedOffsetX = startOffsetX;
    
    CGPoint translation = [self.collectionView.panGestureRecognizer translationInView:self.collectionView];
    
    CGFloat minTranslationDistance = MIN(_itemSpacing*0.5, 150);
    
    if (ABS(translation.x) < minTranslationDistance) {
       
        if (ABS(velocity.x) > 0.3 && ABS(startOffsetX - proposedOffsetX) < _itemSpacing) {
            
            proposedOffsetX += _itemSpacing*velocity.x/ABS(velocity.x);
        }
    }
    
    if (ABS(proposedOffsetX - startOffsetX) >= 2*_itemSpacing) {

        proposedOffsetX += _itemSpacing*velocity.x/ ABS(velocity.x);
    }
    
    return CGPointMake(proposedOffsetX, proposedContentOffset.y);
    
//    CGFloat startContentOffsetX = roundf(self.collectionView.contentOffset.x/_itemSpacing) * _itemSpacing;
//
//    CGFloat proposedContentOffsetX = ceilf(proposedContentOffset.x/_itemSpacing) * _itemSpacing;
    
//    CGPoint translation = [self.collectionView.panGestureRecognizer translationInView:self.collectionView];
////
//    CGFloat minTranslationDistance = MIN(_itemSpacing*0.5, 150);
//    CGFloat originalContentOffsetX = self.collectionView.contentOffset.x - translation.x;
//    if (ABS(translation.x) < minTranslationDistance) {
////
//        if (ABS(velocity.x) >= 0.3 && ABS(proposedContentOffset.x - originalContentOffsetX) <= _itemSpacing*0.5) {
//
//            proposedContentOffsetX += _itemSpacing * velocity.x/ABS(velocity.x);
//        }
//    }
//
//    if (ABS(velocity.x) >= 0.3) {
//
//        proposedContentOffsetX += _itemSpacing * velocity.x/ABS(velocity.x);
//    }
//
//    if (ABS(proposedContentOffsetX - startContentOffsetX) >= 2*_itemSpacing) {
//
//        proposedContentOffsetX = startContentOffsetX + _itemSpacing * velocity.x/ABS(velocity.x);
//    }
    

    
//    return CGPointMake(proposedContentOffsetX, proposedContentOffset.y);
}

#pragma mark - CalculateLayout
- (UICollectionViewLayoutAttributes *)calculateLayoutWithtype:(DSShufflingCustomLayoutType)type attributes:(UICollectionViewLayoutAttributes *)attributes indexPath:(NSIndexPath *)indexPath {
    
    attributes.size = self.itemSize;
    CGFloat x = _edgeSpacing + indexPath.item * _itemSpacing;
    CGFloat y = (CGRectGetHeight(self.collectionView.frame) - self.itemSize.height)*0.5;
    attributes.frame = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);

    CGFloat centerX = CGRectGetMidX(self.collectionView.bounds);
    
    CGFloat attributesCenterX = attributes.center.x;
    
    CGFloat proportion = (attributesCenterX - centerX)/_itemSpacing;
    
    switch (type) {
            
        case DSShufflingCustomLayoutTypeFlow:
            
            break;
            
        case DSShufflingCustomLayoutTypeCoverFlow: {
        
            CGFloat position = MIN(MAX(-proportion,-1) ,1);
            CGFloat rotation = sinf(position*(M_PI)*0.5)*(M_PI)*0.25*1.5;
            CGFloat translationZ = _itemSpacing * 0.5 * ABS(position);
            
            CATransform3D transform3D = CATransform3DIdentity;
            transform3D.m34 = -1/500.0;
            transform3D = CATransform3DRotate(transform3D, rotation, 0, 1, 0);
            transform3D = CATransform3DTranslate(transform3D, 0, 0, translationZ - 10);
            attributes.transform3D = transform3D;

            break;

        }
            
        case DSShufflingCustomLayoutTypeLinear: {
            
            CGFloat scale = (1 - ABS(proportion)*0.35);
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            transform = CGAffineTransformMakeScale(scale, scale);
            
            transform = CGAffineTransformTranslate(transform,-proportion*35, 0);
            
            attributes.transform = transform;
            
            break;
        }
            
        case DSShufflingCustomLayoutTypeCrossFading: {
        
            NSInteger zIndex = 0;
            CGFloat alpha = 0;
            CGAffineTransform transform = CGAffineTransformIdentity;
    
            transform.tx = -_itemSpacing * proportion;
    
            if (ABS(proportion) < 1) {
        
                alpha = 1 - ABS(proportion);
                zIndex = 1;
                
            } else {
        
                alpha = 0;
                zIndex = INT_MIN;
            }
            attributes.alpha = alpha;
            attributes.transform = transform;
            attributes.zIndex = zIndex;

            break;
            
        }
            
        case DSShufflingCustomLayoutTypeZoomOut: {
            
            CGFloat scale = (1 - ABS(proportion)*0.3);
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformMakeScale(scale, scale);
            
            attributes.zIndex = 10 - ABS(proportion)*10;
            attributes.transform = transform;
            
            break;
        }
            
    }
    
    return attributes;
}

@end
