//
//  LBVPNGuideView.m
//  Lettuce Browser
//
//  Created on 2025/2/28.
//

#import "LBVPNGuideView.h"

static NSString * const kLBVPNGuideShownKey = @"kLBVPNGuideHasShown";

@interface LBVPNGuideView ()

@property (nonatomic, assign) CGRect highlightFrame;
@property (nonatomic, strong) UIView *spotlightMaskView;
@property (nonatomic, strong) UIView *tipContainerView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIView *indicatorContainer;
@property (nonatomic, strong) UIButton *tryNowButton;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIView *fingerView;
@property (nonatomic, assign) NSInteger currentStep;
@property (nonatomic, copy, nullable) void(^completionBlock)(BOOL didTapTryNow);

@end

@implementation LBVPNGuideView

#pragma mark - Public

+ (void)showGuideOnView:(UIView *)superView
        vpnEntranceFrame:(CGRect)targetFrame
              completion:(void (^)(BOOL))completion {
    if ([self hasShownGuide]) {
        return;
    }

    LBVPNGuideView *guideView = [[LBVPNGuideView alloc] initWithHighlightFrame:targetFrame];
    guideView.completionBlock = completion;

    if (!superView) {
        superView = [UIApplication sharedApplication].windows.firstObject;
    }
    [superView addSubview:guideView];

    [guideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];

    [guideView showWithAnimation];
    [self markGuideAsShown];
}

+ (BOOL)hasShownGuide {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLBVPNGuideShownKey];
}

+ (void)resetGuideState {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLBVPNGuideShownKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)markGuideAsShown {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLBVPNGuideShownKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Init

- (instancetype)initWithHighlightFrame:(CGRect)highlightFrame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.highlightFrame = highlightFrame;
        self.currentStep = 0;
        [self initializeAppearance];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSpotlightMask];
}

- (void)updateSpotlightMask {
    if (CGRectIsEmpty(self.highlightFrame) || CGRectIsEmpty(self.bounds)) {
        return;
    }

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.bounds];
    CGRect expandedRect = CGRectInset(self.highlightFrame, -8, -6);
    UIBezierPath *highlightPath = [UIBezierPath bezierPathWithRoundedRect:expandedRect cornerRadius:LBAdapterHeight(16)];
    [overlayPath appendPath:highlightPath];
    maskLayer.path = overlayPath.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.spotlightMaskView.layer.mask = maskLayer;
}

#pragma mark - UI Setup

- (void)initializeAppearance {
    [self addSubview:self.spotlightMaskView];
    [self addSubview:self.fingerView];
    [self addSubview:self.tipContainerView];

    [self.tipContainerView addSubview:self.stepLabel];
    [self.tipContainerView addSubview:self.titleLabel];
    [self.tipContainerView addSubview:self.descLabel];
    [self.tipContainerView addSubview:self.indicatorContainer];
    [self.tipContainerView addSubview:self.tryNowButton];
    [self.tipContainerView addSubview:self.skipButton];

    [self setupStepIndicators];
    [self setupLayoutConstraints];
    [self updateContentForStep:0];
}

- (void)setupLayoutConstraints {
    [self.spotlightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];

    CGFloat tipTop = CGRectGetMaxY(self.highlightFrame) + LBAdapterHeight(20);
    [self.tipContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(LBAdapterHeight(20));
        make.right.mas_equalTo(self.mas_right).offset(LBAdapterHeight(-20));
        make.top.mas_equalTo(tipTop);
    }];

    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipContainerView.mas_top).offset(LBAdapterHeight(16));
        make.left.mas_equalTo(self.tipContainerView.mas_left).offset(LBAdapterHeight(16));
        make.height.mas_equalTo(LBAdapterHeight(22));
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stepLabel.mas_bottom).offset(LBAdapterHeight(8));
        make.left.mas_equalTo(self.stepLabel.mas_left);
        make.right.mas_equalTo(self.tipContainerView.mas_right).offset(LBAdapterHeight(-16));
        make.height.mas_equalTo(LBAdapterHeight(26));
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(LBAdapterHeight(6));
        make.left.right.mas_equalTo(self.titleLabel);
    }];

    [self.indicatorContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(LBAdapterHeight(16));
        make.left.mas_equalTo(self.stepLabel);
        make.height.mas_equalTo(LBAdapterHeight(8));
        make.width.mas_equalTo(LBAdapterHeight(48));
    }];

    [self.tryNowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.indicatorContainer.mas_bottom).offset(LBAdapterHeight(16));
        make.left.mas_equalTo(self.tipContainerView.mas_left).offset(LBAdapterHeight(16));
        make.width.mas_equalTo(LBAdapterHeight(120));
        make.height.mas_equalTo(LBAdapterHeight(40));
        make.bottom.mas_equalTo(self.tipContainerView.mas_bottom).offset(LBAdapterHeight(-16));
    }];

    [self.skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.tryNowButton);
        make.left.mas_equalTo(self.tryNowButton.mas_right).offset(LBAdapterHeight(12));
        make.width.mas_equalTo(LBAdapterHeight(60));
        make.height.mas_equalTo(LBAdapterHeight(40));
    }];

    CGFloat fingerX = CGRectGetMidX(self.highlightFrame) - LBAdapterHeight(15);
    CGFloat fingerY = CGRectGetMidY(self.highlightFrame) - LBAdapterHeight(15);
    [self.fingerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(40));
        make.left.mas_equalTo(fingerX);
        make.top.mas_equalTo(fingerY);
    }];
}

- (void)setupStepIndicators {
    CGFloat dotSize = LBAdapterHeight(8);
    CGFloat spacing = LBAdapterHeight(6);
    for (NSInteger i = 0; i < 3; i++) {
        UIView *dot = [[UIView alloc] init];
        dot.layer.cornerRadius = dotSize / 2.0;
        dot.tag = 100 + i;
        [self.indicatorContainer addSubview:dot];
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(dotSize);
            make.centerY.mas_equalTo(self.indicatorContainer);
            make.left.mas_equalTo((dotSize + spacing) * i);
        }];
    }
    [self updateIndicatorForStep:0];
}

- (void)updateIndicatorForStep:(NSInteger)step {
    for (NSInteger i = 0; i < 3; i++) {
        UIView *dot = [self.indicatorContainer viewWithTag:100 + i];
        if (i == step) {
            dot.backgroundColor = [UIColor LB_colorWithHex:0xff58C417];
        } else {
            dot.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        }
    }
}

#pragma mark - Content Updates

- (void)updateContentForStep:(NSInteger)step {
    self.currentStep = step;
    [self updateIndicatorForStep:step];

    switch (step) {
        case 0:
            self.stepLabel.text = @"Step 1/3";
            self.titleLabel.text = @"Tap to Open VPN";
            self.descLabel.text = @"Tap the VPN card on the homepage to enter the VPN feature and protect your network.";
            [self.tryNowButton setTitle:@"Next" forState:UIControlStateNormal];
            self.skipButton.hidden = NO;
            break;
        case 1:
            self.stepLabel.text = @"Step 2/3";
            self.titleLabel.text = @"One-Tap Connect";
            self.descLabel.text = @"Simply tap the connect button to establish a secure VPN connection instantly.";
            [self.tryNowButton setTitle:@"Next" forState:UIControlStateNormal];
            self.skipButton.hidden = NO;
            break;
        case 2:
            self.stepLabel.text = @"Step 3/3";
            self.titleLabel.text = @"Browse Safely";
            self.descLabel.text = @"Your network is now protected. Enjoy faster and safer browsing with VPN enabled!";
            [self.tryNowButton setTitle:@"Try VPN Now" forState:UIControlStateNormal];
            self.skipButton.hidden = YES;
            break;
        default:
            break;
    }
}

#pragma mark - Actions

- (void)tryNowClicked {
    if (self.currentStep < 2) {
        [self updateContentForStep:self.currentStep + 1];
        return;
    }

    [self dismissWithCompletion:^{
        if (self.completionBlock) {
            self.completionBlock(YES);
        }
    }];
}

- (void)skipClicked {
    [self dismissWithCompletion:^{
        if (self.completionBlock) {
            self.completionBlock(NO);
        }
    }];
}

#pragma mark - Animations

- (void)showWithAnimation {
    self.alpha = 0;
    self.fingerView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self startFingerAnimation];
    }];
}

- (void)startFingerAnimation {
    self.fingerView.alpha = 1.0;
    [UIView animateWithDuration:0.8
                          delay:0
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
        self.fingerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        self.fingerView.alpha = 0.7;
    } completion:nil];
}

- (void)dismissWithCompletion:(void(^)(void))completion {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Getters

- (UIView *)spotlightMaskView {
    if (!_spotlightMaskView) {
        _spotlightMaskView = [[UIView alloc] init];
        _spotlightMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    }
    return _spotlightMaskView;
}

- (UIView *)tipContainerView {
    if (!_tipContainerView) {
        _tipContainerView = [[UIView alloc] init];
        _tipContainerView.backgroundColor = [UIColor LB_colorWithHex:0xff1A1D1A];
        _tipContainerView.layer.cornerRadius = LBAdapterHeight(16);
        _tipContainerView.layer.borderWidth = 1.0;
        _tipContainerView.layer.borderColor = [UIColor LB_colorWithHex:0xff58C417].CGColor;
        _tipContainerView.clipsToBounds = YES;
    }
    return _tipContainerView;
}

- (UILabel *)stepLabel {
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] init];
        _stepLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(12) weight:UIFontWeightMedium];
        _stepLabel.textColor = [UIColor LB_colorWithHex:0xff58C417];
    }
    return _stepLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:LBAdapterHeight(18)];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(14)];
        _descLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _descLabel.numberOfLines = 0;
    }
    return _descLabel;
}

- (UIView *)indicatorContainer {
    if (!_indicatorContainer) {
        _indicatorContainer = [[UIView alloc] init];
    }
    return _indicatorContainer;
}

- (UIButton *)tryNowButton {
    if (!_tryNowButton) {
        _tryNowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tryNowButton.titleLabel.font = [UIFont boldSystemFontOfSize:LBAdapterHeight(14)];
        [_tryNowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        UIColor *startColor = [UIColor LB_colorWithHex:0xff98E468];
        UIColor *endColor = [UIColor LB_colorWithHex:0xff58C417];
        gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        gradientLayer.frame = CGRectMake(0, 0, LBAdapterHeight(120), LBAdapterHeight(40));
        [_tryNowButton.layer insertSublayer:gradientLayer atIndex:0];
        _tryNowButton.layer.cornerRadius = LBAdapterHeight(20);
        _tryNowButton.clipsToBounds = YES;
        [_tryNowButton addTarget:self action:@selector(tryNowClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tryNowButton;
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        _skipButton.titleLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(14)];
        [_skipButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skipClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

- (UIView *)fingerView {
    if (!_fingerView) {
        _fingerView = [[UIView alloc] init];

        UILabel *emoji = [[UILabel alloc] init];
        emoji.text = @"👆";
        emoji.font = [UIFont systemFontOfSize:LBAdapterHeight(28)];
        emoji.textAlignment = NSTextAlignmentCenter;
        [_fingerView addSubview:emoji];
        [emoji mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_fingerView);
        }];
    }
    return _fingerView;
}

@end
