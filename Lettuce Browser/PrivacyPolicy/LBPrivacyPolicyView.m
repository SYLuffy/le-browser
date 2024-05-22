//
//  LBPrivacyPolicyViewController.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/7.
//

#import "LBPrivacyPolicyView.h"
#import "Lettuce_Browser-Swift.h"

@interface LBPrivacyPolicyView ()

@property (nonatomic, strong)UIButton * backButton;
@property (nonatomic, strong)UIImageView * iconImgView;
@property (nonatomic, strong)UITextView * contentView;

@end

@implementation LBPrivacyPolicyView

+ (LBPrivacyPolicyView *)popShowWithSuperView:(nullable UIView *)superView {
    LBPrivacyPolicyView * popView = [[LBPrivacyPolicyView alloc] init];
    popView.frame = CGRectMake(0, 0, kLBDeviceWidth, kLBDeviceHeight);
    if (!superView) {
        [[UIApplication sharedApplication].windows.firstObject addSubview:popView];
    }else {
        [superView addSubview:popView];
    }
    [LBTBALogManager objcLogEventWithName:@"session_start" params:nil];
    return popView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    self.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
    [self addSubview:self.backButton];
    [self addSubview:self.iconImgView];
    [self addSubview:self.contentView];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(20));
        make.top.mas_equalTo(self.mas_top).offset(LBAdapterHeight(66));
        make.left.mas_equalTo(LBAdapterHeight(20));
    }];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(LBAdapterHeight(17));
        make.width.mas_equalTo(LBAdapterHeight(111));
        make.top.mas_equalTo(self.mas_top).offset(LBAdapterHeight(66));
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.left.mas_equalTo(self.mas_left).offset(LBAdapterHeight(20));
        make.right.mas_equalTo(self.mas_right).offset(LBAdapterHeight(-20));
        make.top.mas_equalTo(self.iconImgView.mas_bottom).offset(LBAdapterHeight(20));
    }];
    
    [self loadingPrivacyInfo];
}

- (void)loadingPrivacyInfo {
    __block NSAttributedString *attributedString = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"privacy policy" ofType:@"rtf"];
        if (filePath) {
            NSData *rtfData = [NSData dataWithContentsOfFile:filePath];
            if (rtfData) {
                NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType};
                attributedString = [[NSAttributedString alloc] initWithData:rtfData options:options documentAttributes:nil error:nil];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (attributedString) {
                self.contentView.attributedText = attributedString;
            }
        });
    });
}

- (void)backClicked:(UIButton *)sender {
    [self removeFromSuperview];
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
        _iconImgView.image = [UIImage imageNamed:@"home_user_policy"];
    }
    return _iconImgView;
}

- (UITextView *)contentView {
    if (!_contentView) {
        _contentView = [[UITextView alloc] init];
        _contentView.editable = NO;
        _contentView.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
        _contentView.showsVerticalScrollIndicator = NO;
    }
    return _contentView;
}

@end
