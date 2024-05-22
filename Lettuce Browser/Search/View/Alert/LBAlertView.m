//
//  LBAlertView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/7.
//

#import "LBAlertView.h"
#import "LBCleanView.h"

@interface LBAlertView ()

@property (nonatomic, strong) UIImageView * bgView;
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UIButton * cancelButton;
@property (nonatomic, strong) UIButton * confirmButton;

@end

@implementation LBAlertView

+ (LBAlertView *)showWithSuperView:(UIView *)superView {
    LBAlertView * alertVM = [[LBAlertView alloc] init];
    alertVM.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    if (!superView) {
        [[UIApplication sharedApplication].windows.firstObject addSubview:alertVM];
    }else {
        [superView addSubview:alertVM];
    }
    return alertVM;
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
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.iconView];
    [self.bgView addSubview:self.titleLabel];
    [self addSubview:self.cancelButton];
    [self addSubview:self.confirmButton];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(255));
        make.height.mas_equalTo(LBAdapterHeight(144));
        make.top.mas_equalTo(LBAdapterHeight(308));
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(LBAdapterHeight(24));
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.width.mas_equalTo(LBAdapterHeight(70));
        make.height.mas_equalTo(LBAdapterHeight(102));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(LBAdapterHeight(20));
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.width.mas_equalTo(LBAdapterHeight(114));
        make.height.mas_equalTo(LBAdapterHeight(84));
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterWidth(103));
        make.height.mas_equalTo(LBAdapterHeight(40));
        make.left.mas_equalTo(self.bgView.mas_left);
        make.top.mas_equalTo(self.bgView.mas_bottom).offset(LBAdapterHeight(12));
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(140));
        make.height.mas_equalTo(LBAdapterHeight(40));
        make.left.mas_equalTo(self.cancelButton.mas_right).offset(LBAdapterHeight(12));
        make.top.mas_equalTo(self.bgView.mas_bottom).offset(LBAdapterHeight(12));
    }];
}

- (void)configmClicked:(UIButton *)sender {
    [self dismiss];
    [LBCleanView showCleanLoadingWithSuperView:nil];
}

- (void)dismiss {
    [self removeFromSuperview];
}

#pragma mark - Getter

- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        _bgView.image = [UIImage imageNamed:@"home_clean_alertbg"];
        _bgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bgView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage imageNamed:@"home_clean_alerticon"];
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"Close Tabs \nand Clear Data";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(16)];
        _titleLabel.textColor = [UIColor LB_colorWithHex:0xff242727];
    }
    return _titleLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor LB_colorWithHex:0xff232023];
        [_cancelButton setTitleColor:[UIColor LB_colorWithHex:0xffFFFFFF] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        _cancelButton.layer.cornerRadius = LBAdapterHeight(20);
        [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.clipsToBounds = YES;
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        UIColor * startColor = [UIColor LB_colorWithHex:0xff98E468];
        UIColor * endColor = [UIColor LB_colorWithHex:0xff58C417];
        gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        gradientLayer.frame = CGRectMake(0, 0, LBAdapterHeight(140), LBAdapterHeight(40));
        [_confirmButton.layer addSublayer:gradientLayer];
        _confirmButton.layer.cornerRadius = LBAdapterHeight(20);
        _confirmButton.clipsToBounds = YES;
        [_confirmButton addTarget:self action:@selector(configmClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
