//
//  LBVpnSmartServerEntrenceVIew.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import <UIKit/UIKit.h>

@protocol SmartServerEntrenceProtocol <NSObject>

- (BOOL)isEnableEnter;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LBVpnSmartServerEntrenceVIew : UIView

@property (nonatomic, weak) id <SmartServerEntrenceProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
