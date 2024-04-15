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

- (instancetype)initWithVpnStatus:(LBVpnStatus)status;

- (void)updateUI:(LBVpnStatus)status;

@end

NS_ASSUME_NONNULL_END
