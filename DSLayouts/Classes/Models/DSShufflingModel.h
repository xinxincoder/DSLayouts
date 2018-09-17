//
//  DSShufflingModel.h
//  ShufflingManager
//
//  Created by  lxx on 2017/4/10.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSShufflingModel : NSObject

#pragma mark - 都在子类中赋值
/**
 * 显示的网络图片
 */
@property (nonatomic, copy, readonly) NSString* DSImageURL;

/**
 * 显示的本地图片
 */
@property (nonatomic, copy, readonly) NSString* DSImageName;

/**
 * 显示的内容
 */
@property (nonatomic, copy, readonly) NSString* DSTitle;

@end
