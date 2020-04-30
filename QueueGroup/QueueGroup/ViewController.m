//
//  ViewController.m
//  QueueGroup
//
//  Created by Mac on 2020/4/30.
//  Copyright © 2020 Mac. All rights reserved.
//

// 1.分别下载2张图片：大图片、LOGO
// 2.合并2张图片
// 3.显示到一个imageView身上


#define ImgUrl1 @"http://www.people.com.cn/mediafile/pic/20160902/28/713372195701445500.jpg"
#define ImgUrl2 @"http://photocdn.sohu.com/20130827/Img385203229.jpg"

#define ImgUrl3 @"http://pic1.win4000.com/wallpaper/a/57d7bda7209d9.jpg"
#define ImgUrl4 @"http://pic1.win4000.com/wallpaper/2020-03-31/5e830ed47bb5e.jpg"

#define ImgUrl5 @"http://dingyue.ws.126.net/yxsdZvQx9KfXRt8hBEwJW0zjWp6gj7aFBaLUnEEXn24Td1586935537274.jpeg"
#define ImgUrl6 @"http://n.sinaimg.cn/sinakd10111/680/w1920h1160/20200329/2fc2-irpunah0350446.jpg"


// 2D绘图  Quartz2D
// 合并图片 -- 水印

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIImageView *imgView;

@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;

@property (nonatomic, strong) UIButton * button1;

@property (nonatomic, strong) UIButton * button2;

@property (nonatomic, strong) UIButton * button3;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    
    CGFloat viewW = self.view.bounds.size.width;
    CGFloat viewH = self.view.bounds.size.height;
    CGFloat marginX = 20;
    CGFloat marginY = 100;
    
    CGFloat buttonW = 100;
    CGFloat buttonH = 30;
    
    [self.view addSubview:self.imgView];
    self.imgView.frame = CGRectMake(marginX, marginY, viewW-marginX*2, viewH-marginY*2);
    
    [self.view addSubview:self.button1];
    self.button1.frame = CGRectMake(marginX, viewH - buttonH*2, buttonW, buttonH);
    
    [self.view addSubview:self.button2];
    self.button2.frame = CGRectMake(marginX + buttonW + marginX, viewH - buttonH*2, buttonW, buttonH);
    
    [self.view addSubview:self.button3];
    self.button3.frame = CGRectMake(marginX + (buttonW + marginX)*2, viewH - buttonH*2, buttonW, buttonH);
}


#pragma mark- function

/// 异步下载两种图片，分别合并之后再回到主线程刷新UI
- (void)mergedImages1 {
    
    // 异步下载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 1.下载第1张
        UIImage *image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ImgUrl1]]];
        
        // 2.下载第2张
        UIImage *image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ImgUrl2]]];
        
        // 3.合并图片
        // 开启一个位图上下文
        UIGraphicsBeginImageContextWithOptions(image1.size, NO, 0.0);
        
        // 绘制第1张图片
        CGFloat image1W = image1.size.width;
        CGFloat image1H = image1.size.height;
        [image1 drawInRect:CGRectMake(0, 0, image1W, image1H)];
        
        // 绘制第2张图片
        CGFloat image2W = image2.size.width;
        CGFloat image2H = image2.size.height * 0.5;
        CGFloat image2Y = image1H * 0.5;
        [image2 drawInRect:CGRectMake(0, image2Y, image2W, image2H)];
        
        // 得到上下文中的图片
        UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // 结束上下文
        UIGraphicsEndImageContext();
        
        // 4.回到主线程显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imgView.image = fullImage;
        });
    });
}


/// 分别开启两条线程下载图片，然后再判断图片是否下载成功，最后合并完图片之后回到住线程刷新UI
- (void)mergedImages2 {
    
    // 异步下载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 1.下载第1张
        UIImage *image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ImgUrl3]]];
        self.image1 = image1;
        
        [self bindImages];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 2.下载第2张
        UIImage *image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ImgUrl4]]];
        self.image2 = image2;
        
        [self bindImages];
    });
}

- (void)bindImages {
    
    if (self.image1 == nil || self.image2 == nil) return;
    
    // 3.合并图片
    // 开启一个位图上下文
    UIGraphicsBeginImageContextWithOptions(self.image1.size, NO, 0.0);
    
    // 绘制第1张图片
    CGFloat image1W = self.image1.size.width;
    CGFloat image1H = self.image1.size.height;
    [self.image1 drawInRect:CGRectMake(0, 0, image1W, image1H)];
    
    // 绘制第2张图片
    CGFloat image2W = self.image2.size.width;
    CGFloat image2H = self.image2.size.height * 0.5;
    CGFloat image2Y = image1H * 0.5;
    [self.image2 drawInRect:CGRectMake(0, image2Y, image2W, image2H)];
    
    // 得到上下文中的图片
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束上下文
    UIGraphicsEndImageContext();
    
    // 4.回到主线程显示图片
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imgView.image = fullImage;
    });
}

/// 利用队列组方式，轻松实现
- (void)queueGroupImplementation {
    
    // 1.队列组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 2.下载图片1
    __block UIImage *image1 = nil;
    dispatch_group_async(group, queue, ^{
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ImgUrl5]]];
        image1 = image;
    });
    
    // 3.下载图片2
    __block UIImage *image2 = nil;
    dispatch_group_async(group, queue, ^{
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ImgUrl6]]];
        image2 = image;
    });
    
    // 4.合并图片 (保证执行完组里面的所有任务之后，再执行notify函数里面的block)
    dispatch_group_notify(group, queue, ^{
        
        // 开启一个位图上下文
        UIGraphicsBeginImageContextWithOptions(image1.size, NO, 0.0);
        
        // 绘制第1张图片
        CGFloat image1W = image1.size.width;
        CGFloat image1H = image1.size.height;
        [image1 drawInRect:CGRectMake(0, 0, image1W, image1H)];
        
        // 绘制第2张图片
        CGFloat image2W = image2.size.width;
        CGFloat image2H = image2.size.height * 0.5;
        CGFloat image2Y = image1H * 0.5;
        [image2 drawInRect:CGRectMake(0, image2Y, image2W, image2H)];
        
        // 得到上下文中的图片
        UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // 结束上下文
        UIGraphicsEndImageContext();
        
        // 5.回到主线程显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imgView.image = fullImage;
        });
    });
}

- (void)button1Action {
    
    [self mergedImages1]; // 1、异步下载两种图片，分别合并之后再回到主线程刷新UI
}

- (void)button2Action {
    
    [self mergedImages2]; // 2、分别开启两条线程下载图片，然后再判断图片是否下载成功，最后合并完图片之后回到住线程刷新UI
}

- (void)button3Action {
    
    [self queueGroupImplementation]; // 3、利用队列组方式，轻松实现
}

#pragma mark- lazying

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
    }
    return _imgView;
}

- (UIButton *)button1 {
    if (!_button1) {
        _button1 = [[UIButton alloc] init];
        _button1.backgroundColor = [UIColor blueColor];
        [_button1 setTitle:@"异步下载1" forState:UIControlStateNormal];
        _button1.layer.cornerRadius = 15;
        _button1.titleLabel.font = [UIFont systemFontOfSize:13];
        [_button1 addTarget:self action:@selector(button1Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button1;
}

- (UIButton *)button2 {
    if (!_button2) {
        _button2 = [[UIButton alloc] init];
        _button2.backgroundColor = [UIColor blueColor];
        [_button2 setTitle:@"异步下载2" forState:UIControlStateNormal];
        _button2.layer.cornerRadius = 15;
        _button2.titleLabel.font = [UIFont systemFontOfSize:13];
        [_button2 addTarget:self action:@selector(button2Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button2;
}

- (UIButton *)button3 {
    if (!_button3) {
        _button3 = [[UIButton alloc] init];
        _button3.backgroundColor = [UIColor redColor];
        [_button3 setTitle:@"队列组下载" forState:UIControlStateNormal];
        _button3.layer.cornerRadius = 15;
        _button3.titleLabel.font = [UIFont systemFontOfSize:13];
        [_button3 addTarget:self action:@selector(button3Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button3;
}


@end
