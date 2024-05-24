//
//  LBVpnStatusView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import "LBVpnStatusView.h"
#import "LBSmartServerResultViewController.h"
#import "LBVpnModel.h"
#import "LBVpnInfoModel.h"
#import "Lettuce_Browser-Swift.h"

@interface LBVpnStatusView () <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView * statusBgVIew;
@property (nonatomic, strong) UIImageView * rotateView;
@property (nonatomic, strong) UILabel * notiLabel;
@property (nonatomic, strong) UILabel * timerLabel;
/// 连接中的进度条
@property (nonatomic, strong) UIProgressView * progressView;
/// 断开连接的进度条
@property (nonatomic, strong) UIProgressView * disConnectingProgressView;
@property (nonatomic, strong) UILabel * progressLabel;
@property (nonatomic, strong) UIButton * connectButton;
@property (nonatomic, strong) UIButton * clickButton;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat animationNumber;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, assign) BOOL isReConnect;
 
@end

@implementation LBVpnStatusView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeVpnKeepTimeObserver];
}

- (instancetype)initWithVpnStatus:(LBVpnStatus)status {
    self = [super init];
    if (self) {
        _vpnStatus = status;
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    [self addSubview:self.statusBgVIew];
    [self.statusBgVIew addSubview:self.rotateView];
    [self addSubview:self.connectButton];
    [self addSubview:self.notiLabel];
    [self addSubview:self.timerLabel];
    [self addSubview:self.progressView];
    [self addSubview:self.disConnectingProgressView];
    [self addSubview:self.progressLabel];
    [self addSubview:self.clickButton];
    
    [self.statusBgVIew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(275));
        make.height.mas_equalTo(LBAdapterHeight(240));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top);
    }];
    
    [self.connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.statusBgVIew);
    }];
    
    [self.rotateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.statusBgVIew.mas_top).offset(LBAdapterHeight(75));
        make.width.height.mas_equalTo(LBAdapterHeight(84));
        make.centerX.mas_equalTo(self.statusBgVIew.mas_centerX);
    }];
    
    [self.notiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(LBAdapterHeight(24));
        make.top.mas_equalTo(self.statusBgVIew.mas_bottom).offset(LBAdapterHeight(23));
    }];
    
    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(LBAdapterHeight(33));
        make.top.mas_equalTo(self.statusBgVIew.mas_bottom).offset(LBAdapterHeight(21));
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(247));
        make.height.mas_equalTo(LBAdapterHeight(52));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.statusBgVIew.mas_bottom).offset(LBAdapterHeight(80));
    }];
    
    [self.disConnectingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.progressView);
    }];
    
    [self.clickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(247));
        make.height.mas_equalTo(LBAdapterHeight(52));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.statusBgVIew.mas_bottom).offset(LBAdapterHeight(80));
    }];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.progressView.mas_centerX);
        make.centerY.mas_equalTo(self.progressView.mas_centerY);
        make.height.mas_equalTo(LBAdapterHeight(25));
    }];
    
    for (UIImageView * imageView in self.progressView.subviews) {
        imageView.layer.cornerRadius = LBAdapterHeight(26);
        imageView.clipsToBounds = YES;
    }
    for (UIImageView * imageView in self.disConnectingProgressView.subviews) {
        imageView.layer.cornerRadius = LBAdapterHeight(26);
        imageView.clipsToBounds = YES;
    }
    ///进度持续时间 固定 5秒
    self.animationNumber = 1.0/(10/0.1);
    [self updateUI:self.vpnStatus];
    [self addVpnKeepTimeObserver];
    [self addAppForwroundNotification];
}

- (void)addAppForwroundNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectVpn) name:kReconnectionVpnNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)reconnectVpn {
    self.isReConnect = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self clickEvent];
    });
}

- (void)applicationDidEnterBackground {
    if (self.vpnStatus == LBVpnStateConnecting) {
        [[LBVpnUtil shareInstance] stopVPN];
        [self updateUI:LBVpnStatusNormal];
    }
}

- (void)addVpnKeepTimeObserver {
    [[LBAppManagerCenter shareInstance] addObserver:self forKeyPath:@"vpnKeepTime" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeVpnKeepTimeObserver {
    [[LBAppManagerCenter shareInstance] removeObserver:self forKeyPath:@"vpnKeepTime"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(LBAppManagerCenter *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    self.timerLabel.text = [object formatTime:object.vpnKeepTime];
}

- (void)updateUI:(LBVpnStatus)status {
    self.vpnStatus = status;
    switch (self.vpnStatus) {
        case LBVpnStatusNormal:
            [self stopTimer];
            [self stopConnectAnimation];
            [[LBAppManagerCenter shareInstance] stopVpnKeepTime];
            self.clickButton.enabled = YES;
            self.connectButton.enabled = YES;
            self.progressView.hidden = NO;
            self.disConnectingProgressView.hidden = YES;
            self.notiLabel.hidden = NO;
            self.rotateView.hidden = YES;
            self.timerLabel.hidden = YES;
            self.progressLabel.text = @"Connect";
            self.progressView.progress = 1.0;
            self.statusBgVIew.image = [UIImage imageNamed:@"vpn_search_startbg"];
            break;
        case LBVpnStatusConnecting:
            self.timerLabel.hidden = YES;
            self.progressView.hidden = NO;
            self.clickButton.enabled = NO;
            self.connectButton.enabled = NO;
            self.disConnectingProgressView.hidden = YES;
            self.notiLabel.hidden = YES;
            self.rotateView.hidden = NO;
            self.statusBgVIew.image = [UIImage imageNamed:@"vpn_search_connectingbg"];
            self.progressView.progress = 0.0;
            [self startTimer];
            [self startConnectAnimation];
            [self startVpnConnect];
            break;
        case LBVpnStatusConnected:
            [[LBAppManagerCenter shareInstance] startVpnKeepTime];
            self.timerLabel.hidden = NO;
            self.clickButton.enabled = YES;
            self.connectButton.enabled = YES;
            self.progressView.hidden = YES;
            self.disConnectingProgressView.hidden = NO;
            self.disConnectingProgressView.progress = 1.0f;
            self.notiLabel.hidden = YES;
            self.rotateView.hidden = YES;
            [self stopConnectAnimation];
            self.timerLabel.hidden = NO;
            self.statusBgVIew.image = [UIImage imageNamed:@"vpn_searcj_connected"];
            self.progressLabel.text = @"Connected";
            break;
        case LBVpnStatusDisconnecting: {
            self.timerLabel.hidden = NO;
            self.progressView.hidden = YES;
            self.clickButton.enabled = NO;
            self.connectButton.enabled = NO;
            self.disConnectingProgressView.hidden = NO;
            self.disConnectingProgressView.progress = 0.0f;
            self.notiLabel.hidden = YES;
            self.rotateView.hidden = NO;
            self.timerLabel.hidden = NO;
            self.statusBgVIew.image = [UIImage imageNamed:@"vpn_search_disconnectingbg"];
            [self startTimer];
            [self startConnectAnimation];
            [[LBVpnUtil shareInstance] stopVPN];
        }
            break;
        case LBVpnStatusDisconnected:
           
            break;
        default:
            break;
    }
}

- (void)clickEvent {
    if (self.isProcessing) {
        return;
    }
    self.isProcessing = YES;
    if ([LBVpnUtil shareInstance].managerState != LBVpnManagerStateReady) {
        if (![[LBAppManagerCenter shareInstance] checkShowNetworkNotReachableToast]) {
            [LBTBALogManager objcLogEventWithName:@"pro_pm" params:nil];
            [[LBVpnUtil shareInstance] createWithCompletionHandler:^(NSError * _Nonnull error) {
                if (!error) {
                    [LBTBALogManager objcLogEventWithName:@"pro_pm2" params:nil];
                    [self clickHandle];
                }else {
                    [LBTBALogManager objcLogEventWithName:@"pro_pm1" params:nil];
                    [LBToast showMessage:@"Try it agin." duration:3 finishHandler:nil];
                    self.isProcessing = NO;
                }
            }];
        }else {
            self.isProcessing = NO;
        }
    }else {
        if (![[LBAppManagerCenter shareInstance] checkShowNetworkNotReachableToast]) {
            [self clickHandle];
        }else {
            self.isProcessing = NO;
        }
    }
}

- (void)clickHandle {
    switch (self.vpnStatus) {
        case LBVpnStatusNormal: {
            [[LBADNativeManager shareInstance] load:LBADPositionResultNative];
            [[LBADInterstitialManager shareInstance] loadAd:LBADPositionConnect];
            [self updateUI:LBVpnStatusConnecting];
        }
            break;
        case LBVpnStatusConnected:
            [[LBADNativeManager shareInstance] load:LBADPositionResultNative];
            [[LBADInterstitialManager shareInstance] loadAd:LBADPositionConnect];
            [self updateUI:LBVpnStatusDisconnecting];
            break;
        default:
            break;
    }
    self.isProcessing = NO;
}

- (void)jumpResultVc {
    self.isShowConnectAD = YES;
    __weak typeof(self) weakSelf = self;
    ///插屏广告退出，才跳转结果页
    [LBADInterstitialManager shareInstance].ADDismissBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        LBSmartType type = LBSmartTypeSuccessed;
        if (strongSelf.vpnStatus == LBVpnStatusDisconnecting || strongSelf.vpnStatus == LBVpnStatusNormal) {
            type = LBSmartTypeFailed;
        }
        LBSmartServerResultViewController *resultVC = [[LBSmartServerResultViewController alloc] initWithSmartType:type];
        resultVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[strongSelf jjc_getCurrentUIVC] presentViewController:resultVC animated:YES completion:^{
            strongSelf.isShowConnectAD = false;
        }];
    };
    [[LBADInterstitialManager shareInstance] showAd:LBADPositionConnect];
}

#pragma mark - Timer

- (void)startTimer {
    self.progress = 0.0f;
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_WALLTIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self updateProgressValue];
    });
    dispatch_resume(timer);
    self.timer = timer;
}

- (void)startVpnConnect {
//    LBVpnModel * testModel = [[LBVpnModel alloc] init];
//    testModel.iconName = @"United States";
//    LBVpnInfoModel * infoModel = [[LBVpnInfoModel alloc] init];
//    infoModel.serverIP = @"104.237.128.93";
//    infoModel.serverPort = @"1543";
//    infoModel.password = @"K49qpWT_sU8ML1+m";
//    infoModel.method = @"chacha20-ietf-poly1305";
//    testModel.vpnInfo = infoModel;
    
    [LBVpnUtil.shareInstance connectWithServer:[LBAppManagerCenter shareInstance].currentVpnModel];
}

- (void)updateProgressValue {
    self.progress += self.animationNumber;
    if (self.vpnStatus == LBVpnStatusConnecting) {
        self.progressView.progress = self.progress;
    }else {
        self.disConnectingProgressView.progress = self.progress;
    }
    if (self.progress >= 1.0f) {
        self.progressView.progress = 1.0f;
        self.progress = 1.0f;
        [self stopTimer];
        if (self.vpnStatus == LBVpnStatusConnecting) {
            ///动画完成时，检查一下vpn的连接状态
            if ([LBVpnUtil shareInstance].isActiveConnect && [LBVpnUtil shareInstance].vpnState == LBVpnStateError) {
                [self updateUI:LBVpnStatusNormal];
                [LBToast showMessage:@"Try it agin." duration:2.8 finishHandler:nil];
                return;
            }
            [self jumpResultVc];
            [self updateUI:LBVpnStatusConnected];
        }else {
            if (self.isReConnect) {
                self.isReConnect = NO;
                [self updateUI:LBVpnStatusNormal];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self clickEvent];
                });
            }else {
                [self jumpResultVc];
                [self updateUI:LBVpnStatusNormal];
            }
        }
    }else {
        NSInteger number = self.progress * 100;
        if (self.vpnStatus == LBVpnStatusConnecting) {
            self.progressLabel.text = [[NSString stringWithFormat:@"Connecting…%ld",(long)number] stringByAppendingString:@"%"];
        }else {
            self.progressLabel.text = [[NSString stringWithFormat:@"Disconnecting…%ld",(long)number] stringByAppendingString:@"%"];
        }
    }
}

-(void)stopTimer{
    if(self.timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)startConnectAnimation {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.delegate = self;
    
    [self.rotateView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopConnectAnimation {
    [self.rotateView.layer removeAnimationForKey:@"rotationAnimation"];
}

#pragma mark - Getter

- (UIImageView *)statusBgVIew {
    if (!_statusBgVIew) {
        _statusBgVIew = [[UIImageView alloc] init];
    }
    return _statusBgVIew;
}


- (UIImageView *)rotateView {
    if (!_rotateView) {
        _rotateView = [[UIImageView alloc] init];
        _rotateView.image = [UIImage imageNamed:@"vpn_search_rotate"];
    }
    return _rotateView;
}

- (UILabel *)notiLabel {
    if (!_notiLabel) {
        _notiLabel = [[UILabel alloc] init];
        _notiLabel.text = @"Tap any button to connect";
        _notiLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(18)];
        _notiLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    return _notiLabel;
}

- (UILabel *)timerLabel {
    if (!_timerLabel) {
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.textAlignment = NSTextAlignmentCenter;
        _timerLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(24)];
        _timerLabel.textColor = [UIColor whiteColor];
        _timerLabel.text = @"00:00:00";
    }
    return _timerLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
//        _progressView.progressImage = [UIImage imageNamed:@"vpn_search_grad"];
        _progressView.layer.cornerRadius = LBAdapterHeight(26);
        _progressView.trackTintColor = [UIColor LB_colorWithHex:0xff405733];
//        _progressView.progressTintColor = [UIColor LB_colorWithHex:0xff58C417];
        _progressView.progressImage = [UIImage imageNamed:@"vpn_search_progressBg"];
        _progressView.clipsToBounds = YES;
    }
    return _progressView;
}

- (UIProgressView *)disConnectingProgressView {
    if (!_disConnectingProgressView) {
        _disConnectingProgressView = [[UIProgressView alloc] init];
        _disConnectingProgressView.layer.cornerRadius = LBAdapterHeight(26);
        _disConnectingProgressView.trackTintColor = [UIColor LB_colorWithHex:0xff573F33];
//        _disConnectingProgressView.progressTintColor = [UIColor LB_colorWithHex:0xffE47E0A];
        _disConnectingProgressView.progressImage = [UIImage imageNamed:@"vpn_search_disprogressBg"];
        _disConnectingProgressView.clipsToBounds = YES;
    }
    return _disConnectingProgressView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(18)];
    }
    return _progressLabel;
}

- (UIButton *)clickButton {
    if (!_clickButton) {
        _clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _clickButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f];
        [_clickButton addTarget:self action:@selector(clickEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clickButton;
}

- (UIButton *)connectButton {
    if (!_connectButton) {
        _connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _connectButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f];
        [_connectButton addTarget:self action:@selector(clickEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectButton;
}

@end
