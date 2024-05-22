//
//  LBADInterstitialManager.h
//  Lettuce Browser
//
//  Created by shen on 2024/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBADInterstitialManager : NSObject

@property (nonatomic, strong) LBGoogleADModel * vpnConnectADModel;
@property (nonatomic, strong) LBGoogleADModel * backADModel;

@property (nonatomic, copy) void(^ADDismissBlock)(void);

+ (instancetype)shareInstance;

- (void)loadAd:(LBADPosition)adPosition;

- (void)showAd:(LBADPosition)adPosition;

- (GADInterstitialAd *)getCurrentAdModel:(LBADPosition)adPosition;

@end

NS_ASSUME_NONNULL_END
