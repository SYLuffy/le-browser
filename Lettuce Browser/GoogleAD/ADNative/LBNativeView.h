//
//  LBNativeView.h
//  Lettuce Browser
//
//  Created by shen on 2024/5/16.
//

#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBNativeView : GADNativeAdView

- (void)configGADNativeAd:(GADNativeAd * _Nullable )nativeAdModel;

@end

NS_ASSUME_NONNULL_END