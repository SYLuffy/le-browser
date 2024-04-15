//
//  LBSettingListTableViewCell.m
//  Lettuce Browser
//
//  Created by jojo on 2024/4/5.
//

#import "LBSettingListTableViewCell.h"
#import "LBSettingListModel.h"

@interface LBSettingListTableViewCell ()

@property (nonatomic, strong) UIImageView * iconImgView;
@property (nonatomic, strong) UILabel * titlLabel;
@property (nonatomic, strong) UIImageView * arrowView;

@end

@implementation LBSettingListTableViewCell

+ (NSString *)identifier {
    return @"LBSettingListTableViewCell1";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    self.contentView.backgroundColor = [UIColor LB_colorWithHex:0xff222227];
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.titlLabel];
    [self.contentView addSubview:self.arrowView];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(24));
        make.left.mas_equalTo(self.contentView.mas_left).offset(LBAdapterHeight(14));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
    [self.titlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImgView.mas_right).offset(LBAdapterHeight(24));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(LBAdapterHeight(17));
        make.right.mas_equalTo(self.contentView.mas_right);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(LBAdapterHeight(-16));
        make.width.height.mas_equalTo(LBAdapterHeight(16));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
}

- (void)loadModel:(LBSettingListModel *)model {
    self.iconImgView.image = [UIImage imageNamed:model.iconName];
    self.titlLabel.text = model.titleName;
}

#pragma mark - Getter

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
    }
    return _iconImgView;
}

- (UILabel *)titlLabel {
    if (!_titlLabel) {
        _titlLabel = [[UILabel alloc] init];
        _titlLabel.textColor = [UIColor whiteColor];
        _titlLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titlLabel;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.image = [UIImage imageNamed:@"home_setting_arrow"];
    }
    return _arrowView;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

@end
