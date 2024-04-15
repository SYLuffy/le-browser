//
//  UIColor+JJCHex.m
//  JJCBase
//
//  Created by RyanYuan on 2021/2/20.
//

#import "UIColor+LBHex.h"

@implementation UIColor (LBHex)

+ (UIColor *)LB_colorWithHex:(uint)hex {
    int red, green, blue, alpha;

    blue = hex & 0x000000FF;
    green = ((hex & 0x0000FF00) >> 8);
    red = ((hex & 0x00FF0000) >> 16);
    alpha = ((hex & 0xFF000000) >> 24);

    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:alpha/255.f];
}

+ (UIColor *)LB_colorWithHex:(uint)hex andAlpha:(float)alpha {
    int red, green, blue;

    blue = hex & 0x000000FF;
    green = ((hex & 0x0000FF00) >> 8);
    red = ((hex & 0x00FF0000) >> 16);

    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:alpha];
}

@end
