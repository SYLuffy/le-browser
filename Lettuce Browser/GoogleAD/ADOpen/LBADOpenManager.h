//
//  LBADOpenManager.h
//  Lettuce Browser
//
//  Created by shen on 2024/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * kDismissNotification;

@interface LBADOpenManager : NSObject

@property (nonatomic, strong, nullable) GADAppOpenAd *appOpenAd;
@property (nonatomic, strong) LBGoogleADModel *adModel;
@property (nonatomic, assign) BOOL isShowingAd;

+ (instancetype)shareInstance;

- (void)loadAd;

- (void)showAdIfAvailable;

@end

NS_ASSUME_NONNULL_END
