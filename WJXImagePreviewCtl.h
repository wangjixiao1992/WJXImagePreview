//
//  图片预览
//  Magic
//
//  Created by wangjixiao on 2016/12/19.
//  Copyright © 2016年 王. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJXImagePreviewCtl : UIViewController

/**
 预览网络图片
 
 @param url              选中图片地址
 @param urlArray         图片地址数组
 @param imageViewArray   图片试图数组(可选)
 */
- (instancetype)initWithUrl:(NSString *)url
                   urlArray:(NSArray *)urlArray
             imageViewArray:(NSArray *)imageViewArray
                 controller:(UIViewController *)controller;

/**
 预览本地图片
 
 @param imageView      选中的图片试图(必须)
 @param imageViewArray 图片试图数组(必须)
 */
- (instancetype)initWithimageView:(UIImageView *)imageView
                   imageViewArray:(NSArray *)imageViewArray
                       controller:(UIViewController *)controller;

@end
