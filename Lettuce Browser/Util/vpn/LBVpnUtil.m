//
//  LBVpnUtil.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/11.
//

#import "LBVpnUtil.h"
#import <NetworkExtension/NetworkExtension.h>
#import "LBVpnModel.h"
#import "Lettuce_Browser-Swift.h"

static LBVpnUtil * vpnUtil = nil;

@interface LBVpnUtil ()
@property (nonatomic, strong) NETunnelProviderManager * manager;
@property (nonatomic, strong) NSString * currentConnectIpAdress;

@end

@implementation LBVpnUtil

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vpnUtil = [[LBVpnUtil alloc] init];
    });
    return vpnUtil;
}

- (void)addVPNStatusDidChangeObserver {
    if (self.manager) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVPNStatus) name:NEVPNStatusDidChangeNotification object:nil];
    }
   
}

- (void)removeVPNStatusDidChangeObserver:(NSNotification *)notification {
    
}

- (void)updateVPNStatus {
    if (self.manager) {
        if ([self.manager.connection isKindOfClass:[NETunnelProviderSession class]]) {
            NETunnelProviderSession * session = (NETunnelProviderSession *)self.manager.connection;
//            if (!self.connectedEver && session.status != LBVpnStateDisconneced) {
//                NSString * logInfo = [NSString stringWithFormat:@"[VPN MANAGER] not connected yet, but status is (%ld)",(long)session.status];
//                LBDebugLog(logInfo);
//                return;
//            }
            switch (session.status) {
                case NEVPNStatusConnecting:
                    LBDebugLog(@"NEVPNStatusConnecting");
                    self.vpnState = LBVpnStateConnecting;
                    break;
                case NEVPNStatusConnected:
                    LBDebugLog(@"NEVPNStatusConnected");
                    self.vpnState = LBVpnStateConnected;
                    [[LBADNativeManager shareInstance] load:LBADPositionResultNative];
                    [[LBAppManagerCenter shareInstance] saveCurrentVpnInfo];
                    [LBTBALogManager objcLogEventWithName:@"pro_link2" params:@{@"rot":self.currentConnectIpAdress?self.currentConnectIpAdress:@"38.68.134.141"}];
                    break;
                case NEVPNStatusDisconnecting:
                    LBDebugLog(@"NEVPNStatusDisconnecting");
                    self.vpnState = LBVpnStateDisconnecting;
                    break;
                case NEVPNStatusDisconnected:
                    LBDebugLog(@"NEVPNStatusDisconnected");
                    self.vpnState = LBVpnStateDisconneced;
                    if (self.isActiveDisConnect) {
                        self.isActiveDisConnect = NO;
                    }else {
                        [LBAppManagerCenter shareInstance].isShowDisconnectedVC = YES;
                    }
                    [[LBAppManagerCenter shareInstance] stopVpnKeepTime];
                    [[LBAppManagerCenter shareInstance] cleanCurrentVpnInfo];
                    break;
                case NEVPNStatusInvalid:
                    LBDebugLog(@"NEVPNStatusInvalid");
                    self.vpnState = LBVpnStateError;
                    [LBToast showMessage:@"Try it agin." duration:3 finishHandler:nil];
                    break;
                default:
                    break;
            }
        }
    }
  
}

#pragma mark - vpn
-(void)connectWithServer:(LBVpnModel * _Nullable)model {
    self.currentConnectIpAdress = model.vpnInfo.serverIP;
    [LBTBALogManager objcLogEventWithName:@"pro_link" params:nil];
    [LBTBALogManager objcLogEventWithName:@"pro_link0" params:@{@"rot":model.vpnInfo.serverIP}];
    self.currentConnectingVpnModel = model;
    self.isActiveConnect = YES;
    NSString * logInfo = [NSString stringWithFormat:@"记录当前正在连接的vpn：name:%@,ip:%@", self.currentConnectingVpnModel.iconName, self.currentConnectingVpnModel.vpnInfo.serverIP];
    LBDebugLog(logInfo);
    if (!self.manager) {
        LBDebugLog(@"[VPN MANAGER] manager is nil, cannot connect");
        [LBTBALogManager objcLogEventWithName:@"pro_link1" params:nil];
        self.vpnState = LBVpnStateError;
        return;
    }
    
    if (!self.manager.isEnabled) {
        LBDebugLog(@"[VPN MANAGER] manager is not enabled");
        self.needConnectAfterLoaded = YES;
        
        __weak typeof(self) weakSelf = self;
        [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                NSString * loginInfo = [NSString stringWithFormat:@"[VPN MANAGER] cannot enable mananger: %@", error.localizedDescription];
                LBDebugLog(loginInfo);
                [LBTBALogManager objcLogEventWithName:@"pro_link1" params:nil];
                strongSelf.managerState = LBVpnManagerStateError;
            } else {
                [strongSelf.manager setEnabled:YES];
                [strongSelf.manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                    if (error) {
                        NSString * logInfo = [NSString stringWithFormat:@"[VPN MANAGER] cannot save manager into preferences: %@", error.localizedDescription];
                        LBDebugLog(logInfo);
                        [LBTBALogManager objcLogEventWithName:@"pro_link1" params:nil];
                        strongSelf.managerState = LBVpnManagerStateError;
                    } else {
                        [self startVPNTunnelWithServer:model];
                    }
                }];
            }
        }];
    } else {
        [self startVPNTunnelWithServer:model];
    }
}

- (void)stopVPN {
    self.isActiveDisConnect = YES;
    NEVPNConnection *connection = self.manager.connection;
    if (connection && connection.status != NEVPNStatusDisconnected) {
        NSString * logInfo = [NSString stringWithFormat:@"记录当前正在断开的vpn：name:%@,ip:%@", self.currentConnectedVpnModel.iconName, self.currentConnectedVpnModel.vpnInfo.serverIP];
        LBDebugLog(logInfo);
        [connection stopVPNTunnel];
    }
}

- (void)startVPNTunnelWithServer:(LBVpnModel * _Nullable)model {
    if (!self.manager) {
        LBDebugLog(@"[VPN MANAGER] manager is nil, cannot connect");
        return;
    }
    if ([CacheUtil objecGetUserGo]) {
        [[LBADInterstitialManager shareInstance] loadAd:LBADPositionBack];
    }
    NSError *error = nil;
    [self.manager.connection startVPNTunnelWithOptions:[model objectConfig] andReturnError:&error];
    if (error) {
        [LBTBALogManager objcLogEventWithName:@"pro_link1" params:nil];
        NSString * logInfo = [NSString stringWithFormat:@"[VPN MANAGER] Start VPN failed %@", error.localizedDescription];
        LBDebugLog(logInfo);
        self.vpnState = LBVpnStateError;
    } else {
        self.connectedEver = YES;
        self.currentConnectedVpnModel = self.currentConnectingVpnModel;
        self.vpnState = LBVpnStateConnected;
    }
}

- (NSDate *)getCurrentConnectedTime {
    if (self.vpnState == LBVpnStateConnected) {
        return self.manager.connection.connectedDate;
    }
    return nil;
}

#pragma mark - vpnManager

- (void)createWithCompletionHandler:(void (^)(NSError *error))completionHandler {
    NETunnelProviderManager *manager = [[NETunnelProviderManager alloc] init];
    [manager setEnabled:YES];
    NETunnelProviderProtocol *p = [[NETunnelProviderProtocol alloc] init];
    p.serverAddress = @"Lettuce Browser";
    p.providerBundleIdentifier = @"com.lettucebrowser.iosyaho.proxy";
    p.providerConfiguration = @{@"manager_version": @"manager_v1"};
    manager.protocolConfiguration = p;
    self.connectedEver = false;
    [manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            self.managerState = LBVpnManagerStateError;
            if (completionHandler != nil) {
                completionHandler(error);
            }
            return;
        }
        
        [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSString * codeInfo = [NSString stringWithFormat:@"[VPN MANAGER] code: %ld", (long)NEVPNErrorConfigurationReadWriteFailed];
                NSString * codeInfo1 = [NSString stringWithFormat:@"[VPN MANAGER] code: %ld", (long)NEVPNErrorConfigurationStale];
                NSString * errorInfo = [NSString stringWithFormat:@"[VPN MANAGER] create failed: %@", error.localizedDescription];
                self.managerState = LBVpnManagerStateError;
                LBDebugLog(codeInfo);
                LBDebugLog(codeInfo1);
                LBDebugLog(errorInfo);
                if (completionHandler != nil) {
                    completionHandler(error);
                }
            } else {
                [self load:completionHandler];
            }
        }];
    }];
}

- (void)load:(void (^)(NSError *error))completionHandler {
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if (error) {
            self.managerState = LBVpnManagerStateError;
            self.connectedEver = false;
            NSLog(@"[VPN MANAGER] cannot load managers from preferences: %@", error.localizedDescription);
            if (completionHandler != nil) {
                completionHandler(error);
            }
            return;
        }
        
        if (managers.count == 0) {
            self.managerState = LBVpnManagerStateIdle;
            self.connectedEver = false;
            NSLog(@"[VPN MANAGER] have no manager");
            NSError * error1 = [NSError errorWithDomain:@"[VPN MANAGER] have no manager" code:11000 userInfo:nil];
            if (completionHandler != nil) {
                completionHandler(error1);
            }
            return;
        }
        
        NETunnelProviderManager *manager = managers.firstObject;
        [manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"[VPN MANAGER] cannot load manager from preferences: %@", error.localizedDescription);
                self.managerState = LBVpnManagerStateError;
                if (completionHandler != nil) {
                    completionHandler(error);
                }
            }
            
            NSLog(@"[VPN MANAGER] manager loaded from preferences");
            self.manager = manager;
            self.managerState = LBVpnManagerStateReady;
            [self addVPNStatusDidChangeObserver];
            [self updateVPNStatus];
            if (completionHandler != nil) {
                completionHandler(nil);
            }
        }];
    }];
}

- (void)prepareForLoadingWithCompletionHandler:(void (^)(void))completionHandler {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        int times = 20;
        while (times > 0) {
            times -= 1;
            if (self.managerState != LBVpnManagerStateLoading) {
                [self makeSureRunInMainThread:^{
                    completionHandler();
                }];
                return;
            }
            [NSThread sleepForTimeInterval:0.2];
        }
        [self makeSureRunInMainThread:^{
            completionHandler();
        }];
    });
}

- (void)makeSureRunInMainThread:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}



@end
