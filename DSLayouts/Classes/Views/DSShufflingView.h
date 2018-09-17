//
//  DSShufflingView.h
//  ShufflingManager
//
//  Created by  lxx on 2017/4/10.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSShufflingView;

typedef NS_ENUM(NSUInteger, DSShufflingViewType) {
    
    DSShufflingViewTypeDefault,     //线性排列
    DSShufflingViewTypeCoverFlow,   //封面流转排列
    DSShufflingViewTypeLinear,      //线性缩放排列
    DSShufflingViewTypeCrossFading, //渐变排列
    DSShufflingViewTypeZoomOut,     //全屏缩放排列
    
};

typedef NS_ENUM(NSUInteger, DSShufflingViewPageControlPosition) {
    
    DSShufflingViewPageControlPositionRight,
    DSShufflingViewPageControlPositionCenter,
    DSShufflingViewPageControlPositionLeft,
    
};

@protocol DSShufflingViewDelegate <NSObject>

@optional
/**
 点击轮播图中的某一张

 @param shufflingView DSShufflingView对象
 @param model 点击这个张相关的model
 */
- (void)shufflingView:(DSShufflingView*)shufflingView didSelectWithModel:(id)model;

- (void)shufflingView:(DSShufflingView*)shufflingView showImageView:(UIImageView *)showImageView URLString:(NSString*)URLString;

@end

@interface DSShufflingView : UIView

@property (nonatomic, weak) id<DSShufflingViewDelegate> delegate;

/** 轮播图的数据 */
@property (nonatomic, strong) NSArray* shufflings;

#pragma mark - 样式的配置

/** 标题的遮罩 */
@property (nonatomic, strong) UIColor* DSShadeColor;

/** 排列类型 */
@property (nonatomic, assign) DSShufflingViewType type;
/** pageControl的位置 (默认在右边)*/
@property (nonatomic, assign) DSShufflingViewPageControlPosition pageControlPosition;

/** 占位图，必须要设置 */
@property (nonatomic, strong) UIImage* DSPlaceholder;

#pragma mark - UIPageControl 设置
/** 当前PageControl的颜色*/
@property (nonatomic, strong) UIColor* currentPageIndicatorTintColor;
/** 普通PageControl的颜色*/
@property (nonatomic, strong) UIColor* pageIndicatorTintColor;
/** 当前PageControl的图片*/
@property (nonatomic, strong) UIImage *currentPageImage;
/** 普通PageControl的图片*/
@property (nonatomic, strong) UIImage *pageImage;

/**
 滚到指定位置
 @param index 指定位置的索引
 @param animated 是否需要动画
 */
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
