//
//  WJXImagePreviewModel.h
//  Magic
//
//  Created by wangjixiao on 2016/12/22.
//  Copyright © 2016年 王. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WJXImageCacheType) {
    WJXImageCacheTypeNoCache = 0,   //  没缓存
    WJXImageCacheTypeCacheing,      // 缓存中
    WJXImageCacheTypeCached         // 已缓存
};

@interface WJXImagePreviewModel : NSObject

@property (nonatomic, copy)   NSString *url;               //图片地址
@property (nonatomic, strong) UIImageView *imageView;      //图片原始图
@property (nonatomic, assign) CGRect parentRect;           //图片原始位置
@property (nonatomic, assign) WJXImageCacheType cacheType;  //是否缓存
@property (nonatomic, assign) BOOL isExist;                //是否滑动

/**
 *  判断图片是否本地
 */
- (BOOL)imageIsLocation;


/**
 *  判断图片是否已被缓存
 */
/**
 *  判断图片是否已被缓存
 */
- (void)imageIsCacheWithUrl:(NSString *)url
                 completion:(void (^)(BOOL isInCache))completion;



@end
