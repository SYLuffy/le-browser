//
//  LBADNativeManager.h
//  Lettuce Browser
//
//  Created by shen on 2024/5/16.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN
/// 原生广告 管理类
@interface LBADNativeManager : NSObject

@property (nonatomic, strong) LBGoogleADModel * homeNativeModel;
@property (nonatomic, strong) LBGoogleADModel * resultNativeModel;

+ (instancetype)shareInstance;

- (void)load:(LBADPosition)adPosition;

- (void)dismiss:(LBADPosition)adPosition;

/// tabkey 主要是用于区分 web标签管理器创建的 搜索页
- (void)showNativeAd:(LBADPosition)adPosition showLocation:(LBADShowLocation)showLocation searchTabKey:( NSDate * _Nullable)tabKey showNativeBlock:(void(^)(GADNativeAd * _Nullable nativeAD))showNativeBlock;

@end

NS_ASSUME_NONNULL_END
