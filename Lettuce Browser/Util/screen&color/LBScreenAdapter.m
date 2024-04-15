//
//  LBScreenAdapter.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import "LBScreenAdapter.h"
#import "AppDelegate.h"

@implementation LBScreenAdapter

+ (BOOL)isIphoneNotchScreen {
    BOOL result = false;
    if (@available(iOS 11.0, *)) {
        result = [UIApplication sharedApplication].windows.lastObject.safeAreaInsets.bottom > 0?true:false;
    }
    return result;
}

+ (CGFloat)adapterWidthWithValue:(CGFloat)floatV {
    CGFloat width = kLBPlusRefereWidth;
    if (kLBIsIphoneX) {
        width = kLBRefereWidth;
    }
    return  roundf(floatV*kLBDeviceWidth/width);
}

+ (CGFloat)adapterHeightWithValue:(CGFloat)floatV {
    CGFloat width = kLBPlusRefereHeight;
    if (kLBIsIphoneX) {
        width = kLBReferHeight;
    }
    return  roundf(floatV*kLBReferHeight/width);
}

@end