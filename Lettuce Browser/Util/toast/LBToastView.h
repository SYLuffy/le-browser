//
//  JJAToastView.h
//  JJCToast
//
//  Created by shenyi on 2021/12/15.
//  Copyright © 2021 jojo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JJCToastType) {
    JJCToastTypeWords = 0,
    JJCToastTypeImage,
};

@interface LBToastView : UIView

+ (instancetype _Nullable)toastWithMessage:(NSString * _Nullable)message
                                      type:(JJCToastType)type
                                   originY:(CGFloat)originY
                                  tipImage:(UIImage * _Nullable)image;

@end
