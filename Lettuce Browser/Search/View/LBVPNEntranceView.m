//
//  LBVPNEntranceView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import "LBVPNEntranceView.h"
#import "LBVpnViewController.h"

@interface LBVPNEntranceView ()

@property (nonatomic, strong) UIImageView * bgView;
@property (nonatomic, strong) UIImageView * rightArrowView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * descLabel;

@end

@implementation LBVPNEntranceView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vpnClicked)];
    [self addGestureRecognizer:tapGestureRecognizer];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.rightArrowView];
    [self.bgView addSubview:self.descLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top).offset(LBAdapterHeight(19));
        make.right.mas_equalTo(self.bgView.mas_right);
        make.left.mas_equalTo(self.bgView.mas_left).offset(LBAdapterHeight(108));
        make.height.mas_equalTo(LBAdapterHeight(24));
    }];
    
    [self.rightArrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(48));
        make.height.mas_equalTo(LBAdapterHeight(22));
        make.right.mas_equalTo(self.bgView.mas_right).offset(LBAdapterHeight(-12));
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(LBAdapterHeight(13));
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(LBAdapterHeight(15));
        make.height.mas_equalTo(LBAdapterHeight(19));
        make.left.mas_equalTo(self.bgView.mas_left).offset(LBAdapterHeight(108));
        make.right.mas_equalTo(self.bgView.mas_right);
    }];
}

- (void)vpnClicked {
    LBVpnViewController * vpnVC = [LBVpnViewController new];
    vpnVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [[self jjc_getCurrentUIVC] presentViewController:vpnVC animated:YES completion:nil];
}

#pragma mark - Getter
- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        _bgView.image = [UIImage imageNamed:@"vpn_search_entrance"];
    }
    return _bgView;
}

- (UIImageView *)rightArrowView {
    if (!_rightArrowView) {
        _rightArrowView = [[UIImageView alloc] init];
        _rightArrowView.image = [UIImage imageNamed:@"vpn_search_arrow"];
    }
    return _rightArrowView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(20)];
        _titleLabel.text = @"Improve Network Speed";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"VPN function";
        _descLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(16)];
        _descLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _descLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _descLabel;
}

@end
