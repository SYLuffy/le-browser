//
//  LBVpnViewController.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBVpnViewController : UIViewController

- (instancetype)initWithNeedStartConnect:(BOOL)isStartConnect;

- (void)vpnDisconnected;

@end

NS_ASSUME_NONNULL_END
