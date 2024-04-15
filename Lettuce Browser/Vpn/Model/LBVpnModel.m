//
//  LBSmartServerModel.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import "LBVpnModel.h"

@implementation LBVpnModel

- (NSDictionary<NSString *, NSObject *> *)objectConfig {
    NSString *host = self.vpnInfo.serverIP;
    NSString *port = self.vpnInfo.serverPort;
    NSString *method = self.vpnInfo.method;
    NSString *password = self.vpnInfo.password;
    
    NSDictionary<NSString *, NSObject *> *objectDictionary = @{@"host": host, @"port": port, @"method": method, @"password": password};
//    NSString * logInfo = [NSString stringWithFormat:@"server = %@", objectDictionary];
//    LBDebugLog(logInfo);
    return objectDictionary;
}

@end
