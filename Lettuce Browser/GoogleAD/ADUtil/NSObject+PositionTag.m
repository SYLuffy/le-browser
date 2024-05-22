//
//  NSObject+PositionTag.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/20.
//

#import "NSObject+PositionTag.h"
#import <objc/runtime.h>

static const char *positionTagKey = "positionTag";

@implementation NSObject (PositionTag)

- (int)positionTag {
    NSNumber *tag = objc_getAssociatedObject(self, positionTagKey);
    return tag ? [tag intValue] : 0;
}

- (void)setPositionTag:(int)tag {
    objc_setAssociatedObject(self, positionTagKey, @(tag), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
