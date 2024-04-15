//
//  JJAAppraisalProgressView.m
//  Anibook-iOS
//
//  Created by jojo on 2022/3/8.
//

#import "LBBootProgressView.h"

@interface LBBootProgressView ()

@property (nonatomic, strong) UIProgressView * progressView;
@property (nonatomic, strong) UILabel * proLabel;

@end

@implementation LBBootProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    [self addSubview:self.progressView];
    [self addSubview:self.proLabel];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(LBAdapterHeight(10));
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    [self.proLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.progressView.mas_top).offset(LBAdapterHeight(-7));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(LBAdapterHeight(13));
    }];
}

- (void)configProgressValue:(CGFloat)value {
    self.progressView.progress = value;
    NSInteger number = value * 100;
    self.proLabel.text = [[NSString stringWithFormat:@"loading...%ld",number] stringByAppendingString:@"%"];
}

#pragma mark - Getter

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = [UIColor LB_colorWithHex:0xff3D4341];
        _progressView.progressTintColor = [UIColor whiteColor];
        _progressView.progress = 0.0;
    }
    return _progressView;
}

- (UILabel *)proLabel {
    if (!_proLabel) {
        _proLabel = [[UILabel alloc] init];
        _proLabel.text = @"";
        _proLabel.textColor = [UIColor whiteColor];
        _proLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(12)];
    }
    return _proLabel;
}

@end
