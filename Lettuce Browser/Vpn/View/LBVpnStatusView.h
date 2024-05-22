//
//  LBVpnStatusView.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, LBVpnStatus) {
    LBVpnStatusNormal,
    LBVpnStatusConnecting,
    LBVpnStatusConnected,
    LBVpnStatusDisconnecting,
    LBVpnStatusDisconnected,
};

@interface LBVpnStatusView : UIView

@property (nonatomic, assign) LBVpnStatus vpnStatus;
///是否正在展示connect插屏广告
@property (nonatomic, assign) BOOL isShowConnectAD;

- (instancetype)initWithVpnStatus:(LBVpnStatus)status;

- (void)updateUI:(LBVpnStatus)status;

///直接开始连接
- (void)clickEvent;

@end

NS_ASSUME_NONNULL_END
