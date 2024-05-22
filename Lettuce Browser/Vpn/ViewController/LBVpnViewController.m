//
//  LBVpnViewController.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import "LBVpnViewController.h"
#import "LBVpnSmartServerEntrenceVIew.h"
#import "LBVpnStatusView.h"
#import "LBNativeView.h"
#import "Lettuce_Browser-Swift.h"

@interface LBVpnViewController () <SmartServerEntrenceProtocol>

@property (nonatomic, strong)UIButton * backButton;
@property (nonatomic, strong)UIImageView * iconImgView;
@property (nonatomic, strong)LBVpnSmartServerEntrenceVIew * smartServerEntrenceView;
@property (nonatomic, strong)LBVpnStatusView * vpnStatusView;
@property (nonatomic, assign)BOOL isStartConnect;
@property (nonatomic, strong)LBNativeView * nativeADView;
@property (nonatomic, assign)BOOL isFirstLoad;
///已触发了返回按钮
@property (nonatomic, assign)BOOL isBackShow;

@end

@implementation LBVpnViewController

- (instancetype)initWithNeedStartConnect:(BOOL)isStartConnect {
    self = [super init];
    if (self) {
        self.isStartConnect = isStartConnect;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.smartServerEntrenceView updateCurrentVpnModel];
    if (self.isStartConnect) {
        self.isStartConnect = NO;
        [self.vpnStatusView clickEvent];
    }
    if ([CacheUtil objecGetUserGo] && !self.isBackShow && ![[LBADInterstitialManager shareInstance] getCurrentAdModel:LBADPositionBack]) {
        [[LBADInterstitialManager shareInstance] loadAd:LBADPositionBack];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isFirstLoad && !self.isBackShow) {
        [self updateNativeAd];
    }else {
        self.isFirstLoad = NO;
    }
    if (!self.isBackShow) {
        [LBTBALogManager objcLogEventWithName:@"pro_1" params:nil];
        [LBTBALogManager objcLogEventWithName:@"session_start" params:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstLoad = YES;
    self.isBackShow = NO;
    [self initializeAppearance];
}

- (void)initializeAppearance {
    self.view.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.iconImgView];
    [self.view addSubview:self.smartServerEntrenceView];
    [self.view addSubview:self.vpnStatusView];
    [self.view addSubview:self.nativeADView];
    
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
    
    CGFloat padding = 46;
    if (!kLBIsIphoneX) {
        padding = 30;
    }
    [self.vpnStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.smartServerEntrenceView.mas_bottom).offset(LBAdapterHeight(padding));
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(LBAdapterHeight(-236));
    }];
    
    CGFloat bottomPadding = -38;
    if (!kLBIsIphoneX) {
        bottomPadding = -30;
    }
    [self.nativeADView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(LBAdapterHeight(bottomPadding));
        make.left.mas_equalTo(self.view.mas_left).offset(LBAdapterHeight(20));
        make.right.mas_equalTo(self.view.mas_right).offset(LBAdapterHeight(-20));
    }];
    
    [self updateNativeAd];
}

- (void)updateNativeAd {
    if (self.vpnStatusView.isShowConnectAD) {
        NSLog(@"[AD], 正在展示插屏广告，不触发vpn首页广告刷新逻辑");
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[LBADNativeManager shareInstance] showNativeAd:LBADPositionHomeNative showLocation:LBADShowLocationVpnHomePage searchTabKey:nil showNativeBlock:^(GADNativeAd * _Nullable nativeAD) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.nativeADView configGADNativeAd:nativeAD];
    }];
}

- (void)backClicked:(UIButton *)sender {
    if (self.vpnStatusView.vpnStatus == LBVpnStateConnecting || self.vpnStatusView.vpnStatus == LBVpnStateDisconnecting) {
        return;
    }
    self.isBackShow = YES;
    [LBTBALogManager objcLogEventWithName:@"pro_homeback" params:nil];
    if ([CacheUtil objecGetUserGo]) {
        [LBADInterstitialManager shareInstance].ADDismissBlock = ^{
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        };
        [[LBADInterstitialManager shareInstance] showAd:LBADPositionBack];
    }else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
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

- (LBNativeView *)nativeADView {
    if (!_nativeADView) {
        _nativeADView = [[LBNativeView alloc] init];
        [_nativeADView configGADNativeAd:nil];
    }
    return _nativeADView;
}

@end
