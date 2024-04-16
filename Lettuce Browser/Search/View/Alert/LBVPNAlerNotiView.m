//
//  LBVPNAlertView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import "LBVPNAlerNotiView.h"
#import "LBVpnViewController.h"

@interface LBVPNAlerNotiView ()

@property (nonatomic, strong) UIImageView * bgView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * descLabel;
@property (nonatomic, strong) UIButton * cancelButton;
@property (nonatomic, strong) UIButton * confirmButton;
@property (nonatomic, assign) NSInteger countTime;

@end

@implementation LBVPNAlerNotiView

+ (LBVPNAlerNotiView *)showWithSuperView:(UIView *)superView {
    LBVPNAlerNotiView * alertVM = [[LBVPNAlerNotiView alloc] init];
    alertVM.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    if (!superView) {
        [[UIApplication sharedApplication].windows.lastObject addSubview:alertVM];
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
    self.countTime = 3;
    self.frame = CGRectMake(0, 0, kLBDeviceWidth, kLBDeviceHeight);
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.descLabel];
    [self addSubview:self.cancelButton];
    [self addSubview:self.confirmButton];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(255));
        make.height.mas_equalTo(LBAdapterHeight(144));
        make.top.mas_equalTo(LBAdapterHeight(308));
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.bgView.mas_top).offset(LBAdapterHeight(20));
        make.height.mas_equalTo(LBAdapterHeight(24));
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(LBAdapterHeight(13));
        make.height.mas_equalTo(LBAdapterHeight(63));
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
    
    [self countDownText];
}


- (void)countDownText {
    if (self.countTime <= 0) {
        self.cancelButton.enabled = YES;
        [self.cancelButton setTitle:@"Skip" forState:UIControlStateNormal];
        return;
    }
    NSString * timeText = [[NSString stringWithFormat:@"Skip(%ld",(long)self.countTime] stringByAppendingString:@"s)"];
    [self.cancelButton setTitle:timeText forState:UIControlStateNormal];
    self.countTime --;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self countDownText];
    });
}

- (void)configmClicked:(UIButton *)sender {
    [self dismiss];
    LBVpnViewController * vpnVc = [[LBVpnViewController alloc] initWithNeedStartConnect:YES];
    vpnVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [[self jjc_getCurrentUIVC] presentViewController:vpnVc animated:YES completion:nil];
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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(16)];
        _titleLabel.textColor = [UIColor LB_colorWithHex:0xff242727];
        _titleLabel.text = @"Open Network Protection";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(14)];
        _descLabel.textColor = [UIColor LB_colorWithHex:0xff757A7A];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.text = @"Your network is unprotected,\n please open your network\n protection now.";
    }
    return _descLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor LB_colorWithHex:0xff232023];
        [_cancelButton setTitleColor:[UIColor LB_colorWithHex:0xffFFFFFF] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[[UIColor LB_colorWithHex:0xffFFFFFF] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        _cancelButton.layer.cornerRadius = LBAdapterHeight(20);
        [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.clipsToBounds = YES;
        _cancelButton.enabled = NO;
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
