//
//  LBVpnUtil.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, LBVpnManagerState) {
    LBVpnManagerStateLoading,
    LBVpnManagerStateIdle,
    LBVpnManagerStatePreparing,
    LBVpnManagerStateReady,
    LBVpnManagerStateError
};

typedef NS_ENUM(NSUInteger, LBVpnState) {
    LBVpnStateIdle,
    LBVpnStateConnecting,
    LBVpnStateConnected,
    LBVpnStateDisconnecting,
    LBVpnStateDisconneced,
    LBVpnStateError,
};
@class LBVpnModel;
@interface LBVpnUtil : NSObject
@property (nonatomic, assign) BOOL connectedEver;
@property (nonatomic, assign) BOOL needConnectAfterLoaded;
@property (nonatomic, strong) LBVpnModel * currentConnectingVpnModel;
@property (nonatomic, strong) LBVpnModel * currentConnectedVpnModel;
@property (nonatomic, assign) LBVpnManagerState managerState;
@property (nonatomic, assign) LBVpnState vpnState;
@property (nonatomic, assign) BOOL isActiveConnect;
@property (nonatomic, assign) BOOL isActiveDisConnect;

+ (instancetype)shareInstance;

///创建Manager（vpn配置授权）
- (void)createWithCompletionHandler:(void (^)(NSError *error))completionHandler;

///加载Manager配置（已授权情况下）
- (void)load:(nullable void (^)(NSError *error))completionHandler;

///主动触发Vpn连接
-(void)connectWithServer:(LBVpnModel * _Nullable)model;

///主动触发Vpn连接
- (void)stopVPN;

@end

NS_ASSUME_NONNULL_END
