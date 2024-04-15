//
//  LBSearchTopView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import "LBSearchTopView.h"

@interface LBSearchTopView () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView * logoView;
@property (nonatomic, strong) UIView * boxView;
@property (nonatomic, strong) UITextField * searchTextFiled;
@property (nonatomic, strong) UIImageView * rightIconView;
@property (nonatomic, strong) UIButton * cleanInputButton;
@property (nonatomic, strong) UIProgressView * progressView;

@property (nonatomic, assign) BOOL isShowClosed;

@end

@implementation LBSearchTopView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self cornerRadiusBottom];
}

- (void)initializeAppearance {
    self.backgroundColor = [UIColor LB_colorWithHex:0xff222227];
    [self addSubview:self.logoView];
    [self addSubview:self.boxView];
    [self.boxView addSubview:self.searchTextFiled];
    [self.boxView addSubview:self.rightIconView];
    [self.boxView addSubview:self.cleanInputButton];
    [self addSubview:self.progressView];
    
    [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(134));
        make.height.mas_equalTo(LBAdapterHeight(13));
        make.top.mas_equalTo(LBAdapterHeight(56));
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(LBAdapterHeight(-20));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(LBAdapterHeight(335));
        make.height.mas_equalTo(LBAdapterHeight(60));
    }];
    
    [self.rightIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(26));
        make.centerY.mas_equalTo(self.boxView.mas_centerY);
        make.right.mas_equalTo(self.boxView.mas_right).offset(LBAdapterHeight(-20));
    }];
    
    [self.cleanInputButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(26));
        make.centerY.mas_equalTo(self.boxView.mas_centerY);
        make.right.mas_equalTo(self.boxView.mas_right).offset(LBAdapterHeight(-20));
    }];
    
    [self.searchTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.boxView.mas_centerY);
        make.left.mas_equalTo(self.boxView.mas_left).offset(LBAdapterHeight(16));
        make.right.mas_equalTo(self.boxView.mas_right).offset(LBAdapterHeight(-50));
        make.height.mas_equalTo(LBAdapterHeight(15));
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(LBAdapterHeight(44));
        make.right.mas_equalTo(self.mas_right).offset(LBAdapterHeight(-44));
        make.height.mas_equalTo(LBAdapterHeight(4));
        make.bottom.mas_equalTo(self.mas_bottom).offset(LBAdapterHeight(-9));
    }];
}

/// 圆角
- (void)cornerRadiusBottom {
    CGFloat cornerRadius = LBAdapterHeight(32);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    self.clipsToBounds = YES;
}

- (void)updateProgressValue:(CGFloat)progressValue {
    self.progressView.progress = progressValue;
    if (progressValue >= 1 || progressValue <= 0) {
        self.progressView.hidden = YES;
    }else {
        self.progressView.hidden = NO;
    }
}

- (void)updateInputUrl:(NSString *)urlString {
    if (urlString) {
        self.searchTextFiled.text = urlString;
        [self updateInputRightMode];
    }
}

- (void)textFiledEndEdit {
    [self.searchTextFiled resignFirstResponder];
}

- (void)updateWebviewLoading:(WKWebView *)webView {
    if (webView.loading && webView.URL) {
        NSString * urlString = webView.URL.absoluteString;
        if (urlString) {
            self.searchTextFiled.text = urlString;
        }
    }
}

#pragma mark - UITextFiled Delegate

- (void)textFieldChange: (UITextField *)sender {
    [self updateInputRightMode];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.textDidBeginEditBlock) {
        self.textDidBeginEditBlock();
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString * string = textField.text;
    NSString * realStr = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (realStr.length > 0) {
        if (self.searchInputBlock) {
            self.searchInputBlock(string);
        }
    }else {
        [LBToast showMessage:@"Please enter your search content." duration:1.5 finishHandler:nil];
    }
    return YES;
}

- (void)cleanInputClicked:(UIButton *)sender {
    self.searchTextFiled.text = @"";
    [self updateInputRightMode];
    if (self.cleanInputBlock) {
        self.cleanInputBlock();
    }
}

- (void)updateInputRightMode {
    NSInteger length = self.searchTextFiled.text.length;
    self.rightIconView.hidden = length>0?YES:NO;
    self.cleanInputButton.hidden = length>0?NO:YES;
}

#pragma mark - Getter

- (UIImageView *)logoView {
    if (!_logoView) {
        _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_logo"]];
    }
    return _logoView;
}

- (UIView *)boxView {
    if (!_boxView) {
        _boxView = [[UIView alloc] init];
        _boxView.backgroundColor = [UIColor LB_colorWithHex:0xff323234];
        _boxView.layer.cornerRadius = LBAdapterHeight(30);
        _boxView.clipsToBounds = YES;
    }
    return _boxView;
}

- (UITextField *)searchTextFiled {
    if (!_searchTextFiled) {
        NSAttributedString * attrPlaceHolder = [[NSAttributedString alloc] initWithString:@"Search..." attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        _searchTextFiled = [[UITextField alloc] init];
        _searchTextFiled.delegate = self;
        _searchTextFiled.attributedPlaceholder = attrPlaceHolder;
        _searchTextFiled.font = [UIFont systemFontOfSize:LBAdapterHeight(14)];
        _searchTextFiled.textColor = [UIColor whiteColor];
        _searchTextFiled.returnKeyType = UIReturnKeyDone;
        [_searchTextFiled addTarget:self action:@selector(textFieldChange:)
        forControlEvents:UIControlEventEditingChanged];
    }
    return _searchTextFiled;
}

- (UIImageView *)rightIconView {
    ///home_search_icon   home_search_close
    if (!_rightIconView) {
        _rightIconView = [[UIImageView alloc] init];
        _rightIconView.image = [UIImage imageNamed:@"home_search_icon"];
    }
    return _rightIconView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = [[UIColor LB_colorWithHex:0xff78AA4D] colorWithAlphaComponent:0.7];
        _progressView.progressTintColor = [UIColor LB_colorWithHex:0xff58C417];
        _progressView.progress = 0.0;
        _progressView.hidden = YES;
    }
    return _progressView;
}

- (UIButton *)cleanInputButton {
    if (!_cleanInputButton) {
        _cleanInputButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cleanInputButton.hidden = YES;
        [_cleanInputButton setBackgroundImage:[UIImage imageNamed:@"home_search_close"] forState:UIControlStateNormal];
        [_cleanInputButton addTarget:self action:@selector(cleanInputClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanInputButton;
}

@end
