//
//  LBWebPageTabModel.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import "LBWebPageTabModel.h"

@implementation LBWebPageTabModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.tabKey forKey:@"tabKey"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.screenShot forKey:@"screenShot"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder { 
    self = [super init];
    if (self) {
        self.tabKey = [coder decodeObjectForKey:@"tabKey"];
        self.url = [coder decodeObjectForKey:@"url"];
        self.screenShot = [coder decodeObjectForKey:@"screenShot"];
    }
    return self;
}


@end
