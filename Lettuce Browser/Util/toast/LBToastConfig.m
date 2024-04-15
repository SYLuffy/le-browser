//
//  JJCToastConfig.m
//  JJCToast
//
//  Created by shenyi on 2021/12/15.
//  Copyright © 2021 jojo. All rights reserved.
//

#import "LBToastConfig.h"

@implementation LBToastConfig

static id _instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetConfig];
    }
    return self;
}

- (void)resetConfig {
    _showMask = NO;
    _maskCoverNav = YES;
    _leftPadding = 26;
    _topPadding = 8;
    _cornerRadius = 12;
    _imageCornerRadius = 8;
    _minWidth = 16;
    _minTopMargin = 60;
    _minLeftMargin = 40;
    _lineSpacing = 0;
    _lineHeight = 20;
    _tipImageBottomMargin = 8;
    _tipImageSize = CGSizeMake(50, 50);
    _maskColor = [UIColor colorWithWhite:0 alpha:0.3];
    _textColor = [UIColor whiteColor];
    _backColor = [UIColor colorWithWhite:0 alpha:0.7];
    _font = [UIFont systemFontOfSize:14];
}

@end
