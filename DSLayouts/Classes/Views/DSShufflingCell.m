//
//  DSShufflingCell.m
//  ShufflingManager
//
//  Created by  lxx on 2017/4/10.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSShufflingCell.h"
#import "DSShufflingModel.h"

@interface DSShufflingCell ()

@property (weak, nonatomic) UIImageView *suffingImageView;
/** 显示标题时候的遮盖效果 */
@property (nonatomic, weak) UIView* shadeView;
/** 显示标题 */
@property (nonatomic, weak) UILabel* tipsLabel;

@end

@implementation DSShufflingCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOpacity = 0.75;
    self.contentView.layer.shadowOffset = CGSizeZero;
//    self.contentView.layer.masksToBounds = YES;
    [self createSubviews];

    return self;
}

- (void)createSubviews {
    
    UIImageView *suffingImageView = [[UIImageView alloc] init];
    suffingImageView.backgroundColor = [UIColor clearColor];
    suffingImageView.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:suffingImageView];
    self.suffingImageView = suffingImageView;
    
    UIView* shadeView = [[UIView alloc] init];
    shadeView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:shadeView];
    self.shadeView = shadeView;
    
    UILabel* tipsLabel = [[UILabel alloc] init];
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.numberOfLines = 0;
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.font = [UIFont systemFontOfSize:13];
    [shadeView addSubview:tipsLabel];
    self.tipsLabel = tipsLabel;
}

- (void)setDSShadeColor:(UIColor *)DSShadeColor {
    _DSShadeColor = DSShadeColor;
    self.shadeView.backgroundColor = DSShadeColor;
}

- (void)setModel:(DSShufflingModel *)model {
    _model = model;
    
    if (_model.DSImageURL) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(shufflingCell:showImageView:)]) {
            // 加载网络图片
            [self.delegate shufflingCell:self showImageView:self.suffingImageView];
        } else {
            self.suffingImageView.image = self.DSPlaceholder;
        }
        
    } else if (_model.DSImageName){
        
        self.suffingImageView.image = [UIImage imageNamed:_model.DSImageName];
        
    } else {
        
        self.suffingImageView.image = self.DSPlaceholder;
    }
    
    if (_model.DSTitle && [_model.DSTitle isKindOfClass:[NSString class]]) {
        
        self.tipsLabel.text = _model.DSTitle;
        
    } else {
        
        self.tipsLabel.text = @"";
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.suffingImageView.frame = self.contentView.bounds;
    self.shadeView.frame = CGRectMake(0, CGRectGetHeight(self.contentView.frame)-25.0, CGRectGetWidth(self.contentView.frame), 25.0);
    self.tipsLabel.frame = CGRectMake(15, 0, CGRectGetWidth(self.shadeView.frame) - 15, CGRectGetHeight(self.shadeView.frame));
}

@end
