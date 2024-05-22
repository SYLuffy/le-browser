//
//  LBADOpenManager.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/16.
//

#import "LBADOpenManager.h"
#import <GoogleMobileAds/GADAppOpenAd.h>
#import "Lettuce_Browser-Swift.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>

NSString * kDismissNotification = @"kDismissNotification";

static NSTimeInterval const fourHoursInSeconds = 3600 * 4;

@interface LBADOpenManager () <GADFullScreenContentDelegate>

@property (nonatomic, assign) BOOL isLoadingAd;
@property (nonatomic, strong) NSDate *loadTime;
@property (nonatomic, strong) GADAppOpenAd * currentShowAD;
///当前使用的广告id索引
///waterfall，当前请求失败，自动切换下一个adid请求
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation LBADOpenManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static LBADOpenManager *aManager = nil;
    dispatch_once(&onceToken, ^{
        aManager = [[LBADOpenManager alloc] init];
        aManager.currentIndex = 0;
        [[NSNotificationCenter defaultCenter] addObserver:aManager
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    });
    return aManager;
}

- (void)loadAd {
    if ([[LBGoogleADUtil shareInstance] isADLimit]) {
        return;
    }
    if (self.isLoadingAd || [self isAdAvailable]) {
        return;
    }
    NSLog(@"[AD] loadingOpenAd 开始加载");
    if (self.adModel.value.count > 0) {
        self.isLoadingAd = YES;
        [GADAppOpenAd loadWithAdUnitID:self.adModel.value[self.currentIndex].theAdID
                               request:[GADRequest request]
                     completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
            self.isLoadingAd = NO;
            if (error) {
                [self waterFallEvent];
                return;
            }
            NSLog(@"[AD] loadingOpenAd 加载完成 ✅✅");
            self.appOpenAd = appOpenAd;
            self.appOpenAd.fullScreenContentDelegate = self;
        }];
    }
}

- (void)waterFallEvent {
    self.currentIndex ++;
    if (self.currentIndex >= self.adModel.value.count) {
        self.currentIndex = 0;
        NSLog(@"[AD] loadingOpenAd 当前ad组内都已请求失败，等待下次触发");
    }else {
        NSLog(@"[AD] loadingOpenAd 当前序号 %ld 加载失败，waterfall自动切到序号 %ld adid加载 ❌❌",self.currentIndex,self.currentIndex + 1);
        [self loadAd];
    }
}

- (void)showAdIfAvailable {
    if ([[LBGoogleADUtil shareInstance] isADLimit]) {
        return;
    }
  if (self.isShowingAd) {
    return;
  }
    
  if (![self isAdAvailable]) {
    [self loadAd];
    return;
  }

  self.isShowingAd = YES;
  [self.appOpenAd presentFromRootViewController:nil];
}

- (BOOL)wasLoadTimeLessThanFourHoursAgo {
  return [[NSDate date] timeIntervalSinceDate:self.loadTime] < fourHoursInSeconds;
}

- (BOOL)isAdAvailable {
  return self.appOpenAd != nil;
}

- (void)applicationDidEnterBackground:(NSNotification *)noti {
    /// 退到后台关掉插屏广告
    [self dismiss];
}

- (void)dismiss {
    if (self.isShowingAd) {
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
        self.isShowingAd = NO;
        NSLog(@"[AD] loadingOpenAd 已关闭");
    }
}

#pragma mark - GADFullScreenContentDelegate

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [[LBGoogleADUtil shareInstance] recordADImpressNumber];
    self.currentShowAD = nil;
    self.currentShowAD = self.appOpenAd;
    self.currentShowAD.paidEventHandler = ^(GADAdValue * _Nonnull value) {
        double price = [value.value doubleValue];
        NSString * currencyCode = value.currencyCode;
        [CacheUtil ocAddFBPriceWithPrice:price currency:currencyCode];
        double totalPrice = [CacheUtil ocneedUploadFBPrice];
        ///价值回传
        if (totalPrice > 0) {
            [FBSDKAppEvents.shared logPurchase:totalPrice currency:currencyCode];
        }
    };
    self.appOpenAd = nil;
    self.isShowingAd = YES;
    NSLog(@"[AD] loadingOpenAd 开始加载下一个备用");
    [self loadAd];
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    self.isShowingAd = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kDismissNotification object:nil];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    self.appOpenAd = nil;
    self.isShowingAd = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kDismissNotification object:nil];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
    [[LBGoogleADUtil shareInstance] recordADClickNumber];
}

@end
