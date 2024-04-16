//
//  LBSmartServerResultViewController.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import "LBSmartServerResultViewController.h"

@interface LBSmartServerResultViewController ()

@property (nonatomic, strong)UIButton * backButton;
@property (nonatomic, strong)UIImageView * iconImgView;
@property (nonatomic, assign)LBSmartType smartType;
@property (nonatomic, strong)UIImageView * typeImgView;
@property (nonatomic, strong)UILabel * textLabel;
@property (nonatomic, strong)UILabel * timeLabel;

@end

@implementation LBSmartServerResultViewController

- (void)dealloc {
    [self removeVpnKeepTimeObserver];
}

- (instancetype)initWithSmartType:(LBSmartType)smartType {
    self = [super init];
    if (self) {
        self.smartType = smartType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self initializeAppearance];
}

- (void)initializeAppearance {
    self.view.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.iconImgView];
    [self.view addSubview:self.typeImgView];
    [self.view addSubview:self.textLabel];
    [self.view addSubview:self.timeLabel];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(20));
        make.top.mas_equalTo(self.view.mas_top).offset(LBAdapterHeight(66));
        make.left.mas_equalTo(LBAdapterHeight(20));
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(129));
        make.height.mas_equalTo(LBAdapterHeight(15));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
    }];
    
    [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(175));
        make.height.mas_equalTo(LBAdapterHeight(157));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.iconImgView.mas_bottom).offset(LBAdapterHeight(64));
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.typeImgView.mas_bottom).offset(LBAdapterHeight(48));
        make.height.mas_equalTo(LBAdapterHeight(24));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(LBAdapterHeight(30));
        make.top.mas_equalTo(self.textLabel.mas_bottom).offset(LBAdapterHeight(19));
    }];
    
    [self updatePageMode];
    [self addVpnKeepTimeObserver];
}

- (void)addVpnKeepTimeObserver {
    [[LBAppManagerCenter shareInstance] addObserver:self forKeyPath:@"vpnKeepTime" options:NSKeyValueObservingOptionNew context:nil];
    if (self.smartType == LBSmartTypeFailed) {
        self.timeLabel.text = [[LBAppManagerCenter shareInstance] formatTime:[LBAppManagerCenter shareInstance].lastVpnKeepTime];
    }
}

- (void)removeVpnKeepTimeObserver {
    [[LBAppManagerCenter shareInstance] removeObserver:self forKeyPath:@"vpnKeepTime"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(LBAppManagerCenter *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.smartType == LBSmartTypeSuccessed) {
        self.timeLabel.text = [object formatTime:object.vpnKeepTime];
    }
}


- (void)updatePageMode {
    NSInteger time = [LBAppManagerCenter shareInstance].vpnKeepTime;
    if (time > 0) {
        self.timeLabel.text = [[LBAppManagerCenter shareInstance] formatTime:time];
    }
    switch (self.smartType) {
        case LBSmartTypeSuccessed:
            self.textLabel.text = @"Connected Successfully";
            self.typeImgView.image = [UIImage imageNamed:@"vpn_smartserver_reportssucess"];
            break;
        case LBSmartTypeFailed:
            self.textLabel.text = @"VPN Disconnected";
            self.typeImgView.image = [UIImage imageNamed:@"vpn_smartserver_reportfailed"];
            break;
        default:
            break;
    }
}

- (void)backClicked:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
        _iconImgView.image = [UIImage imageNamed:@"vpn_smartserver_reporticon"];
    }
    return _iconImgView;
}

- (UIImageView *)typeImgView {
    if (!_typeImgView) {
        _typeImgView = [[UIImageView alloc] init];
    }
    return _typeImgView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(20)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(26)];
        _timeLabel.text = @"00:00:00";
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

@end
