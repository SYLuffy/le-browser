//
//  LBCleanView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/7.
//

#import "LBCleanView.h"
#import "Lettuce_Browser-Swift.h"

@interface LBCleanView ()<CAAnimationDelegate>

@property (nonatomic, strong) UIImageView * iconImgView;
@property (nonatomic, strong) UIImageView * rotateImgView;
@property (nonatomic, strong) UILabel * loadingLabel;

@end

@implementation LBCleanView

+ (LBCleanView *)showCleanLoadingWithSuperView:(UIView *)superView {
    LBCleanView * cleanView = [[LBCleanView alloc] init];
    if (!superView) {
        [[UIApplication sharedApplication].windows.firstObject addSubview:cleanView];
    }else {
        [superView addSubview:cleanView];
    }
    [LBTBALogManager objcLogEventWithName:@"session_start" params:nil];
    return cleanView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    self.frame = CGRectMake(0, 0, kLBDeviceWidth, kLBDeviceHeight);
    [self bgGradient];
    
    [self addSubview:self.rotateImgView];
    [self addSubview:self.iconImgView];
    [self addSubview:self.loadingLabel];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(133));
        make.centerX.mas_equalTo(self.rotateImgView.mas_centerX);
        make.centerY.mas_equalTo(self.rotateImgView.mas_centerY);
    }];
    
    [self.rotateImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(221));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top).offset(LBAdapterHeight(225));
    }];
    
    [self.loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rotateImgView.mas_bottom).offset(LBAdapterHeight(150));
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(LBAdapterHeight(22));
    }];
    
    [self startLoadinganimation];
}

- (void)startLoadinganimation {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = 3;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.delegate = self;
    rotationAnimation.removedOnCompletion = NO;
    
    [self.rotateImgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)bgGradient {
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    UIColor * startColor = [UIColor LB_colorWithHex:0xff98E468];
    UIColor * endColor = [UIColor LB_colorWithHex:0xff58C417];
    gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.frame = CGRectMake(0, 0, kLBDeviceWidth, kLBDeviceHeight);
    [self.layer addSublayer:gradientLayer];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [LBTBALogManager objcLogEventWithName:@"pro_cleanDone" params:nil];
        [[LBWebPageTabManager shareInstance] removeAllWebTab];
        if ([CacheUtil objecGetUserGo]) {
            [LBADInterstitialManager shareInstance].ADDismissBlock = ^{
                [self removeFromSuperview];
                [[LBWebPageTabManager shareInstance] addNewSerchVC:nil];
                [LBToast showMessage:@"Clean up successfully" duration:2 finishHandler:nil];
                [LBTBALogManager objcLogEventWithName:@"pro_cleanToast" params:@{@"bro":@3}];
            };
            [[LBADInterstitialManager shareInstance] showAd:LBADPositionBack];
        }else {
            [self removeFromSuperview];
            [[LBWebPageTabManager shareInstance] addNewSerchVC:nil];
            [LBToast showMessage:@"Clean up successfully" duration:2 finishHandler:nil];
            [LBTBALogManager objcLogEventWithName:@"pro_cleanToast" params:@{@"bro":@3}];
        }
    }else {
        [self startLoadinganimation];
    }
}

#pragma mark - Getter

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.image = [UIImage imageNamed:@"home_clean_icon"];
    }
    return _iconImgView;
}

- (UIImageView *)rotateImgView {
    if (!_rotateImgView) {
        _rotateImgView = [[UIImageView alloc] init];
        _rotateImgView.image = [UIImage imageNamed:@"home_clean_rotate"];
    }
    return _rotateImgView;
}

- (UILabel *)loadingLabel {
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] init];
        _loadingLabel.textColor = [UIColor blackColor];
        _loadingLabel.text = @"Cleaning...";
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        _loadingLabel.font = [UIFont systemFontOfSize:16];
    }
    return _loadingLabel;
}

@end
