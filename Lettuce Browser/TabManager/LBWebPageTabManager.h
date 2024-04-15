//
//  LBWebPageTabManager.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import <Foundation/Foundation.h>
#import "LBWebPageTabModel.h"

NS_ASSUME_NONNULL_BEGIN
@class LBSearchViewController;
@interface LBWebPageTabManager : NSObject

@property (nonatomic, copy) void(^removeWebTabFinish)(NSDate *removeTabKey ,LBWebPageTabModel *firstModel);

+ (instancetype)shareInstance;

///增加一个tab
- (LBWebPageTabModel *)addNewWebTabScreenShot:(UIImage *)screenShot;

///更新tab内的内容
- (void)updateTabModel:(LBWebPageTabModel *)model;

///删除tab
- (void)removeWebTabfor:(LBWebPageTabModel *)tabModel;

///删除全部tab
- (void)removeAllWebTab;

///获取所有WebTab的截图列表
- (NSArray *)getAllWebTabVCScreenShot;

///当前有多少个tab
- (NSInteger)countOfScreenShotArrays;

- (void)addNewSerchVC:(nullable LBWebPageTabModel *)fromModel;

- (LBWebPageTabModel *)getFirstTabModel;

@end

NS_ASSUME_NONNULL_END
