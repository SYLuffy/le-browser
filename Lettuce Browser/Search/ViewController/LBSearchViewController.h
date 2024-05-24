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

/// fromModel 代表 已有网页数据
- (instancetype)initWithStartMode:(LBHomeStartMode)startMode fromModel:(nullable LBWebPageTabModel *)fromModel isAppdelegate:(BOOL)isAppdelegate;

@end

NS_ASSUME_NONNULL_END
