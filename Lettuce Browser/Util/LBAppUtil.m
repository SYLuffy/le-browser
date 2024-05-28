//
//  LBAppUtil.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/28.
//

#import "LBAppUtil.h"

@interface LBAppUtil ()

@end

@implementation LBAppUtil

+ (BOOL)isUseADABCache {
    return YES;
}

+ (NSString *)name {
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleExecutable"] ?: @"Lettuce Browser";
}

+ (NSString *)version {
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
}

+ (NSString *)build {
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"] ?: @"1";
}

+ (NSString *)bundle {
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"] ?: @"com.lettucebrowser.iosyaho";
}

+ (NSString *)group {
    return [@"group." stringByAppendingString:[self bundle]];
}

+ (NSString *)proxy {
    return [[self bundle] stringByAppendingString:@".proxy"];
}

+ (NSString *)localCountry {
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

+ (BOOL)isDebug {
    return ![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.lettucebrowser.iosyaho"];
}

@end
