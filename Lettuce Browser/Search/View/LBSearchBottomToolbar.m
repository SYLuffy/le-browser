//
//  LBSearchBottomToolbar.m
//  Lettuce Browser
//
//  Created by jojo on 2024/4/4.
//

#import "LBSearchBottomToolbar.h"
#import "LBSettingPopView.h"
#import "LBAlertView.h"
#import "LBTabManagerView.h"
#import <WebKit/WebKit.h>

@interface LBSearchBottomToolbar ()

@property (nonatomic, strong) UIButton * prevButton;
@property (nonatomic, strong) UIButton * nextButton;
@property (nonatomic, strong) UIButton * cleanButton;
@property (nonatomic, strong) UIButton * tagButton;
@property (nonatomic, strong) UIButton * settingButton;

@end

@implementation LBSearchBottomToolbar

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    self.backgroundColor = [UIColor LB_colorWithHex:0xff222227];
    self.layer.cornerRadius = LBAdapterHeight(26);
    self.clipsToBounds = YES;
    
    [self addSubview:self.prevButton];
    [self addSubview:self.nextButton];
    [self addSubview:self.cleanButton];
    [self addSubview:self.tagButton];
    [self addSubview:self.settingButton];
    
    [self addConstraint];
    [self resertToolBarState];
}

- (void)addConstraint {
    [self.prevButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(LBAdapterHeight(16));
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(LBAdapterHeight(35));
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.prevButton.mas_right).offset(LBAdapterHeight(32));
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(LBAdapterHeight(35));
    }];
    [self.cleanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nextButton.mas_right).offset(LBAdapterHeight(29));
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(LBAdapterHeight(41));
    }];
    [self.tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cleanButton.mas_right).offset(LBAdapterHeight(29));
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(LBAdapterHeight(35));
    }];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tagButton.mas_right).offset(LBAdapterHeight(32));
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(LBAdapterHeight(35));
    }];
}

- (UIButton *)createButtonWithImgName:(NSString *)imgName toolbarType:(LBToolbarType)toolbarType {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = toolbarType;
    [button setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClicked:(UIButton *)sener {
    if (self.toolBarClickBlock) {
        self.toolBarClickBlock(sener.tag);
    }
}

- (void)updateToolBarState:(WKWebView *)webView {
    self.prevButton.enabled = webView.canGoBack;
    self.nextButton.enabled = webView.canGoForward;
}

- (void)resertToolBarState {
    self.prevButton.enabled = NO;
    self.nextButton.enabled = NO;
}

- (void)updateToolBarTabCount {
    NSInteger tabCount = [[LBWebPageTabManager shareInstance] countOfScreenShotArrays];
    if (tabCount < 1) {
        tabCount = 1;
    }
    [self.tagButton setTitle:[NSString stringWithFormat:@"%ld",tabCount] forState:UIControlStateNormal];
}

#pragma mark - Getter

- (UIButton *)prevButton {
    if (!_prevButton) {
        _prevButton = [self createButtonWithImgName:@"home_search_leftBtn" toolbarType:LBToolbarTypePrev];
    }
    return _prevButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [self createButtonWithImgName:@"home_search_rightBtn" toolbarType:LBToolbarTypeNext];
    }
    return _nextButton;
}

- (UIButton *)cleanButton {
    if (!_cleanButton) {
        _cleanButton = [self createButtonWithImgName:@"home_search_cleanBtn" toolbarType:LBToolbarTypeClean];
    }
    return _cleanButton;
}

- (UIButton *)tagButton {
    if (!_tagButton) {
        _tagButton = [self createButtonWithImgName:@"home_search_tabBtn" toolbarType:LBToolbarTypeTag];
    }
    return _tagButton;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [self createButtonWithImgName:@"home_search_settingBtn" toolbarType:LBToolbarTypeSetting];
    }
    return _settingButton;
}

@end
