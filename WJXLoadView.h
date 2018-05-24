//
//  扇形菊花
//  MumUnion
//
//  Created by wangjixiao on 16/7/12.
//  Copyright © 2016年 octech. All rights reserved.

#import <UIKit/UIKit.h>


@interface WJXLoadView : UIView

/**
 *  构造方法
 */
+ (WJXLoadView *)showViewInView:(UIView *)view;

/**
 *  进度条进度
 *
 *  @param values 0 - 100 大于或等于 100 自动消失
 */
- (void)setLoadValues:(CGFloat)values;


/**
 *  隐藏
 */
- (void)viewHidden:(BOOL)hidden;


@end
