//
//  LBGoogleADConfigModel.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/20.
//

#import "LBGoogleADConfigModel.h"

@implementation LBGoogleADValueModel


@end

@implementation LBGoogleADModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"value":[LBGoogleADValueModel class]
    };
}

@end

@implementation LBGoogleADConfigModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"ads":[LBGoogleADModel class]
    };
}

@end
