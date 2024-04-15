//
//  LBScreenAdapter.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import <Foundation/Foundation.h>

///屏幕尺寸
#define kLBIsIphoneX [LBScreenAdapter isIphoneNotchScreen]

#define kLBScreenWidth [UIScreen mainScreen].bounds.size.width
#define KLBScreenHeight [UIScreen mainScreen].bounds.size.height
#define kLBDeviceWidth MIN(kLBScreenWidth, KLBScreenHeight)
#define kLBDeviceHeight MAX(kLBScreenWidth, KLBScreenHeight)

///以IphoneX尺寸基准
#define kLBRefereWidth 375.f
#define kLBReferHeight 812.f

///非iPhoneX尺寸
#define kLBPlusRefereWidth 360.f
#define kLBPlusRefereHeight 640.f

#define LBAdapterWidth(floatV) [LBScreenAdapter adapterWidthWithValue:floatV]
#define LBAdapterHeight(floatV) [LBScreenAdapter adapterHeightWithValue:floatV]

NS_ASSUME_NONNULL_BEGIN

@interface LBScreenAdapter : NSObject

///判断是否是留海屏
+ (BOOL)isIphoneNotchScreen;

///以屏幕宽（高）度为固定比例关系，计算不同屏幕下的值
+ (CGFloat)adapterWidthWithValue:(CGFloat)floatV;
+ (CGFloat)adapterHeightWithValue:(CGFloat)floatV;

@end

NS_ASSUME_NONNULL_END
