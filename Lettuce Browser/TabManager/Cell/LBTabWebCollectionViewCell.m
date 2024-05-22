//
//  LBTabWebCollectionViewCell.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/7.
//

#import "LBTabWebCollectionViewCell.h"

@interface LBTabWebCollectionViewCell ()

@property (nonatomic, strong)UIImageView * coverImgView;
@property (nonatomic, strong)UIImageView * selectedImgView;
@property (nonatomic, strong)UIButton * closeButton;

@end

@implementation LBTabWebCollectionViewCell

+ (NSString *)identifier {
    return @"LBTabWebCollectionViewCell";
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
    
    self.coverImgView.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
    
    [self.contentView addSubview:self.coverImgView];
    [self.contentView addSubview:self.closeButton];
    [self.coverImgView addSubview:self.selectedImgView];
    
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(LBAdapterHeight(-16));
        make.left.mas_equalTo(self.contentView.mas_left).offset(LBAdapterHeight(16));
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(16));
        make.top.mas_equalTo(self.contentView.mas_top).offset(LBAdapterHeight(8));
        make.right.mas_equalTo(self.contentView.mas_right).offset(LBAdapterHeight(-8));
    }];
    
    [self.selectedImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(LBAdapterHeight(20));
        make.left.right.bottom.mas_equalTo(self.coverImgView);
    }];
}

- (void)loadTabModel:(LBWebPageTabModel *)model selectedKey:(nonnull NSDate *)selectedKey{
    self.model = model;
    if (model.screenShot) {
        self.coverImgView.image = model.screenShot;
    }
    if ([model.tabKey isEqual:selectedKey]) {
        self.selectedImgView.hidden = NO;
    }else {
        self.selectedImgView.hidden = YES;
    }
}

- (void)hiddenClose {
    self.closeButton.hidden = YES;
}

- (void)closeClicked:(UIButton *)sender {
    [[LBWebPageTabManager shareInstance] removeWebTabfor:self.model];
}

- (UIColor *)randomColor {
    CGFloat red = (CGFloat)arc4random_uniform(256) / 255.0;
    CGFloat green = (CGFloat)arc4random_uniform(256) / 255.0;
    CGFloat blue = (CGFloat)arc4random_uniform(256) / 255.0;
    CGFloat alpha = 1.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - Getter

- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.layer.cornerRadius = LBAdapterHeight(8);
        _coverImgView.clipsToBounds = YES;
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverImgView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"home_webtab_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIImageView *)selectedImgView {
    if (!_selectedImgView) {
        _selectedImgView = [[UIImageView alloc] init];
        _selectedImgView.image = [UIImage imageNamed:@"home_webtab_selected"];
        _selectedImgView.hidden = YES;
    }
    return _selectedImgView;
}

@end
