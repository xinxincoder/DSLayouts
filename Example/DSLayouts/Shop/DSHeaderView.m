//
//  DSHeaderView.m
//  WaterflowLayoutManager
//
//  Created by  lxx on 2017/5/4.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSHeaderView.h"

@interface DSHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@end

@implementation DSHeaderView

- (void)setTips:(NSString *)tips {
    _tips = tips.copy;
    self.tipsLabel.text = _tips;
}

@end
