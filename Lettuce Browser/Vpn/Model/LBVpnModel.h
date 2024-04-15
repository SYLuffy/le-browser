//
//  LBSmartServerModel.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import <Foundation/Foundation.h>
#import "LBVpnInfoModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface LBVpnModel : NSObject

@property (nonatomic, strong)NSString *iconName;
@property (nonatomic, strong)NSString *titleName;
@property (nonatomic, strong)LBVpnInfoModel * vpnInfo;

- (NSDictionary<NSString *, NSObject *> *)objectConfig;

@end

NS_ASSUME_NONNULL_END
