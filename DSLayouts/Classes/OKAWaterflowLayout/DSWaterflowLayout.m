//
//  DSWaterflowLayout.m
//  WaterflowLayoutManager
//
//  Created by  lxx on 2017/4/15.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSWaterflowLayout.h"

@interface DSWaterflowLayout ()


/** 这个字典用来存储每一列最大的Y值(每一列的高度) */
@property (nonatomic, strong) NSMutableDictionary *maxYDict;

/** 存放所有的布局属性 */
@property (nonatomic, strong) NSMutableArray *attrsArray;

/**
 每个 section 的最高最 (当有多个 section 的时候起作用)
 */
@property (nonatomic, strong) NSMutableArray* sectionMaxHeights;

@end

@implementation DSWaterflowLayout

#pragma mark - 懒加载

- (NSMutableDictionary *)maxYDict
{
    if (!_maxYDict) {
        self.maxYDict = [[NSMutableDictionary alloc] init];
    }
    return _maxYDict;
}

- (NSMutableArray *)attrsArray
{
    if (!_attrsArray) {
        self.attrsArray = [[NSMutableArray alloc] init];
    }
    return _attrsArray;
}

- (NSMutableArray *)sectionMaxHeights {
    if (!_sectionMaxHeights) {
        _sectionMaxHeights = [NSMutableArray array];
    }
    return _sectionMaxHeights;
}

#pragma mark - 构造方法
- (instancetype)init
{
    if (self = [super init]) {
        self.columnMargin = 10;
        self.rowMargin = 10;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.columnsCount = 3;
    }
    return self;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


/**
 *  每次布局之前的准备
 */
- (void)prepareLayout
{
    [super prepareLayout];
    
    // 1.清空最大的Y值, 默认top
//    for (int i = 0; i<self.columnsCount; i++) {
//        NSString *column = [NSString stringWithFormat:@"%d", i];
//        self.maxYDict[column] = @(self.sectionInset.top);
//    }
    
    {
//        id<UICollectionViewDelegateFlowLayout> delegate = self.collectionView.delegate;
//        
//        if (delegate && [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)] && [delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
//            CGSize size = [delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:0];
//            
//            NSLog(@"%f", size.height);
//        }
        
    }
    
    // 2.计算所有cell的属性
    [self.attrsArray removeAllObjects];
    [self.sectionMaxHeights removeAllObjects];
    
    NSUInteger section = [self.collectionView numberOfSections];
    for (NSInteger i=0; i<section; i++) {
        NSUInteger row = [self.collectionView numberOfItemsInSection:i];
        
        // 头
        [self.attrsArray addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]]];
        
        // cells
        for (NSInteger j=0; j<row; j++) {
            
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.attrsArray addObject:attrs];
        }
        
    }
}


/**
 *  返回所有的尺寸
 */
- (CGSize)collectionViewContentSize
{
    __block NSString *maxColumn = @"0";
    [self.maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString *column, NSNumber *maxY, BOOL *stop) {
        if ([maxY floatValue] > [self.maxYDict[maxColumn] floatValue]) {
            maxColumn = column;
        }
    }];
    return CGSizeMake(0, [self.maxYDict[maxColumn] floatValue] + self.sectionInset.bottom);
}


/**
 *  返回indexPath这个位置Item的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item == 0) {
        CGSize size = [self layoutHeraderHeightWithSection:indexPath.section];
        if (indexPath.section == 0) {
            for (int i = 0; i<self.columnsCount; i++) {
                NSString *column = [NSString stringWithFormat:@"%d", i];
                self.maxYDict[column] = @(self.sectionInset.top + size.height - self.rowMargin);
            }
        } else {
            for (int i = 0; i<self.columnsCount; i++) {
                
                NSNumber* maxHeightNumer = self.sectionMaxHeights[indexPath.section-1];
                
                NSString *column = [NSString stringWithFormat:@"%d", i];
                self.maxYDict[column] = @(self.sectionInset.top + maxHeightNumer.floatValue + size.height - self.rowMargin);
            }
        }
    }
    
    
    
    // 假设最短的那一列的第0列
    __block NSString *minColumn = @"0";
    // 找出最短的那一列
    [self.maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString *column, NSNumber *maxY, BOOL *stop) {
        if ([maxY floatValue] < [self.maxYDict[minColumn] floatValue]) {
            minColumn = column;
        }
    }];
    
    // 计算尺寸
    CGFloat width = (self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right - (self.columnsCount - 1) * self.columnMargin)/self.columnsCount;
    
    // 必须要实现的代理,可以这么写.
    CGFloat height = [self.delegate waterflowLayout:self heightForWidth:width atIndexPath:indexPath];
    
    // 计算位置
    CGFloat x = self.sectionInset.left + (width + self.columnMargin) * [minColumn intValue];
    CGFloat y = [self.maxYDict[minColumn] floatValue] + self.rowMargin;
    
    // 更新这一列的最大Y值
    self.maxYDict[minColumn] = @(y + height);
    
    // 创建属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = CGRectMake(x, y, width, height);
    
    // 获取当前section的总的item.
    NSUInteger item = [self.collectionView numberOfItemsInSection:indexPath.section];
    if (indexPath.item == (item-1)) {
        // 已经是当前 section 的最后一个了.记录当前section的最高值
        [self.sectionMaxHeights addObject:@(y + height + self.sectionInset.bottom)];
    }
    
    return attrs;
}

/**
 *  返回rect范围内的布局属性
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attrsArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    CGSize size = [self layoutHeraderHeightWithSection:indexPath.section];
    if (size.height > 0.0) {
        
        CGFloat height = 0.0f;
        
        if (self.sectionMaxHeights.count > 0) {
            NSNumber* heightNumber = self.sectionMaxHeights[indexPath.section-1];
            height = heightNumber.doubleValue;
        }
        
        attrs.frame = CGRectMake(self.sectionInset.left, self.sectionInset.top + height, self.collectionView.frame.size.width - (self.sectionInset.left+self.sectionInset.right), size.height);
    }
    
    attrs.zIndex = 1;
    return attrs;
}

- (CGSize)layoutHeraderHeightWithSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    id<UICollectionViewDelegateFlowLayout> delegate = self.collectionView.delegate;
    
    if (delegate && [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)] && [delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        
        size = [delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
        
        NSLog(@"%f", size.height);
    }
    
    return size;
}

@end
