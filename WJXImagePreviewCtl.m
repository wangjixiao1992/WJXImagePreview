//
//  图片预览
//  Magic
//
//  Created by wangjixiao on 2016/12/19.
//  Copyright © 2016年 王. All rights reserved.
//

#import "WJXImagePreviewCtl.h"
#import "WJXImagePreviewModel.h"
#import "WJXLoadView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIButton+WebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kAnimationTime 0.3

#define  kscreenWidth   [UIScreen mainScreen].bounds.size.width //屏幕宽度
#define  kscreenHeight  [UIScreen mainScreen].bounds.size.height //屏幕长度
#define  kscProportion  (kscreenHeight / kscreenWidth >= 2436.0 / 1125.0) ? 1 : 0
#define  knavHeight     ((kscProportion == 1) ? 88 : 64)   //屏幕宽度
#define  ktabBarHeight  ((kscProportion == 1) ? 83 : 49)   //屏幕宽度

typedef NS_ENUM (NSInteger, WJXImagePreviewCtlAnimationStyle) {
    WJXImagePreviewCtlAnimationStylePresenting,
    WJXImagePreviewCtlAnimationStyleDismissing
};

@interface WJXImagePreviewCtl ()<UIScrollViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, copy)  NSString *selectUrl;
@property (nonatomic, strong)UIImageView *selectImageView;
@property (nonatomic, copy)  NSArray *urlArray;
@property (nonatomic, copy)  NSArray *imageViewArray;

@property (nonatomic, strong) UIButton *totalButton;

@property (nonatomic, assign) NSInteger photoIndex;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *scrollViewArray;

@property (nonatomic, assign) BOOL lastStatusBarHidden;
@property (nonatomic, strong) UIViewController *controller;


@end

#pragma mark - 转场
@interface WJXImagePreviewCtlAnimationController : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) WJXImagePreviewCtlAnimationStyle animationStyle;
@end


@implementation WJXImagePreviewCtlAnimationController
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3f;
    
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    if (self.animationStyle == WJXImagePreviewCtlAnimationStylePresenting) {
        WJXImagePreviewCtl *toVC = (WJXImagePreviewCtl *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        [containerView addSubview:toVC.view];
        [transitionContext completeTransition:YES];
    } else if (self.animationStyle == WJXImagePreviewCtlAnimationStyleDismissing) {
        WJXImagePreviewCtl *fromVC = (WJXImagePreviewCtl *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        fromVC.view.alpha = 0;
        [transitionContext completeTransition:YES];
    }
}
@end



@implementation WJXImagePreviewCtl

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    WJXImagePreviewCtlAnimationController *animationController = [[WJXImagePreviewCtlAnimationController alloc] init];
    animationController.animationStyle = WJXImagePreviewCtlAnimationStylePresenting;
    
    return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    WJXImagePreviewCtlAnimationController *animationController = [[WJXImagePreviewCtlAnimationController alloc] init];
    animationController.animationStyle = WJXImagePreviewCtlAnimationStyleDismissing;
    
    return animationController;
}

#pragma mark - init

/**
 预览本地图片
 
 @param imageView 选中的图片试图
 @param imageViewArray 图片试图数组
 */
- (instancetype)initWithimageView:(UIImageView *)imageView
                   imageViewArray:(NSArray *)imageViewArray
                       controller:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        self.selectImageView = imageView;
        self.imageViewArray = imageViewArray;
        self.controller = controller;
        self.lastStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        self.modalPresentationStyle = UIModalPresentationCustom; // 自定义
        self.transitioningDelegate = self;
    }
    return self;
}

/**
 预览网络图片
 
 @param url              选中图片地址
 @param urlArray         图片地址数组
 @param imageViewArray   图片试图数组
 */
- (instancetype)initWithUrl:(NSString *)url
                   urlArray:(NSArray *)urlArray
             imageViewArray:(NSArray *)imageViewArray
                 controller:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        self.selectUrl = url;
        self.urlArray = urlArray;
        self.imageViewArray = imageViewArray;
        self.controller = controller;
        self.lastStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        self.modalPresentationStyle = UIModalPresentationCustom; // 自定义
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.controller setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.controller setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    
    if (self.selectImageView) {
        self.photoIndex = 0;
        for (NSUInteger i = 0; i < self.imageViewArray.count; i++) {
            WJXImagePreviewModel *model = [[WJXImagePreviewModel alloc] init];
            model.imageView = [self.imageViewArray objectAtIndex:i];
            model.parentRect = [model.imageView convertRect:model.imageView.bounds
                                                     toView:self.view.window];
            [self.dataSourceArray addObject:model];
            if (self.selectImageView == model.imageView) {
                self.photoIndex = i;
            }
        }
    } else {
        self.photoIndex = 0;
        for (NSUInteger i = 0; i < self.urlArray.count; i++) {
            WJXImagePreviewModel *model = [[WJXImagePreviewModel alloc] init];
            model.url = [self.urlArray objectAtIndex:i];
            if (self.imageViewArray.count > 0 && self.imageViewArray.count - 1 >= i) {
                model.imageView = [self.imageViewArray objectAtIndex:i];
                model.parentRect = [model.imageView convertRect:model.imageView.bounds
                                                         toView:self.view.window];
            }
            [self.dataSourceArray addObject:model];
            if ([self.selectUrl isEqualToString:model.url]) {
                self.photoIndex = i;
            }
        }
    }
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadViewWithNumber:self.photoIndex];
}

#pragma mark - 构建UI
- (void)setupUI
{
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.totalButton];
}

/**
 *  加载图片
 *
 *  @param number     标志位
 */
- (void)setViewWithNumber:(NSInteger)number
{
    WJXImagePreviewModel *model = [self.dataSourceArray objectAtIndex:number];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(kscreenWidth * number, 0, kscreenWidth, kscreenHeight - ktabBarHeight);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor grayColor];
    
    if ([model imageIsLocation]) {
        if (model.imageView.image) {
            imageView.image = model.imageView.image;
        }
        if (self.photoIndex == number) {
            imageView.frame = CGRectMake(model.parentRect.origin.x,
                                         model.parentRect.origin.y,
                                         model.parentRect.size.width,
                                         model.parentRect.size.height);
        } else {
            imageView.frame = CGRectMake((kscreenWidth - model.parentRect.size.width) / 2,
                                         (kscreenHeight - ktabBarHeight - model.parentRect.size.height) / 2,
                                         model.parentRect.size.width,
                                         model.parentRect.size.height);
            [self imageSizeWithImage:model.imageView.image
                           imageView:imageView
                             animate:NO];
        }
    } else {
        [model imageIsCacheWithUrl:model.url
                        completion:^(BOOL isInCache) {
                            if (model.imageView.image) {
                                imageView.image = model.imageView.image;
                            }
                            if (model.parentRect.size.width > 0 && model.parentRect.size.height > 0) {
                                //有位置
                                if (self.photoIndex == number) {
                                    imageView.frame = CGRectMake(model.parentRect.origin.x,
                                                                 model.parentRect.origin.y,
                                                                 model.parentRect.size.width,
                                                                 model.parentRect.size.height);
                                } else {
                                    imageView.frame = CGRectMake((kscreenWidth - model.parentRect.size.width) / 2,
                                                                 (kscreenHeight - ktabBarHeight - model.parentRect.size.height) / 2,
                                                                 model.parentRect.size.width,
                                                                 model.parentRect.size.height);
                                    [self imageSizeWithImage:model.imageView.image
                                                   imageView:imageView
                                                     animate:NO];
                                }
                            } else {
                                //没位置
                                imageView.frame = CGRectMake((kscreenWidth - model.parentRect.size.width) / 2,
                                                             (kscreenHeight - ktabBarHeight - model.parentRect.size.height) / 2,
                                                             model.parentRect.size.width,
                                                             model.parentRect.size.height);
                            }
                        }];
    }
    [scrollView addSubview:imageView];
    
    // 双击放大
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                                action:@selector(doubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [scrollView addGestureRecognizer:doubleTapGestureRecognizer];
    
    [self.scrollView addSubview:scrollView];
    [self.scrollViewArray addObject:scrollView];
}

/**
 *  加载指定的试图
 *
 *  @param num 位置
 */
- (void)loadViewWithNumber:(NSInteger)num
{
    WJXImagePreviewModel *model = [self.dataSourceArray objectAtIndex:num];
    UIScrollView *scrollView = [self.scrollViewArray objectAtIndex:num];
    UIImageView *imageView = [[scrollView subviews] firstObject];
    __weak typeof(self) weakSelf = self;
    if (!model.isExist) {
        if ([model imageIsLocation]) {
            if (num == self.photoIndex) {
                [self zoomWithScrollView:scrollView];
                [self imageSizeWithImage:model.imageView.image
                               imageView:imageView
                                 animate:YES];
                imageView.image = model.imageView.image;
            }
            model.isExist = YES;
        } else {
            [model imageIsCacheWithUrl:model.url
                            completion:^(BOOL isInCache) {
                                if (isInCache) {
                                    [imageView sd_setImageWithURL:[NSURL URLWithString:model.url]
                                                 placeholderImage:imageView.image
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                            if (model.parentRect.size.width > 0 && model.parentRect.size.height > 0) {
                                                                //有位置
                                                                if (num == self.photoIndex) {
                                                                    [weakSelf zoomWithScrollView:scrollView];
                                                                    [weakSelf imageSizeWithImage:image
                                                                                       imageView:imageView
                                                                                         animate:YES];
                                                                }
                                                            } else {
                                                                //没位置
                                                                [weakSelf zoomWithScrollView:scrollView];
                                                                [weakSelf imageSizeWithImage:image
                                                                                   imageView:imageView
                                                                                     animate:YES];
                                                     
                                                            }
                                                            model.cacheType = WJXImageCacheTypeCached;
                                                            model.isExist = YES;
                                                        }];
                                } else {
                                    if (model.cacheType == WJXImageCacheTypeNoCache) {
                                        model.cacheType = WJXImageCacheTypeCacheing;
                                        [weakSelf imageSizeWithImage:model.imageView.image
                                                           imageView:imageView
                                                             animate:YES];
                                        WJXLoadView *hudView = [WJXLoadView showViewInView:imageView];
                                        hudView.tag = 500;
                                        [imageView sd_setImageWithURL:[NSURL URLWithString:model.url]
                                                     placeholderImage:[UIImage imageNamed:@"123"]
                                                              options:SDWebImageProgressiveDownload
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                                 //进度条
                                                                 CGFloat load = (CGFloat)receivedSize / (CGFloat)expectedSize;
                                                                 // 回到主队列刷新UI
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     // 设置进度条的百分比
                                                                     [(WJXLoadView *)[imageView viewWithTag:500] setLoadValues:load * 100];
                                                                 });
                                                             } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                                 [weakSelf zoomWithScrollView:scrollView];
                                                                 if (error) {
                                                                     UIImage *newImage = nil;
                                                                     imageView.image = newImage;
                                                                     [weakSelf imageSizeWithImage:newImage
                                                                                        imageView:imageView
                                                                                          animate:NO];
                                                                     model.cacheType = WJXImageCacheTypeNoCache;
                                                                 } else {
                                                                     if (model.parentRect.size.width > 0 && model.parentRect.size.height > 0) {
                                                                         if (num == self.photoIndex) {
                                                                             [weakSelf imageSizeWithImage:image
                                                                                                imageView:imageView
                                                                                                  animate:YES];
                                                                             model.cacheType = WJXImageCacheTypeCached;
                                                                         }
                                                                     } else {
                                                                         [weakSelf imageSizeWithImage:image
                                                                                            imageView:imageView
                                                                                              animate:YES];
                                                                         model.cacheType = WJXImageCacheTypeCached;
                                                                     }
                                                                 }
                                                                 model.isExist = YES;
                                                             }];
                                    } else {
                                        //缓存中 不做处理
                                    }
                                }
                            }];
        }
    }
}

/**
 *  图片适应手机 适用于图片
 *
 */
- (void)imageSizeWithImage:(UIImage *)image
                 imageView:(UIImageView *)imageView
                   animate:(BOOL)animate
{
    if (image.size.height > kscreenHeight - ktabBarHeight || image.size.width > kscreenWidth) {
        if ((image.size.height / image.size.width) > (kscreenHeight - ktabBarHeight / kscreenWidth)) {
            CGFloat width = kscreenHeight - ktabBarHeight * (image.size.width / image.size.height);
            if (animate) {
                [UIView animateWithDuration:kAnimationTime animations:^{
                    imageView.frame = CGRectMake((kscreenWidth - width) / 2, 0, width , kscreenHeight - ktabBarHeight);
                }];
            } else {
                imageView.frame = CGRectMake((kscreenWidth - width) / 2, 0, width , kscreenHeight - ktabBarHeight);
            }
            
        } else {
            CGFloat height = kscreenWidth * (image.size.height / image.size.width);
            if (animate) {
                [UIView animateWithDuration:kAnimationTime animations:^{
                    imageView.frame = CGRectMake(0, (kscreenHeight - ktabBarHeight - height ) / 2, kscreenWidth, height);
                }];
            } else {
                imageView.frame = CGRectMake(0, (kscreenHeight - ktabBarHeight - height ) / 2, kscreenWidth, height);
            }
        }
    } else {
        if (animate) {
            [UIView animateWithDuration:kAnimationTime animations:^{
                imageView.frame = CGRectMake((kscreenWidth - image.size.width ) / 2, (kscreenHeight - ktabBarHeight - image.size.height) / 2, image.size.width, image.size.height );
            }];
        } else {
            imageView.frame = CGRectMake((kscreenWidth - image.size.width ) / 2, (kscreenHeight - ktabBarHeight - image.size.height) / 2, image.size.width, image.size.height );
        }
    }
}

/**
 关闭
 */
- (void)cancelButtonClick
{
    [self.controller setNeedsStatusBarAppearanceUpdate];
    // 得到底部滚动试图
    UIScrollView *scrollView = [self.scrollViewArray objectAtIndex:self.photoIndex];
    UIImageView *imageView = (UIImageView *)[[scrollView subviews] firstObject];
    if ([imageView viewWithTag:500]) {
        [(WJXLoadView *)[imageView viewWithTag:500] viewHidden:YES];
    }
    
    WJXImagePreviewModel *model = [self.dataSourceArray objectAtIndex:self.photoIndex];
    //是否超过屏幕
    BOOL isExceedScreem = NO;
    if (model.parentRect.origin.x + model.parentRect.size.width < 0 || model.parentRect.origin.x > kscreenWidth || model.parentRect.origin.y > kscreenHeight - ktabBarHeight || model.parentRect.origin.y + model.parentRect.size.height < 0) {
        isExceedScreem = YES ;
    }
    //超过父试图的位置或者 超过屏幕位置位置 不在回到原来位置
    if (isExceedScreem) {
        self.view.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:kAnimationTime
                         animations:^{
                             imageView.alpha = 0;
                         }];
    } else {
        if (model.parentRect.size.width > 0 && model.parentRect.size.height > 0) {
            self.view.backgroundColor = [UIColor clearColor];
            [UIView animateWithDuration:kAnimationTime
                             animations:^{
                                 scrollView.contentOffset = CGPointMake(0, 0);
                                 imageView.frame = CGRectMake(model.parentRect.origin.x, model.parentRect.origin.y, model.parentRect.size.width, model.parentRect.size.height);
                             }];
        } else {
            scrollView.contentOffset = CGPointMake(0, 0);
        }
    }
    //先做动画 然后关闭视图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO
                                 completion:nil];
    });
}


/**
 下载
 */
- (void)downLoadButtonClick
{
    // 得到底部滚动试图
    UIScrollView *scrollView = [self.scrollViewArray objectAtIndex:self.photoIndex];
    UIImageView *imageView = (UIImageView *)[[scrollView subviews] firstObject];
    UIImage *image = imageView.image;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //创建相簿成功
    [library writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(image) metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
       
        } else {
            
        }
    }];
}

/**
 *  双击手势
 *
 */
- (void)doubleTap:(UIGestureRecognizer*)sender
{
    // 得到底部滚动试图
    UIScrollView *scrollView = (UIScrollView *)sender.view;
    UIImageView *imageView = (UIImageView *)[[scrollView subviews] firstObject];
    WJXImagePreviewModel *model = [self.dataSourceArray objectAtIndex:self.photoIndex];
    
    // 获取imageView
    UIImage *image = model.imageView.image;
    CGFloat width;
    
    if (image.size.height > kscreenHeight - ktabBarHeight || image.size.width > kscreenWidth) {
        if ((image.size.height / image.size.width) > (kscreenHeight - ktabBarHeight / kscreenWidth)) {
            width = kscreenHeight - ktabBarHeight * (image.size.width / image.size.height);
        } else {
            width = kscreenWidth;
        }
    } else {
        width = image.size.width;
    }
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    CGFloat scrollViewHeight = scrollView.frame.size.height;
    CGFloat imageWidth = imageView.frame.size.width;
    CGFloat imageHeight = imageView.frame.size.height;
    CGFloat x = (scrollViewWidth - imageWidth) / 2; // 图片左边距离scrollView的x
    CGFloat y = (scrollViewHeight - imageHeight) / 2; // 图片上边距离scrollView的y
    CGPoint touchPoint = [sender locationInView:scrollView];
    
    // 将scrollView的点击坐标转换为imageView上的坐标
    CGFloat touchX = MAX(touchPoint.x - x, 0); // 限定左边不可超出图片
    touchX = MIN(scrollViewWidth - x * 2, touchX); // 限定右边不可超过图片
    
    CGFloat touchY = MAX(touchPoint.y - y, 0); // 限定上边不可超出图片
    touchY = MIN(scrollViewHeight - y * 2, touchY); // 限定下边不可超出图片
    
    CGFloat newScale = 2;
    CGFloat xsize = imageWidth / newScale;
    CGFloat ysize = imageHeight / newScale;
    [scrollView zoomToRect:CGRectMake(touchX - xsize / 2, touchY - ysize / 2, xsize, ysize) animated:YES];
}

/**
 *  最大缩放比手势
 *
 */
- (void)zoomWithScrollView:(UIScrollView *)scrollView
{
    // 获取imageView
    UIImageView *imageView = (UIImageView *)[[scrollView subviews] firstObject];
    
    // 最大缩放比
    CGFloat maxProportion = 0.0;
    
    if (imageView.frame.size.width / imageView.frame.size.height > 4) { // 判断图片比例 图片过宽
        
        CGFloat flo;
        if (imageView.image.size.width > kscreenWidth) {
            flo = imageView.image.size.width / kscreenWidth;
        } else {
            flo = 1;
        }
        maxProportion = flo * 2;
    } else if (imageView.frame.size.height / imageView.frame.size.width > 4){ // 判断图片比例 图片过长
        CGFloat flo;
        if (imageView.image.size.height > kscreenHeight - ktabBarHeight) {
            flo = imageView.image.size.height / kscreenHeight - ktabBarHeight;
        } else {
            flo = 1;
        }
        maxProportion = flo * 2;
    } else { // 常规图片
        CGFloat flo;
        if (imageView.image.size.width > kscreenWidth || imageView.image.size.height > kscreenHeight - ktabBarHeight) {
            if ((imageView.image.size.height / imageView.image.size.width) > (kscreenHeight - ktabBarHeight / kscreenWidth)) {
                flo = imageView.image.size.height / kscreenHeight - ktabBarHeight;
            } else {
                flo = imageView.image.size.width / kscreenWidth;
            }
        } else {
            flo = 1;
        }
        maxProportion = 2 * flo;
    }
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = maxProportion;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 2000) {
        [self loadViewWithNumber:self.photoIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 2000) {
        
        CGFloat contentX = scrollView.contentOffset.x + kscreenWidth / 2;
        NSInteger page = (contentX / kscreenWidth);
        if (page > self.dataSourceArray.count) {
            page = self.dataSourceArray.count;
        }
        self.photoIndex = page;
        [self.totalButton setTitle:[NSString stringWithFormat:@"%ld/%ld", self.photoIndex + 1, self.dataSourceArray.count]
                          forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView.tag != 2000) {
        //获取imageView
        UIImageView *imageView = (UIImageView *)[[scrollView subviews] firstObject];
        
        CGFloat x = scrollView.frame.size.width / 2;
        CGFloat y = scrollView.frame.size.height / 2;
        x = (scrollView.contentSize.width > scrollView.frame.size.width) ? scrollView.contentSize.width / 2 : x;
        y = (scrollView.contentSize.height > scrollView.frame.size.height) ? scrollView.contentSize.height / 2 : y;
        [imageView setCenter:CGPointMake(x, y)];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView.tag != 2000) {
        //获取imageView
        UIImageView *imageView = (UIImageView *)[[scrollView subviews] firstObject];
        return imageView;
    }
    return nil;
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kscreenWidth, kscreenHeight - ktabBarHeight)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.delegate = self;
        _scrollView.tag = 2000;
        _scrollView.pagingEnabled = YES;
        for (int i = 0; i < self.dataSourceArray.count; i++) {
            [self setViewWithNumber:i];
        }
        _scrollView.contentSize = CGSizeMake(kscreenWidth * self.dataSourceArray.count, kscreenHeight - ktabBarHeight);
        _scrollView.contentOffset = CGPointMake(kscreenWidth * self.photoIndex, 0);
    }
    return _scrollView;
}

- (UIButton *)totalButton
{
    if (!_totalButton) {
        _totalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _totalButton.frame = CGRectMake((kscreenWidth - 50) / 2, kscreenHeight - ktabBarHeight, 50, 50);
        [_totalButton setTitle:[NSString stringWithFormat:@"%ld/%ld", self.photoIndex + 1, self.dataSourceArray.count]
                      forState:UIControlStateNormal];
    }
    return _totalButton;
}

- (NSMutableArray *)dataSourceArray
{
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataSourceArray;
}

- (NSMutableArray *)scrollViewArray
{
    if (!_scrollViewArray) {
        _scrollViewArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _scrollViewArray;
}



@end
