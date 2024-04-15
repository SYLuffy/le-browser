//
//  LBBootLoadingView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import "LBBootLoadingView.h"
#import "LBBootProgressView.h"
#import "LBVPNAlerNotiView.h"
#import "LBSmartServerResultViewController.h"
#import "LBVpnViewController.h"

@interface LBBootLoadingView ()

@property (nonatomic, strong) UIImageView * logoImgView;
@property (nonatomic, strong) UIImageView * titleImgView;
@property (nonatomic, strong) LBBootProgressView * progressView;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat animationNumber;
@property (nonatomic, assign) LBLoadingMode loadingMode;

@end

@implementation LBBootLoadingView

+ (LBBootLoadingView *)showLoadingMode:(LBLoadingMode)loadingMode superView:(UIView *)superView {
    LBBootLoadingView * loadingView = LBAppManagerCenter.shareInstance.globalLoadingView;
    if (!loadingView) {
        loadingView = [[LBBootLoadingView alloc] initWithFrame:CGRectMake(0, 0, kLBDeviceWidth, kLBDeviceHeight) loadingMode:loadingMode];
        loadingView.tag = 1993;
        if (!superView) {
            [[UIApplication sharedApplication].windows.lastObject addSubview:loadingView];
        }else {
            [superView addSubview:loadingView];
        }
        LBAppManagerCenter.shareInstance.globalLoadingView = loadingView;
    }
    return loadingView;
}

- (instancetype)initWithFrame:(CGRect)frame loadingMode:(LBLoadingMode)loadingMode {
    self = [super initWithFrame:frame];
    if (self) {
        NSInteger animationTime = 3;
        if (loadingMode == LBLoadingModeColdBoot) {
            ///冷启动 动画展示秒数随机
            animationTime = arc4random() % 10 + 3;
        }
        self.loadingMode = loadingMode;
        self.animationNumber = 1.0/(animationTime/0.1);
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    self.backgroundColor = [UIColor LB_colorWithHex:0xff030b08];
    
    [self addSubview:self.logoImgView];
    [self addSubview:self.titleImgView];
    [self addSubview:self.progressView];
    
    [self addConstraint];
    [self startTimer];
}

- (void)addConstraint {
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).mas_equalTo(LBAdapterHeight(44));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(LBAdapterHeight(335));
        make.height.mas_equalTo(LBAdapterHeight(255));
    }];
    
    [self.titleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(181));
        make.height.mas_equalTo(LBAdapterHeight(17));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.logoImgView.mas_bottom).offset(LBAdapterHeight(16));
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(LBAdapterHeight(-34));
        make.height.mas_equalTo(LBAdapterHeight(37));
    }];
}

#pragma mark - Timer

- (void)startTimer {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self updateProgressValue];
    });
    dispatch_resume(timer);
    self.timer = timer;
}

- (void)updateProgressValue {
    self.progress += self.animationNumber;
    [self.progressView configProgressValue:self.progress];
    if (self.progress >= 1.0f) {
        [self.progressView configProgressValue:1.0];
        [self stopTimer];
    }
}

-(void)stopTimer{
    if(self.timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    [self stopLoading];
}

- (void)stopLoading {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0.0;
    }completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        if (weakSelf.loadingMode == LBLoadingModeColdBoot) {
            [LBVPNAlerNotiView showWithSuperView:nil];
            }else {
                if ([LBVpnUtil shareInstance].vpnState != LBVpnStateConnected) {
                    if ([LBAppManagerCenter shareInstance].isShowDisconnectedVC) {
                        [LBAppManagerCenter shareInstance].isShowDisconnectedVC = NO;
                        UIViewController * topVc = [self jjc_getCurrentUIVC];
                        if ([topVc isKindOfClass:[LBVpnViewController class]]) {
                            [((LBVpnViewController *)topVc) vpnDisconnected];
                            LBSmartServerResultViewController * resultVC = [[LBSmartServerResultViewController alloc] initWithSmartType:LBSmartTypeFailed];
                            resultVC.modalPresentationStyle = UIModalPresentationFullScreen;
                            [topVc presentViewController:resultVC animated:YES completion:nil];
                        }
                }
            }
//            ///主页自动显示权限弹窗
//            if ([LBVpnUtil shareInstance].managerState != LBVpnManagerStateReady) {
//                [[LBVpnUtil shareInstance] createWithCompletionHandler:^(NSError * _Nonnull error) {
//                    
//                }];
//            }
        }
    }];
}

#pragma mark - Gtter

- (UIImageView *)logoImgView {
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start"]];
    }
    return _logoImgView;
}

- (UIImageView *)titleImgView {
    if (!_titleImgView) {
        _titleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Lettuce Browser"]];
    }
    return _titleImgView;
}

- (LBBootProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[LBBootProgressView alloc] init];
    }
    return _progressView;
}

@end
