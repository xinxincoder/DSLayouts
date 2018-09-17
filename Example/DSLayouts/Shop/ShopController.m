//
//  ShopController.m
//  DSShufflingDemo
//
//  Created by  lxx on 2017/9/10.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

// 0~1的随机数
#define DSWFRandom0_1 (arc4random_uniform(100)/100.0)

#import "ShopController.h"
#import "MJRefresh.h"
#import "DSWaterflowLayout.h"
#import "DSShopCell.h"
#import "DSShop.h"
#import "DSHeaderView.h"

static NSString* const ID = @"DSShopCell";
static NSString* const HeaderID = @"DSHeaderView";

@interface ShopController () <UICollectionViewDataSource, UICollectionViewDelegate, DSWaterflowLayoutDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *shops;

@end

@implementation ShopController


- (NSMutableArray *)shops
{
    if (_shops == nil) {
        self.shops = [NSMutableArray array];
    }
    return _shops;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 数据
    [self loadData];
    
    // 布局流
    DSWaterflowLayout *layout = [[DSWaterflowLayout alloc] init];
    layout.delegate = self;
    
    // 创建UICollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib:[UINib nibWithNibName:ID bundle:nil] forCellWithReuseIdentifier:ID];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // 注册 HeaderView
    [self.collectionView registerNib:[UINib nibWithNibName:HeaderID bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderID];
    
    // 增加刷新控件
    MJRefreshAutoStateFooter* footer = [MJRefreshAutoStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];
    self.collectionView.mj_footer = footer;
    
}

- (void)loadMoreShops {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData];
        [self.collectionView.mj_footer endRefreshing];
    });
}

// 假数据
- (void)loadData {
    for (NSInteger i=0; i<20; i++) {
        DSShop* shop = [[DSShop alloc] init];
        shop.w = 30 + 30*DSWFRandom0_1;
        shop.h = 50 + 40*DSWFRandom0_1;
        shop.color = [UIColor colorWithRed:DSWFRandom0_1 green:DSWFRandom0_1 blue:DSWFRandom0_1 alpha:1.0];
        
        shop.name = [NSString stringWithFormat:@"第 %zd 个商品", self.shops.count+1];
        [self.shops addObject:shop];
    }
    
    [self.collectionView reloadData];
}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.shops.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DSShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.shop = self.shops[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DSShopCell *cell = (DSShopCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSLog(@"你选中了 : %@ (%zd, %zd)", cell.shop.name, indexPath.section, indexPath.item);
}

#pragma mark - DSWaterflowLayoutDelegate
- (CGFloat)waterflowLayout:(DSWaterflowLayout *)waterflowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath {
    DSShop *shop = self.shops[indexPath.item];
    return shop.h / shop.w * width;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 40.0);
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DSHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderID forIndexPath:indexPath];
    
    headerView.tips = [NSString stringWithFormat:@"这里是第 %zd 个 部分", indexPath.section];
    
    return headerView;
}

@end
