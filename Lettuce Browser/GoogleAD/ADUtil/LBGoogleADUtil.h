//
//  LBGoogleADUtil.h
//  Lettuce Browser
//
//  Created by shen on 2024/5/20.
//

#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LBADPosition) {
    LBADPositionLoadingOpen,    ///开屏
    LBADPositionHomeNative,     ///浏览器主页、tab页、VPN主页（原生）广告位
    LBADPositionResultNative,   ///结果页
    LBADPositionConnect,        ///VPN插屏
    LBADPositionBack            ///清理动画、界面返回 插屏广告
};

/// 用于统计 或 刷新间隔处理
typedef NS_ENUM(NSUInteger, LBADShowLocation) {
    LBADShowLocationHomePage,
    LBADShowLocationTabPage,
    LBADShowLocationVpnHomePage,
    LBADShowLocationResultPage,
};

@interface LBGoogleADUtil : GADNativeAdView

+ (instancetype)shareInstance;

/// 枚举转换字符串
- (NSString *)getPositionKeyWith:(LBADPosition)position;

/// 广告点击一次，次数 + 1
- (void)recordADClickNumber;

/// 广告曝光一次，次数 + 1
- (void)recordADImpressNumber;

/// 原生广告点击区域
- (BOOL)installOnlyTouch;

/// 是否已到限制
- (BOOL)isADLimit;

@end

NS_ASSUME_NONNULL_END
