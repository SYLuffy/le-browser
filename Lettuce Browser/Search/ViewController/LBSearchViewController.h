//
//  LBBootLoadViewController.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LBHomeStartMode) {
    LBHomeStartModeCold,    ///冷启动
    LBHomeStartModeAddNew,  ///添加新的
};

NS_ASSUME_NONNULL_BEGIN

@interface LBSearchViewController : UIViewController

- (instancetype)initWithStartMode:(LBHomeStartMode)startMode fromModel:(nullable LBWebPageTabModel *)fromModel;

@end

NS_ASSUME_NONNULL_END
