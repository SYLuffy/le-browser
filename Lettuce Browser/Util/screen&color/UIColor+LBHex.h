//
//  UIColor+JJCHex.h
//  JJCBase
//
//  Created by RyanYuan on 2021/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (LBHex)

/**
 *  十六进制颜色转换
 *
 *  @param hex 如：0xffb12524
 */
+ (UIColor *)LB_colorWithHex:(uint)hex;

/**
 *  十六进制颜色转换
 *
 *  @param hex 如：0xffb125
 *  @param alpha 入：0.3
 */
+ (UIColor *)LB_colorWithHex:(uint)hex andAlpha:(float)alpha;

@end

NS_ASSUME_NONNULL_END
