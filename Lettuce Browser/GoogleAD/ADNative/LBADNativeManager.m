//
//  LBADNativeManager.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/16.
//

#import "LBADNativeManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "Lettuce_Browser-Swift.h"

@interface LBADNativeManager () <GADAdLoaderDelegate,GADNativeAdLoaderDelegate,GADNativeAdDelegate>

/// 展示的时间
@property (nonatomic, strong) NSDate * loadedDate;
@property (nonatomic, strong) GADNativeAd * lastHomeNativeAd;
@property (nonatomic, strong) GADNativeAd * lastResultNativeAd;
@property (nonatomic, strong) GADNativeAd * homeNativeAd;
@property (nonatomic, strong) GADNativeAd * resultNativeAd;
@property (nonatomic, strong) GADAdLoader * homeLoader;
@property (nonatomic, strong) GADAdLoader * resultLoader;

@property (nonatomic, assign) BOOL isLoading;
///预加载
@property (nonatomic, assign) BOOL isHomePreLoad;
@property (nonatomic, assign) BOOL isResultPreLoad;
///当前使用的广告id索引
///waterfall，当前请求失败，自动切换下一个adid请求
@property (nonatomic, assign) NSInteger currentHomeIndex;
@property (nonatomic, assign) NSInteger currentResultIndex;

@property (nonatomic, copy) void (^homeNativeBlock)(GADNativeAd *nativeAd);
@property (nonatomic, copy) void (^resultNativeBlock)(GADNativeAd *nativeAd);

@property (nonatomic, strong) NSMutableDictionary * timeEventDicts;
@property (nonatomic, assign) LBADShowLocation currentADLocation;
@property (nonatomic, strong) NSDate * webTabKey;

@end

@implementation LBADNativeManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static LBADNativeManager *aManager = nil;
    dispatch_once(&onceToken, ^{
        aManager = [[LBADNativeManager alloc] init];
        aManager.currentHomeIndex = 0;
        aManager.currentResultIndex = 0;
    });
    return aManager;
}

- (void)load:(LBADPosition)adPosition{
    if ([[LBGoogleADUtil shareInstance] isADLimit]) {
        return;
    }
    if (adPosition == LBADPositionHomeNative && self.homeNativeModel && (!self.homeNativeAd || self.isHomePreLoad)) {
        NSLog(@"[AD] homeNative 开始加载");
        self.isHomePreLoad = NO;
        self.homeLoader = [[GADAdLoader alloc] initWithAdUnitID:self.homeNativeModel.value[self.currentHomeIndex].theAdID
                                             rootViewController:nil
                                                        adTypes:@[ GADAdLoaderAdTypeNative ]
                                                        options:@[]];
        self.homeLoader.delegate = self;
        [self.homeLoader loadRequest:[GADRequest request]];
    }else if (adPosition == LBADPositionResultNative && self.resultNativeModel && (!self.resultNativeAd || self.isResultPreLoad)) {
        NSLog(@"[AD] resultNative 开始加载");
        self.isResultPreLoad = NO;
        self.resultLoader = [[GADAdLoader alloc] initWithAdUnitID:self.resultNativeModel.value[self.currentResultIndex].theAdID
                                               rootViewController:nil
                                                          adTypes:@[ GADAdLoaderAdTypeNative ]
                                                          options:@[]];
        self.resultLoader.delegate = self;
        [self.resultLoader loadRequest:[GADRequest request]];
    }
}

- (void)showNativeAd:(LBADPosition)adPosition showLocation:(LBADShowLocation)showLocation searchTabKey:(NSDate *)tabKey showNativeBlock:(void(^)(GADNativeAd * _Nullable nativeAD))showNativeBlock {
    self.currentADLocation = showLocation;
    self.webTabKey = tabKey;
    if ([[LBGoogleADUtil shareInstance] isADLimit]) {
        if (showNativeBlock) {
            showNativeBlock(nil);
        }
        return;
    }
    GADNativeAd * currentNativeAd = [self getCurrentAdModel:adPosition];
    NSDate * currentImpressionDate = [self getImpressionDate];
    if (currentNativeAd) {
        if (currentImpressionDate && [NSDate date].timeIntervalSinceNow - currentImpressionDate.timeIntervalSinceNow < 12) {
            NSLog(@"[AD] 12s %@ 广告显示間隔",[[LBGoogleADUtil shareInstance] getPositionKeyWith:adPosition]);
            if (showNativeBlock) {
                showNativeBlock(nil);
            }
        }else {
            if (showNativeBlock) {
                showNativeBlock(currentNativeAd);
            }
        }
    }else {
        [self load:adPosition];
        [self setCurrentADBlock:adPosition showNativeBlock:showNativeBlock];
    }
}

/// water fall
- (void)incremCurrenIndex:(LBADPosition)position {
    if (position == LBADPositionHomeNative) {
        self.currentHomeIndex ++;
        if (self.currentHomeIndex >= self.homeNativeModel.value.count) {
            self.currentHomeIndex = 0;
            NSLog(@"[AD] homeNative 当前ad组内都已请求失败，等待下次触发");
        }else {
            NSLog(@"[AD] homeNative 当前序号 %ld 加载失败，waterfall自动切到序号 %ld adid加载 ❌❌",self.currentHomeIndex,self.currentHomeIndex + 1);
            [self load:LBADPositionHomeNative];
        }
    }else {
        self.currentResultIndex ++;
        if (self.currentResultIndex >= self.resultNativeModel.value.count) {
            self.currentResultIndex = 0;
            NSLog(@"[AD] resultNative 当前ad组内都已请求失败，等待下次触发");
        }else {
            NSLog(@"[AD] resultNative 当前序号 %ld 加载失败，waterfall自动切到序号 %ld adid加载 ❌❌",self.currentResultIndex,self.currentResultIndex + 1);
            [self load:LBADPositionResultNative];
        }
    }
}

- (void)dismiss:(LBADPosition)adPosition {
    LBGoogleADModel * currentGoogleModel = [self getCurrentGooglaADModel:adPosition];
    currentGoogleModel.isDisPlay = NO;
}

- (void)setCurrentADBlock:(LBADPosition)adPosition showNativeBlock:(void(^)(GADNativeAd * nativeAD))showNativeBlock {
    if (adPosition == LBADPositionHomeNative) {
        self.homeNativeBlock = showNativeBlock;
    }else {
        self.resultNativeBlock = showNativeBlock;
    }
}

- (LBGoogleADModel *)getCurrentGooglaADModel:(LBADPosition)adPosition {
    if (adPosition == LBADPositionHomeNative) {
        return self.homeNativeModel;
    }
    return self.resultNativeModel;
}

- (GADNativeAd *)getCurrentAdModel:(LBADPosition)adPosition {
    if (adPosition == LBADPositionHomeNative) {
        return self.homeNativeAd;
    }
    return self.resultNativeAd;
}

- (NSDate *)getImpressionDate {
    NSDate * date = nil;
    if (self.webTabKey) {
        date = [self.timeEventDicts objectForKey:self.webTabKey];
    }else {
        date = [self.timeEventDicts objectForKey:@(self.currentADLocation)];
    }
    return date;
}

#pragma mark - GADAdLoaderDelegate & GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    self.isLoading = NO;
    self.loadedDate = [NSDate date];
    if (adLoader == self.homeLoader) {
        NSLog(@"[AD] homeNative 已加载完成 ✅✅");
        self.homeNativeAd = nativeAd;
        self.homeNativeAd.delegate = self;
        if (!self.isHomePreLoad) {
            self.lastHomeNativeAd = nil;
            self.lastHomeNativeAd = self.homeNativeAd;
            self.lastHomeNativeAd.paidEventHandler = ^(GADAdValue * _Nonnull value) {
                double price = [value.value doubleValue];
                NSString * currencyCode = value.currencyCode;
                [CacheUtil ocAddFBPriceWithPrice:price currency:currencyCode];
                double totalPrice = [CacheUtil ocneedUploadFBPrice];
                ///价值回传
                if (totalPrice > 0) {
                    [FBSDKAppEvents.shared logPurchase:totalPrice currency:currencyCode];
                }
            };
        }
        if (self.homeNativeBlock) {
            self.homeNativeBlock(nativeAd);
            self.homeNativeBlock = nil;
        }
    }else if (adLoader == self.resultLoader) {
        NSLog(@"[AD] resultNative 加载完成 ✅✅");
        self.resultNativeAd = nativeAd;
        self.resultNativeAd.delegate = self;
        if (!self.isResultPreLoad) {
            self.lastResultNativeAd = nil;
            self.lastResultNativeAd = self.resultNativeAd;
            self.lastResultNativeAd.paidEventHandler = ^(GADAdValue * _Nonnull value) {
                double price = [value.value doubleValue];
                NSString * currencyCode = value.currencyCode;
                [CacheUtil ocAddFBPriceWithPrice:price currency:currencyCode];
                double totalPrice = [CacheUtil ocneedUploadFBPrice];
                ///价值回传
                if (totalPrice > 0) {
                    [FBSDKAppEvents.shared logPurchase:totalPrice currency:currencyCode];
                }
            };
        }
        if (self.resultNativeBlock) {
            self.resultNativeBlock(nativeAd);
            self.resultNativeBlock = nil;
        }
    }
}

- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader {

}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    if (self.homeLoader == adLoader) {
        NSLog(@"[AD] Failed to load homeNative ad with error: %@", [error localizedDescription]);
        [self incremCurrenIndex:LBADPositionHomeNative];
    }else {
        NSLog(@"[AD] Failed to load resultNative ad with error: %@", [error localizedDescription]);
        NSLog(@"[AD] resultNative 加载失败，waterfall自动切到下一个adid");
        [self incremCurrenIndex:LBADPositionResultNative];
    }
   
}

#pragma mark - GADNativeAdDelegate

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
    [[LBGoogleADUtil shareInstance] recordADImpressNumber];
    if (self.homeNativeAd == nativeAd) {
        NSLog(@"[AD] homeNative 当前已显示，开始加载下一个备用");
        self.isHomePreLoad = YES;
        [self load:LBADPositionHomeNative];
    }else if (self.resultNativeAd == nativeAd) {
        NSLog(@"[AD] resultNative 当前已显示，开始加载下一个备用");
        self.isResultPreLoad = YES;
        [self load:LBADPositionResultNative];
    }
    if (self.webTabKey) {
        [self.timeEventDicts setObject:[NSDate date] forKey:self.webTabKey];
    }else {
        [self.timeEventDicts setObject:[NSDate date] forKey:@(self.currentADLocation)];
    }
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
  // The native ad was clicked on.
    [[LBGoogleADUtil shareInstance] recordADClickNumber];
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd {
  // The native ad will present a full screen view.
}

- (void)nativeAdWillDismissScreen:(GADNativeAd *)nativeAd {
  // The native ad will dismiss a full screen view.
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd {
  // The native ad did dismiss a full screen view.
}

- (void)nativeAdWillLeaveApplication:(GADNativeAd *)nativeAd {
  // The native ad will cause the app to become inactive and
  // open a new app.
}

#pragma mark - Getter

- (NSMutableDictionary *)timeEventDicts {
    if (!_timeEventDicts) {
        _timeEventDicts = [[NSMutableDictionary alloc] init];
    }
    return _timeEventDicts;
}

@end
