//
//  LBAppUtil.h
//  Lettuce Browser
//
//  Created by shen on 2024/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBAppUtil : NSObject

/// 是否启用广告 AB缓存池
+ (BOOL)isUseADABCache;

+ (BOOL)isUseADABCacheCache;

/// 应用名称
+ (NSString *)name;
/// 版本号
+ (NSString *)version;
/// build号
+ (NSString *)build;
/// 包名
+ (NSString *)bundle;

+ (NSString *)group;
+ (NSString *)proxy;
+ (NSString *)localCountry;
/// 根据包名判断是否是debug
+ (BOOL)isDebug;

@end

NS_ASSUME_NONNULL_END
