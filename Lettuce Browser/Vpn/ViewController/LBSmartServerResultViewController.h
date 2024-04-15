//
//  LBSmartServerResultViewController.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, LBSmartType) {
    LBSmartTypeSuccessed,
    LBSmartTypeFailed,
};

@interface LBSmartServerResultViewController : UIViewController

- (instancetype)initWithSmartType:(LBSmartType)smartType;

@end

NS_ASSUME_NONNULL_END
