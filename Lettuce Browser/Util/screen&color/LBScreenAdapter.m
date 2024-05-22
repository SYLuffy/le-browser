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
        result = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom > 0?true:false;
    }
    return result;
}

+ (CGFloat)adapterWidthWithValue:(CGFloat)floatV {
    CGFloat width = kLBRefereWidth;
    return  roundf(floatV*kLBDeviceWidth/width);
}

+ (CGFloat)adapterHeightWithValue:(CGFloat)floatV {
    CGFloat height = kLBReferHeight;
    return  roundf(floatV*kLBDeviceHeight/height);
}

@end
