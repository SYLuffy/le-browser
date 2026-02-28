//
//  LBVPNGuideView.h
//  Lettuce Browser
//
//  Created on 2025/2/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBVPNGuideView : UIView

/// Show the VPN feature guide overlay. Displays only once per user.
/// @param superView The view to add the guide to. If nil, uses the key window.
/// @param targetFrame The frame of the VPN entrance view in the superView's coordinate system.
/// @param completion Called when the user taps "Try Now" (YES) or "Skip" (NO).
+ (void)showGuideOnView:(nullable UIView *)superView
        vpnEntranceFrame:(CGRect)targetFrame
              completion:(nullable void(^)(BOOL didTapTryNow))completion;

/// Returns YES if the guide has already been shown to the user.
+ (BOOL)hasShownGuide;

/// Reset the guide shown state (for testing purposes).
+ (void)resetGuideState;

@end

NS_ASSUME_NONNULL_END
