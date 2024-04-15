//
//  LBVpnInfoModel.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBVpnInfoModel : NSObject

@property (nonatomic, strong) NSString *serverIP;
@property (nonatomic, strong) NSString *serverPort;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *password;

@end

NS_ASSUME_NONNULL_END
