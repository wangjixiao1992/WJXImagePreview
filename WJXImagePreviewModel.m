//
//  WJXImagePreviewModel.m
//  Magic
//
//  Created by wangjixiao on 2016/12/22.
//  Copyright © 2016年 王. All rights reserved.
//

#import "WJXImagePreviewModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIButton+WebCache.h"

@implementation WJXImagePreviewModel


/**
 *  判断图片是否已被缓存
 */
- (void)imageIsCacheWithUrl:(NSString *)url
                 completion:(void (^)(BOOL isInCache))completion
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *imageUrl = [NSURL URLWithString:url];
    [manager cachedImageExistsForURL:imageUrl completion:^(BOOL isInCache) {
        completion(isInCache);
    }];
}

/**
 *  判断图片是否本地
 */
- (BOOL)imageIsLocation
{
    if (self.url.length > 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
