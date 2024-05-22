//
//  LBAppManagerCenter.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LBBootLoadingView,LBVpnModel;
@interface LBAppManagerCenter : NSObject

@property (nonatomic, weak) LBBootLoadingView * globalLoadingView;
@property (nonatomic, strong) NSMutableArray * vpnModelList;
/// vpn连接持续时间
@property (nonatomic, assign) NSInteger vpnKeepTime;
@property (nonatomic, assign) NSInteger lastVpnKeepTime;
@property (nonatomic, strong) LBVpnModel * currentVpnModel;
@property (nonatomic, assign) BOOL isShowDisconnectedVC;

+ (instancetype)shareInstance;

- (BOOL)checkShowNetworkNotReachableToast;

- (void)startVpnKeepTime;

- (void)stopVpnKeepTime;

- (NSString *)formatTime:(NSInteger)totalSeconds;

- (void)saveCurrentVpnInfo;

- (void)cleanCurrentVpnInfo;

@end

NS_ASSUME_NONNULL_END
