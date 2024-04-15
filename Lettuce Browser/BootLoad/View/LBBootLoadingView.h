//
//  LBBootLoadingView.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LBLoadingMode) {
    LBLoadingModeColdBoot,  ///冷启动
    LBLoadingModeFireBoot,  ///热启动
};

@interface LBBootLoadingView : UIView

///superView为空，默认加在window上
+ (LBBootLoadingView *)showLoadingMode:(LBLoadingMode)loadingMode superView:(nullable UIView *)superView;

@end

NS_ASSUME_NONNULL_END
