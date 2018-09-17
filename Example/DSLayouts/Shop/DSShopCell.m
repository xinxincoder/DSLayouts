//
//  DSShopCell.m
//  WaterflowLayoutManager
//
//  Created by  lxx on 2017/4/15.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSShopCell.h"
#import "DSShop.h"

@interface DSShopCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageDSView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation DSShopCell

- (void)setShop:(DSShop *)shop {
    _shop = shop;
    
    self.imageDSView.backgroundColor = shop.color;
    self.nameLabel.text = shop.name;
}

@end
