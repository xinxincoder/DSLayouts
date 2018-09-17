//
//  ViewController.m
//  ShufflingManager
//
//  Created by  lxx on 2017/4/10.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "ViewController.h"
#import "DSShufflingView.h"
#import "DSMode.h"
#import "UIImageView+WebCache.h"

/*
http://upload-images.jianshu.io/upload_images/1198135-ecbabb99d89a8a0b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240
 
http://upload-images.jianshu.io/upload_images/1198135-59c5b38268afec47.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240
http://upload-images.jianshu.io/upload_images/1198135-6ed3ea5fc22ece9e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240
 
 */

@interface ViewController () <DSShufflingViewDelegate>

@property (weak, nonatomic) IBOutlet DSShufflingView *shufflingView;

@property (nonatomic, strong) NSMutableArray* imageNames;

@property (nonatomic, strong) NSMutableArray* imageURLs;

@property (nonatomic, weak) DSShufflingView* sfView;

@end

@implementation ViewController

#pragma mark - 懒加载
- (NSMutableArray *)imageNames {
    if (!_imageNames) {
        _imageNames = [NSMutableArray array];
        
        for (NSInteger i=0; i<3; i++) {
            DSMode* mode = [[DSMode alloc] init];
            mode.title = [NSString stringWithFormat:@"第 %02zd 张图片", i];
            mode.imageName = [NSString stringWithFormat:@"image%02zd", i];
            
            [_imageNames addObject:mode];
        }
        
        
    }
    return _imageNames;
}

#pragma mark - 懒加载
// 模拟获取数据
- (NSMutableArray *)imageURLs {
    if (!_imageURLs) {
        
        DSMode* mode0 = [[DSMode alloc] init];
        mode0.title = @"第一张网络图片";
        mode0.imageURL = @"http://upload-images.jianshu.io/upload_images/1198135-ecbabb99d89a8a0b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";
        
        DSMode* mode1 = [[DSMode alloc] init];
        mode1.title = @"第二张网络图片";
        mode1.imageURL = @"http://upload-images.jianshu.io/upload_images/1198135-59c5b38268afec47.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";
        
        DSMode* mode2 = [[DSMode alloc] init];
        mode2.title = @"第三张网络图片";
        mode2.imageURL = @"http://upload-images.jianshu.io/upload_images/1198135-6ed3ea5fc22ece9e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";
        
        _imageURLs = [NSMutableArray array];
        [_imageURLs addObject:mode0];
        [_imageURLs addObject:mode1];
        [_imageURLs addObject:mode2];
        
    }
    return _imageURLs;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.shufflingView.shufflings = self.imageNames;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 本地图片
    self.shufflingView.delegate = self;
    self.shufflingView.DSPlaceholder = [UIImage imageNamed:@"ADLoop_placeholder"];

    
    // 网络图片
    DSShufflingView* sfView = [[DSShufflingView alloc] init];
    // 占位图

    sfView.DSPlaceholder = [UIImage imageNamed:@"ADLoop_placeholder"];

    // 代理
    sfView.delegate = self;
    // 数据
    sfView.shufflings = self.imageURLs;
    // 添加到视图
    [self.view addSubview:sfView];
    self.sfView = sfView;
    
    // 网络图片
//    DSShufflingView* sfView = [[DSShufflingView alloc] init];
//    sfView.emmPlaceholder = @"ADLoop_placeholder";
//    sfView.delegate = self;
//    sfView.shufflings = self.imageURLs;
//    [self.view addSubview:sfView];
//    self.sfView = sfView;
    
//     网络图片
//    DSShufflingView* sfView = [[DSShufflingView alloc] init];
//    sfView.emmPlaceholder = @"ADLoop_placeholder";
//    sfView.delegate = self;
//    sfView.shufflings = self.imageURLs;
//    [self.view addSubview:sfView];
//    self.sfView = sfView;
 
}


#pragma mark -
#pragma mark - DSShufflingViewDelegate
- (void)shufflingView:(DSShufflingView *)shufflingView didSelecteWithMode:(DSMode*)mode {
    NSLog(@"您点击的是:  %@ ", mode.title);
}

- (void)shufflingView:(DSShufflingView *)shufflingView showImageView:(UIImageView *)showImageView URLString:(NSString *)URLString {
    [showImageView sd_setImageWithURL:[NSURL URLWithString:URLString] placeholderImage:shufflingView.DSPlaceholder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat x = 0;
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = 150.0;
    CGFloat y = CGRectGetHeight(self.view.frame) - height - 10;
    
    _sfView.frame = CGRectMake(x, y, width, height);
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.shufflingView.type = (self.shufflingView.type + 1)%2;
//}


@end
