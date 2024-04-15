//
//  UIView+Util.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import "UIView+Util.h"

@implementation UIView (Util)

- (UIImage *)takeScreenshot {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kLBDeviceWidth, kLBDeviceHeight), NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

@end
