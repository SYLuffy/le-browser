//
//  LBAppManagerCenter.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LBAppNetworkStatus) {
    LBAppNetworkStatusUnknow = -1,          ///未知
    LBAppNetworkStatusNotReachable = 0,     ///未联网
    LBAppNetworkStatusReachable = 1,        ///联网
};

@class LBBootLoadingView,LBVpnModel;
@interface LBAppManagerCenter : NSObject

@property (nonatomic, weak) LBBootLoadingView * globalLoadingView;
@property (nonatomic, assign) LBAppNetworkStatus networkStatus;
@property (nonatomic, strong) NSMutableArray * vpnModelList;
/// vpn连接持续时间
@property (nonatomic, assign) NSInteger vpnKeepTime;
@property (nonatomic, strong) LBVpnModel * currentVpnModel;
@property (nonatomic, assign) BOOL isShowDisconnectedVC;

+ (instancetype)shareInstance;

- (BOOL)checkShowNetworkNotReachableToast;

- (void)startVpnKeepTime;

- (void)stopVpnKeepTime;

- (NSString *)formatTime:(NSInteger)totalSeconds;

@end

NS_ASSUME_NONNULL_END
