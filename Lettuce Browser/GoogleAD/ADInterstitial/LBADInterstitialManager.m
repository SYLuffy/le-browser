//
//  LBADInterstitialManager.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/16.
//

#import "LBADInterstitialManager.h"
#import <GoogleMobileAds/GADInterstitialAd.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "Lettuce_Browser-Swift.h"

@interface LBADInterstitialManager () <GADFullScreenContentDelegate>

@property (nonatomic, strong) GADInterstitialAd * connectInterstitialAD;
@property (nonatomic, strong) GADInterstitialAd * backInterstitialAD;

@property (nonatomic, strong) GADInterstitialAd * lastConnectInterstitialAD;
@property (nonatomic, strong) GADInterstitialAd * lastBackInterstitialAD;

@property (nonatomic, assign) BOOL isShowPresent;
@property (nonatomic, assign) LBADPosition currentShowPosition;
///当前使用的广告id索引
///waterfall，当前请求失败，自动切换下一个adid请求
@property (nonatomic, assign) NSInteger connectCurrentIndex;
@property (nonatomic, assign) NSInteger backCurrentIndex;

@end

@implementation LBADInterstitialManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static LBADInterstitialManager *aManager = nil;
    dispatch_once(&onceToken, ^{
        aManager = [[LBADInterstitialManager alloc] init];
        aManager.backCurrentIndex = 0;
        aManager.connectCurrentIndex = 0;
        [[NSNotificationCenter defaultCenter] addObserver:aManager
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    });
    return aManager;
}

- (void)loadAd:(LBADPosition)adPosition {
    if ([[LBGoogleADUtil shareInstance] isADLimit]) {
        return;
    }
    GADRequest *request = [GADRequest request];
    if (adPosition == LBADPositionConnect && self.vpnConnectADModel) {
        NSLog(@"[AD] vpnConnect 开始加载");
        [GADInterstitialAd loadWithAdUnitID:self.vpnConnectADModel.value[self.connectCurrentIndex].theAdID
                                    request:request
                          completionHandler:^(GADInterstitialAd *ad, NSError *error) {
            if (error) {
                NSLog(@"[AD] Failed to load vpnConnect ad with error: %@", [error localizedDescription]);
                [self incremCurrenIndex:LBADPositionConnect];
                return;
            }
            self.connectCurrentIndex = 0;
            self.connectInterstitialAD = ad;
            self.connectInterstitialAD.fullScreenContentDelegate = self;
            NSLog(@"[AD] vpnConnect 加载完成 ✅✅");
        }];
    }else if (adPosition == LBADPositionBack && self.backADModel){
        NSLog(@"[AD] back 开始加载");
        [GADInterstitialAd loadWithAdUnitID:self.backADModel.value[self.backCurrentIndex].theAdID
                                    request:request
                          completionHandler:^(GADInterstitialAd *ad, NSError *error) {
            if (error) {
                NSLog(@"[AD] Failed to load back ad with error: %@", [error localizedDescription]);
                [self incremCurrenIndex:LBADPositionBack];
                return;
            }
            self.backCurrentIndex = 0;
            self.backInterstitialAD = ad;
            self.backInterstitialAD.fullScreenContentDelegate = self;
            NSLog(@"[AD] back 加载完成 ✅✅");
        }];
    }
    
}

/// water fall
- (void)incremCurrenIndex:(LBADPosition)position {
    if (position == LBADPositionConnect) {
        self.connectCurrentIndex ++;
        if (self.connectCurrentIndex >= self.vpnConnectADModel.value.count) {
            self.connectCurrentIndex = 0;
            NSLog(@"[AD] vpnConnect 当前ad组内都已请求失败，等待下次触发");
        }else {
            NSLog(@"[AD] vpnConnect 当前序号 %ld 加载失败，waterfall自动切到序号 %ld adid加载 ❌❌",self.connectCurrentIndex,self.connectCurrentIndex + 1);
            [self loadAd:LBADPositionConnect];
        }
    }else {
        self.backCurrentIndex ++;
        if (self.backCurrentIndex >= self.backADModel.value.count) {
            self.backCurrentIndex = 0;
            NSLog(@"[AD] back 当前ad组内都已请求失败，等待下次触发");
        }else {
            NSLog(@"[AD] back 当前序号 %ld 加载失败，waterfall自动切到序号 %ld adid加载 ❌❌",self.backCurrentIndex,self.backCurrentIndex + 1);
            [self loadAd:LBADPositionBack];
        }
    }
}

- (void)showAd:(LBADPosition)adPosition {
    if ([[LBGoogleADUtil shareInstance] isADLimit]) {
        if (self.ADDismissBlock) {
            self.ADDismissBlock();
        }
        return;
    }
    self.currentShowPosition = adPosition;
    GADInterstitialAd * currentAd = [self getCurrentAdModel:adPosition];
    if (currentAd) {
        [currentAd presentFromRootViewController:nil];
    }else {
        NSLog(@"[AD] 当前没有插屏广告，马上加载一个");
        [self loadAd:adPosition];
        if (self.ADDismissBlock) {
            self.ADDismissBlock();
        }
    }
}

- (GADInterstitialAd *)getCurrentAdModel:(LBADPosition)adPosition {
    if (adPosition == LBADPositionConnect) {
        return self.connectInterstitialAD;
    }
    return self.backInterstitialAD;
}

- (LBGoogleADModel *)getCurrentGooglaADModel:(LBADPosition)adPosition {
    if (adPosition == LBADPositionConnect) {
        return self.vpnConnectADModel;
    }
    return self.backADModel;
}

- (void)dismiss {
    if (self.isShowPresent) {
        UIApplication *app = [UIApplication sharedApplication];
        NSArray<UIWindow *> *windows = app.windows;
        NSUInteger keyWindowIndex = [windows indexOfObjectPassingTest:^BOOL(UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.isKeyWindow;
        }];
        if (keyWindowIndex != NSNotFound) {
            UIViewController *topController = windows[keyWindowIndex].rootViewController;
            if (topController.presentedViewController) {
                [topController.presentedViewController dismissViewControllerAnimated:YES completion:^{
                    [topController dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        }
        if (self.ADDismissBlock) {
            self.ADDismissBlock();
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)noti {
    /// 退到后台关掉插屏广告
    [self dismiss];
}

#pragma mark - GADFullScreenContentDelegate

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"[AD] did fail to present full screen content.");
    self.isShowPresent = NO;
    if (self.ADDismissBlock) {
        self.ADDismissBlock();
    }
}

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [[LBGoogleADUtil shareInstance] recordADImpressNumber];
    self.isShowPresent = YES;
    __weak typeof(self) weakSelf = self;
    if (self.currentShowPosition == LBADPositionConnect) {
        self.lastConnectInterstitialAD = nil;
        self.lastConnectInterstitialAD = self.connectInterstitialAD;
        ///价值回传
        self.lastConnectInterstitialAD.paidEventHandler = ^(GADAdValue * _Nonnull value) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            double price = [value.value doubleValue];
            NSString * currencyCode = value.currencyCode;
            [CacheUtil ocAddFBPriceWithPrice:price currency:currencyCode];
            double totalPrice = [CacheUtil ocneedUploadFBPrice];
            ///价值回传
            if (totalPrice > 0) {
                [FBSDKAppEvents.shared logPurchase:totalPrice currency:currencyCode];
            }
            ///tba 价值回传
            ADBaseModel * adBaseModel = [[ADBaseModel alloc] init];
            [adBaseModel objcInit:price
                                 :currencyCode
                                 :strongSelf.lastConnectInterstitialAD.responseInfo.loadedAdNetworkResponseInfo.adNetworkClassName?strongSelf.lastConnectInterstitialAD.responseInfo.loadedAdNetworkResponseInfo.adNetworkClassName:@""
                                 :@""
                                 :@""
                                 :strongSelf.vpnConnectADModel.value[strongSelf.connectCurrentIndex].theAdID];
            [Request objcTbaAdRequest:adBaseModel];
        };
        self.connectInterstitialAD = nil;
        NSLog(@"[AD] vpnConnect 当前已显示，开始加载下一个备用");
        [self loadAd:LBADPositionConnect];
    }else {
        self.lastBackInterstitialAD = nil;
        self.lastBackInterstitialAD = self.backInterstitialAD;
        ///价值回传
        self.lastBackInterstitialAD.paidEventHandler = ^(GADAdValue * _Nonnull value) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            double price = [value.value doubleValue];
            NSString * currencyCode = value.currencyCode;
            [CacheUtil ocAddFBPriceWithPrice:price currency:currencyCode];
            double totalPrice = [CacheUtil ocneedUploadFBPrice];
            ///价值回传
            if (totalPrice > 0) {
                [FBSDKAppEvents.shared logPurchase:totalPrice currency:currencyCode];
            }
            ///tba 价值回传
            ADBaseModel * adBaseModel = [[ADBaseModel alloc] init];
            [adBaseModel objcInit:price
                                 :currencyCode
                                 :strongSelf.lastBackInterstitialAD.responseInfo.loadedAdNetworkResponseInfo.adNetworkClassName?strongSelf.lastBackInterstitialAD.responseInfo.loadedAdNetworkResponseInfo.adNetworkClassName:@""
                                 :@""
                                 :@""
                                 :strongSelf.backADModel.value[strongSelf.backCurrentIndex].theAdID];
            [Request objcTbaAdRequest:adBaseModel];
        };
        self.backInterstitialAD = nil;
        [self loadAd:LBADPositionBack];
        NSLog(@"[AD] back 当前已显示，开始加载下一个备用");
    }
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"[AD] did dismiss full screen content.");
    self.isShowPresent = NO;
    if (self.ADDismissBlock) {
        self.ADDismissBlock();
    }
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
    [[LBGoogleADUtil shareInstance] recordADClickNumber];
}

#pragma mark - Getter

@end
