//
//  DSShufflingCustomLayout.h
//  LineLayout
//
//  Created by XXL on 2017/5/3.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DSShufflingCustomLayoutType) {
    
    DSShufflingCustomLayoutTypeFlow,       //线性布局（系统）
    DSShufflingCustomLayoutTypeCoverFlow,  //封面流转
    DSShufflingCustomLayoutTypeLinear,     //线性缩放
    DSShufflingCustomLayoutTypeCrossFading,//渐变
    DSShufflingCustomLayoutTypeZoomOut,    //全屏缩放
    
};

@interface DSShufflingCustomLayout : UICollectionViewLayout

/** cell的宽度 + cell之间的空隙 */
@property (nonatomic) CGFloat itemSpacing;
/** cell之间的空隙 */
@property (nonatomic) CGFloat interitemSpacing;
/** cell的大小 */
@property (nonatomic) CGSize itemSize;
/** 布局类型 */
@property (nonatomic, assign) DSShufflingCustomLayoutType layoutType;

/** 初始化类方法（默认线性布局） */
+ (instancetype)shufflingCustomLayout;
/** 初始化类方法（可选布局） */
+ (instancetype)shufflingCustomLayoutWithLayoutType:(DSShufflingCustomLayoutType)layoutType;

@end
