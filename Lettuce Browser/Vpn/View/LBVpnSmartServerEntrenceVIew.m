//
//  LBVpnSmartServerEntrenceVIew.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import "LBVpnSmartServerEntrenceVIew.h"
#import "LBSmartServerViewController.h"
#import "LBVpnModel.h"

@interface LBVpnSmartServerEntrenceVIew ()

@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImgView;

@end

@implementation LBVpnSmartServerEntrenceVIew

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self addGestureRecognizer:tapGesture];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.iconView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.arrowImgView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(28));
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(LBAdapterHeight(20));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(LBAdapterHeight(12));
        make.right.mas_equalTo(self.mas_right).offset(LBAdapterHeight(-40));
        make.height.mas_equalTo(LBAdapterHeight(15));
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(LBAdapterHeight(-20));
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(LBAdapterHeight(20));
    }];
}

- (void)tapClick {
    if ([self.delegate respondsToSelector:@selector(isEnableEnter)]) {
        if ([self.delegate isEnableEnter]) {
            LBSmartServerViewController * ssVC = [[LBSmartServerViewController alloc] init];
            ssVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [[self jjc_getCurrentUIVC] presentViewController:ssVC animated:YES completion:nil];
        }
    }
}

- (void)updateCurrentVpnModel {
    self.iconView.image = [UIImage imageNamed:[LBAppManagerCenter shareInstance].currentVpnModel.iconName];
    self.titleLabel.text = [LBAppManagerCenter shareInstance].currentVpnModel.titleName;
}

#pragma mark - Getter

- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        _bgView.image = [UIImage imageNamed:@"vpn_smartserver_entrencebg"];
    }
    return _bgView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage imageNamed:@"vpn_smartserver_entrencicon"];
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor LB_colorWithHex:0xff525050];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.text = @"Smart Server";
    }
    return _titleLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = [UIImage imageNamed:@"vpn_smartserver_entrencarrow"];
    }
    return _arrowImgView;
}

@end
