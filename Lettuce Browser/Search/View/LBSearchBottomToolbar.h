//
//  LBSearchBottomToolbar.h
//  Lettuce Browser
//
//  Created by jojo on 2024/4/4.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LBToolbarType) {
    LBToolbarTypePrev,       ///上一页
    LBToolbarTypeNext,       ///下一页
    LBToolbarTypeClean,      ///清理
    LBToolbarTypeTag,        ///标签页
    LBToolbarTypeSetting,    ///设置
};

NS_ASSUME_NONNULL_BEGIN
@class WKWebView;
@interface LBSearchBottomToolbar : UIView

@property (nonatomic, copy) void(^toolBarClickBlock)(LBToolbarType type);

- (void)updateToolBarState:(WKWebView *)webView;

- (void)updateToolBarTabCount;

- (void)resertToolBarState;

@end

NS_ASSUME_NONNULL_END
