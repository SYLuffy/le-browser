//
//  LBSmartServerCollectionViewCell.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import "LBSmartServerCollectionViewCell.h"
#import "LBVpnModel.h"

@interface LBSmartServerCollectionViewCell ()

@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation LBSmartServerCollectionViewCell

+ (NSString *)identifier {
    return @"LBSmartServerCollectionViewCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    self.contentView.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
    
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.iconView];
    [self.bgView addSubview:self.titleLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView.mas_right).offset(LBAdapterHeight(-19));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(LBAdapterHeight(-24));
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(28));
        make.centerX.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.bgView.mas_top).offset(LBAdapterHeight(16));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconView.mas_bottom).offset(LBAdapterHeight(16));
        make.left.right.mas_equalTo(self.bgView);
        make.height.mas_equalTo(LBAdapterHeight(21));
    }];
}

- (void)loadServerModel:(LBVpnModel *)model {
    self.model = model;
    self.titleLabel.text = model.titleName;
    self.iconView.image = [UIImage imageNamed:model.iconName];
}

#pragma mark - Getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = LBAdapterHeight(16);
        _bgView.clipsToBounds = YES;
        _bgView.backgroundColor = [UIColor LB_colorWithHex:0xff272727];
    }
    return _bgView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(15)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
