//
//  LBVpnViewController.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import "LBVpnViewController.h"
#import "LBVpnSmartServerEntrenceVIew.h"
#import "LBVpnStatusView.h"

@interface LBVpnViewController () <SmartServerEntrenceProtocol>

@property (nonatomic, strong)UIButton * backButton;
@property (nonatomic, strong)UIImageView * iconImgView;
@property (nonatomic, strong)LBVpnSmartServerEntrenceVIew * smartServerEntrenceView;
@property (nonatomic, strong)LBVpnStatusView * vpnStatusView;

@end

@implementation LBVpnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeAppearance];
}

- (void)initializeAppearance {
    self.view.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.iconImgView];
    [self.view addSubview:self.smartServerEntrenceView];
    [self.view addSubview:self.vpnStatusView];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(20));
        make.top.mas_equalTo(self.view.mas_top).offset(LBAdapterHeight(66));
        make.left.mas_equalTo(LBAdapterHeight(20));
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(32));
        make.height.mas_equalTo(LBAdapterHeight(11));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
    }];
    
    [self.smartServerEntrenceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(LBAdapterHeight(303));
        make.height.mas_equalTo(LBAdapterHeight(48));
        make.top.mas_equalTo(self.iconImgView.mas_bottom).offset(LBAdapterHeight(34));
    }];
    
    [self.vpnStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.smartServerEntrenceView.mas_bottom).offset(LBAdapterHeight(46));
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(LBAdapterHeight(-236));
    }];
}

- (void)backClicked:(UIButton *)sender {
    if (self.vpnStatusView.vpnStatus == LBVpnStateConnecting || self.vpnStatusView.vpnStatus == LBVpnStateDisconnecting) {
        return;
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)vpnDisconnected {
    [self.vpnStatusView updateUI:LBVpnStatusNormal];
}

#pragma mark - SmartServerEntrenceProtocol
- (BOOL)isEnableEnter {
    return self.vpnStatusView.vpnStatus != LBVpnStatusConnecting && self.vpnStatusView.vpnStatus != LBVpnStatusDisconnecting;
}

#pragma mark - Getter
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"home_user_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.image = [UIImage imageNamed:@"vpn_search_icon"];
    }
    return _iconImgView;
}

- (LBVpnSmartServerEntrenceVIew *)smartServerEntrenceView {
    if (!_smartServerEntrenceView) {
        _smartServerEntrenceView = [[LBVpnSmartServerEntrenceVIew alloc] init];
        _smartServerEntrenceView.delegate = self;
    }
    return _smartServerEntrenceView;
}

- (LBVpnStatusView *)vpnStatusView {
    if (!_vpnStatusView) {
        
        _vpnStatusView = [[LBVpnStatusView alloc] initWithVpnStatus:[LBVpnUtil shareInstance].vpnState == LBVpnStateConnected?LBVpnStatusConnected:LBVpnStatusNormal];
    }
    return _vpnStatusView;
}

@end
