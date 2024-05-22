//
//  LBNativeView.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/16.
//

#import "LBNativeView.h"
#import "LBGoogleADUtil.h"

@interface LBNativeView ()

@property (nonatomic, strong) UIImageView * placeholderView;
@property (nonatomic, strong) UIImageView * adView;
@property (nonatomic, strong) UIImageView * iconImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subTitleLabel;
@property (nonatomic, strong) UIButton * installLabel;
@property (nonatomic, strong) GADMediaView * videoView;
@property (nonatomic, strong) UIImageView * bigView;

@end

@implementation LBNativeView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    CGFloat nativeViewWidth = kLBDeviceWidth - 32 - 114;
    CGFloat nativeViewHeight = nativeViewWidth * 110.0 / 195.0;
    
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = true;
    
    [self addSubview:self.placeholderView];
    [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];

    [self addSubview:self.adView];
    [self.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self);
        make.width.equalTo(@18);
        make.height.equalTo(@12);
    }];

    [self addSubview:self.bigView];
    [self.bigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(14);
        make.left.equalTo(self).offset(10);
        make.width.equalTo(@(nativeViewWidth));
        make.height.equalTo(@(nativeViewHeight));
    }];

    [self addSubview:self.videoView];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.bigView);
    }];

    UIView *view = [[UIView alloc] init];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bigView.mas_right);
        make.right.equalTo(self);
        make.centerY.equalTo(self.bigView);
    }];

    [view addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.centerX.equalTo(view);
        make.width.height.equalTo(@36);
    }];

    [view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(6);
        make.width.equalTo(@100);
        make.centerX.equalTo(self.iconImageView);
    }];

    [view addSubview:self.installLabel];
    [self.installLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.iconImageView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
        make.width.equalTo(@64);
        make.height.equalTo(@28);
        make.bottom.equalTo(view);
    }];

    [self addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bigView.mas_bottom).offset(8);
        make.left.equalTo(self.bigView);
        make.right.equalTo(self).offset(-10);
    }];
}

- (void)configGADNativeAd:(GADNativeAd *)nativeAdModel {
    self.nativeAd = nativeAdModel;
    self.placeholderView.image = [UIImage imageNamed:@"bro_ad_placeholder"];
    UIColor * bgColor = [UIColor colorWithRed:50 / 255.0 green:51 / 255.0 blue:58 / 255.0 alpha:1];
    UIColor * subTitleColor = [UIColor whiteColor];
    UIColor * titleColor = [UIColor whiteColor];
    UIColor * installColor = [UIColor colorWithRed:255/255.0 green:236/255.0 blue:94/255.0 alpha:1.0];
    UIColor * installTitleColor = [UIColor colorWithRed:31/255.0 green:33/255.0 blue:51/255.0 alpha:1.0];
    
    self.backgroundColor = nativeAdModel == nil? [UIColor clearColor] : bgColor;
    self.adView.image = [UIImage imageNamed:@"bro_ad_tag"];
    self.installLabel.backgroundColor = installColor;
    [self.installLabel setTitleColor:installTitleColor forState:UIControlStateNormal];
    self.subTitleLabel.textColor = subTitleColor;
    self.titleLabel.textColor = titleColor;
    
    self.iconView = self.iconImageView;
    self.headlineView = self.titleLabel;
    self.bodyView = self.subTitleLabel;
    self.callToActionView = self.installLabel;
    self.imageView = self.bigView;
    self.mediaView = self.videoView;
    [self.installLabel setTitle:nativeAdModel.callToAction forState:UIControlStateNormal];
    self.iconImageView.image = nativeAdModel.icon.image;
    self.titleLabel.text = nativeAdModel.headline ? nativeAdModel.headline : @" ";
    self.subTitleLabel.text = nativeAdModel.body ? nativeAdModel.body : @" ";
    self.bigView.image = nativeAdModel.images.firstObject.image;
    self.videoView.mediaContent = nativeAdModel.mediaContent;
    [self hiddenSubViews:self.nativeAd == nil?YES:NO];
    self.videoView.hidden = nativeAdModel.mediaContent == nil;
    self.bigView.hidden = nativeAdModel.mediaContent != nil;
    
    if (!nativeAdModel) {
        self.videoView.hidden = true;
        self.bigView.hidden = true;
        self.placeholderView.hidden = false;
    }else {
        self.placeholderView.hidden = true;
    }
}

/// 根据 installOnlyTouch 控制点击区域
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([[LBGoogleADUtil shareInstance] installOnlyTouch]) {
        CGRect frameInTouch = [self.installLabel convertRect:self.installLabel.bounds toView:self];
        if (CGRectContainsPoint(frameInTouch, point)) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (void)hiddenSubViews:(BOOL)hidden {
    self.iconImageView.hidden = hidden;
    self.titleLabel.hidden = hidden;
    self.subTitleLabel.hidden = hidden;
    self.installLabel.hidden = hidden;
    self.bigView.hidden = hidden;
    self.videoView.hidden = hidden;
    self.adView.hidden = hidden;
}

#pragma mark - Getter

- (UIImageView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView = [[UIImageView alloc] init];
        _placeholderView.contentMode = UIViewContentModeScaleToFill;
        _placeholderView.layer.masksToBounds = YES;
    }
    return _placeholderView;
}

- (UIImageView *)adView {
    if (!_adView) {
        _adView = [[UIImageView alloc] init];
        _adView.image = [UIImage imageNamed:@"ad_tag"];
    }
    return _adView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor grayColor];
        _iconImageView.layer.cornerRadius = 2;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
        _subTitleLabel.textColor = [UIColor whiteColor];
        _subTitleLabel.numberOfLines = 2;
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _subTitleLabel;
}

- (UIButton *)installLabel {
    if (!_installLabel) {
        _installLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        _installLabel.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:236 / 255.0 blue:94 / 255.0 alpha:1.0];
        _installLabel.titleLabel.font = [UIFont systemFontOfSize:12];
        [_installLabel setTitleColor:[UIColor colorWithRed:31 / 255.0 green:35 / 255.0 blue:51 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        _installLabel.layer.cornerRadius = 14;
        _installLabel.layer.masksToBounds = YES;
    }
    return _installLabel;
}

- (GADMediaView *)videoView {
    if (!_videoView) {
        _videoView = [[GADMediaView alloc] init];
    }
    return _videoView;
}

- (UIImageView *)bigView {
    if (!_bigView) {
        _bigView = [[UIImageView alloc] init];
        _bigView.backgroundColor = [UIColor grayColor];
        _bigView.contentMode = UIViewContentModeScaleAspectFit;
        _bigView.layer.masksToBounds = YES;
    }
    return _bigView;
}

@end
