//
//  DSWaterflowLayout.h
//  WaterflowLayoutManager
//
//  Created by  lxx on 2017/4/15.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

// 感谢 MJ .

// 参考博客: http://blog.csdn.net/majiakun1/article/details/17204921
// 参考博客: http://blog.csdn.net/qq_30513483/article/details/51611653

#import <UIKit/UIKit.h>
@class DSWaterflowLayout;

@protocol DSWaterflowLayoutDelegate <UICollectionViewDelegateFlowLayout>

- (CGFloat)waterflowLayout:(DSWaterflowLayout *)waterflowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath;

@end

@interface DSWaterflowLayout : UICollectionViewLayout

/** 设置内嵌 默认:10 */
@property (nonatomic, assign) UIEdgeInsets sectionInset;
/** 每一列之间的间距 默认:10 */
@property (nonatomic, assign) CGFloat columnMargin;
/** 每一行之间的间距 默认:10 */
@property (nonatomic, assign) CGFloat rowMargin;
/** 显示多少列 默认:3 */
@property (nonatomic, assign) int columnsCount;

/** 代理 */
@property (nonatomic, weak) id<DSWaterflowLayoutDelegate> delegate;

@end
