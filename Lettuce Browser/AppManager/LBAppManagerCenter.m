//
//  LBAppManagerCenter.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import "LBAppManagerCenter.h"
#import "LBVpnModel.h"
#import "Lettuce_Browser-Swift.h"

static LBAppManagerCenter * aManager = nil;
static NSString * const kSaveConnectedVpnName = @"kSaveConnectedVpnName";

@interface LBAppManagerCenter ()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation LBAppManagerCenter

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aManager = [[LBAppManagerCenter alloc] init];
        aManager.vpnKeepTime = 0;
        [aManager initData];
    });
    return aManager;
}

- (void)initData {
    /// 请求cloak
    [Request objcCloak];
    /// 初始化TBA上报请求
    [Request objcPreload];
    [Request objcTbaRequestWithKey:@"install"];
    [Request objcTbaRequestWithKey:@"first_Open"];
    
    [LBTBALogManager objcLogEventWithName:@"pro_lun" params:nil];
    [LBTBALogManager objcLogEventWithName:@"pro_clod" params:nil];
    
    NSString * vpnTitle = [[NSUserDefaults standardUserDefaults] objectForKey:kSaveConnectedVpnName];
    self.vpnModelList = [self getVpnConfigList];
    
    if (vpnTitle && vpnTitle.length > 0) {
        for (LBVpnModel * model in self.vpnModelList) {
            if ([vpnTitle isEqualToString:model.titleName]) {
                self.currentVpnModel = model;
            }
        }
    }else {
        self.currentVpnModel = self.vpnModelList[0];
    }
    
}

- (BOOL)checkShowNetworkNotReachableToast {
   if ([ReachabilityUtil ocIsConnected] == false) {
        [LBToast showMessage:@"Local network is not turned on." duration:3 finishHandler:nil];
        return YES;
    }
    return NO;
}

- (NSMutableArray *)getVpnConfigList {
    ///,@"vpn_smart_Germany",@"vpn_smart_France",@"vpn_smart_Japan",@"vpn_smart_Australia",@"vpn_smart_Singapore"
    ///,@"Germany",@"France",@"Japan",@"Australia",@"Singapore"
    NSMutableArray * mArrays = [[NSMutableArray alloc] init];
    NSArray * iconNameArray = @[@"vpn_smart_smart",@"vpn_smart_US",@"vpn_smart_US"];
    NSArray * countryArray = @[@"Smart Server",@"Unite States-Dallas",@"Unite States-Ashburn"];
    NSArray * ipArrays = @[@"38.68.134.141",@"38.68.134.141",@"45.135.229.173"];
    for (int i = 0; i < iconNameArray.count; i ++) {
        NSString * imageName = iconNameArray[i];
        NSString * countryName = countryArray[i];
        LBVpnModel * model = [[LBVpnModel alloc] init];
        model.iconName = imageName;
        model.titleName = countryName;
        LBVpnInfoModel * infoModel = [[LBVpnInfoModel alloc] init];
        infoModel.serverIP = ipArrays[i];
        infoModel.serverPort = @"1497";
        infoModel.password = @"bahoKuxVZqklBiWC";
        infoModel.method = @"chacha20-ietf-poly1305";
        model.vpnInfo = infoModel;
        [mArrays addObject:model];
    }
    return mArrays;
}

- (void)startVpnKeepTime {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_WALLTIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self countDownTime];
    });
    dispatch_resume(timer);
    self.timer = timer;
}

/// format 计时
- (NSString *)formatTime:(NSInteger)totalSeconds {
    NSInteger hours = totalSeconds / 3600;
    NSInteger minutes = (totalSeconds % 3600) / 60;
    NSInteger seconds = totalSeconds % 60;

    NSString *timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    
    return timeString;
}

- (void)countDownTime {
    self.vpnKeepTime += 1;
}

- (void)stopVpnKeepTime {
    if (self.timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    if (self.vpnKeepTime > 2) {
        [LBTBALogManager objcLogEventWithName:@"pro_disLink" params:@{@"duration":@(self.vpnKeepTime)}];
    }
    self.lastVpnKeepTime = self.vpnKeepTime;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.vpnKeepTime = 0;
    });
}

- (void)saveCurrentVpnInfo {
    [[NSUserDefaults standardUserDefaults] setObject:self.currentVpnModel.titleName forKey:kSaveConnectedVpnName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cleanCurrentVpnInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSaveConnectedVpnName];
}

#pragma mark - Getter

- (NSMutableArray *)vpnModelList {
    if (!_vpnModelList) {
        _vpnModelList = [[NSMutableArray alloc] init];
    }
    return _vpnModelList;
}

@end
