//
//  DSShufflingCell.h
//  ShufflingManager
//
//  Created by  lxx on 2017/4/10.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

// 颜色的简单构成宏
#define DSShufflingRGB(R, G, B, a) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:a]

#import <UIKit/UIKit.h>
@class DSShufflingCell;
@class DSShufflingModel;

@protocol DSShufflingCellDelegate <NSObject>

- (void)shufflingCell:(DSShufflingCell*)cell showImageView:(UIImageView*)showImageView;

@end

@interface DSShufflingCell : UICollectionViewCell

@property (nonatomic, weak) id<DSShufflingCellDelegate> delegate;

@property (nonatomic, strong) DSShufflingModel* model;

#pragma mark - 样式的配置
/** 占位图 */
@property (nonatomic, strong) UIImage* DSPlaceholder;

/** 标题的遮罩 */
@property (nonatomic, strong) UIColor* DSShadeColor;

@end
