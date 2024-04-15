//
//  LBSearchTopView.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface LBSearchTopView : UIView

@property (nonatomic, copy)void(^searchInputBlock)(NSString *inputString);
@property (nonatomic, copy)void(^textDidBeginEditBlock)(void);
@property (nonatomic, copy)void(^cleanInputBlock)(void);

- (void)updateInputUrl:(NSString *)urlString;

- (void)updateWebviewLoading:(WKWebView *)webView;

- (void)updateProgressValue:(CGFloat)progressValue;

- (void)textFiledEndEdit;

@end

NS_ASSUME_NONNULL_END
