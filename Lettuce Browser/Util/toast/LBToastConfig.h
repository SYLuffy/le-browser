//
//  JJCToastConfig.h
//  JJCToast
//
//  Created by shenyi on 2021/12/15.
//  Copyright © 2021 jojo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kToastConfig ([LBToastConfig sharedInstance])

static inline UIWindow *JJCToast_currentWindow(void) {
    UIWindow* window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        window = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
    }
    return window;
}

@interface LBToastConfig : NSObject

@property (nonatomic, assign) BOOL showMask;
@property (nonatomic, assign) BOOL maskCoverNav;

@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, strong) UIColor *backColor;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont  *font;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat lineSpacing;

@property (nonatomic, assign) CGSize  tipImageSize;
@property (nonatomic, assign) CGFloat tipImageBottomMargin;
@property (nonatomic, assign) CGFloat leftPadding;
@property (nonatomic, assign) CGFloat topPadding;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat imageCornerRadius;

@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minTopMargin;
@property (nonatomic, assign) CGFloat minLeftMargin;

@property (nonatomic, strong) UIColor *attStrColor;
@property (nonatomic, assign) NSRange attStrRange;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)sharedInstance;

- (void)resetConfig;

@end
