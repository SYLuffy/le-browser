//
//  LBTabManagerView.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBTabManagerView : UIView

@property (nonatomic, copy) void(^backToBlock)(void);

+ (LBTabManagerView *)popShowWithSuperView:(nullable UIView *)superView fromModel:(LBWebPageTabModel *)fromModel;

@end

NS_ASSUME_NONNULL_END
