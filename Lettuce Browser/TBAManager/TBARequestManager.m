//
//  TBARequestManager.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/15.
//

#import "TBARequestManager.h"
#import "Lettuce_Browser-Swift.h"

@implementation TBARequestManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TBARequestManager * aManager = nil;
    dispatch_once(&onceToken, ^{
        aManager = [[TBARequestManager alloc] init];
    });
    return aManager;
}

- (void)logEvent:(NSString *)eventName params:(NSDictionary *)dict {
    
}

@end
