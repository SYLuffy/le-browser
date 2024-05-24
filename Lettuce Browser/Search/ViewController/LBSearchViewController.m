//
//  LBBootLoadViewController.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import "LBSearchViewController.h"
#import "LBBootLoadingView.h"
#import "LBSearchTopView.h"
#import "LBIconListView.h"
#import "LBSearchBottomToolbar.h"
#import "LBSettingPopView.h"
#import <WebKit/WebKit.h>
#import "LBAlertView.h"
#import "LBTabManagerView.h"
#import "LBVPNEntranceView.h"
#import "LBVpnUtil.h"
#import "LBNativeView.h"
#import "Lettuce_Browser-Swift.h"

@interface LBSearchViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong)LBSearchTopView * searchTopView;
@property (nonatomic, strong)LBIconListView * iconListView;
@property (nonatomic, strong)LBSearchBottomToolbar * bottomToolbar;
@property (nonatomic, strong)WKWebView * webView;
@property (nonatomic, strong)UIView * coverLoadingView;
@property (nonatomic, assign)BOOL isFirtLoad;
@property (nonatomic, assign)BOOL isFromModel;
@property (nonatomic, strong)UIView * contentView;
@property (nonatomic, strong)LBWebPageTabModel * currentModel;
@property (nonatomic, strong)NSString * currentUrl;
@property (nonatomic, assign)LBHomeStartMode currentStartMode;
@property (nonatomic, strong)LBVPNEntranceView * vpnEntranceView;
@property (nonatomic, strong)UIButton * fullScrennButton;
@property (nonatomic, assign)BOOL isLoadFinishPage;
@property (nonatomic, strong)NSString * lastWebUrl;
@property (nonatomic, strong)LBNativeView * nativeADView;
/// 是不是从冷启动加载的搜索页
@property (nonatomic, assign)BOOL isAppdelegate;

@end

@implementation LBSearchViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (instancetype)initWithStartMode:(LBHomeStartMode)startMode fromModel:(LBWebPageTabModel *)fromModel isAppdelegate:(BOOL)isAppdelegate{
    self = [super init];
    if (self) {
        if (fromModel) {
            self.isFromModel = YES;
        }
        self.isAppdelegate = isAppdelegate;
        self.currentModel = fromModel;
        self.currentStartMode = startMode;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirtLoad) {
        self.isFirtLoad = NO;
        if (self.isFromModel) {
            [self loadFromModel];
        }else {
            self.currentModel = [[LBWebPageTabManager shareInstance] addNewWebTabScreenShot:[self.contentView takeScreenshot]];
            [self updateNativeAd];
        }
    }else {
        [self updateNativeAd];
    }
    [self.bottomToolbar updateToolBarTabCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirtLoad = YES;
    self.view.backgroundColor = [UIColor LB_colorWithHex:0x030b08];
    [self initializeAppearance];
    if (self.currentStartMode == LBHomeStartModeCold) {
        [LBBootLoadingView showLoadingMode:LBLoadingModeColdBoot superView:self.view];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNativeAd) name:kDismissNotification object:nil];
}

- (void)initializeAppearance {
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.searchTopView];
    [self.contentView addSubview:self.vpnEntranceView];
    [self.contentView addSubview:self.iconListView];
    [self.contentView addSubview:self.bottomToolbar];
    [self.contentView addSubview:self.webView];
    [self.contentView addSubview:self.coverLoadingView];
    [self.contentView addSubview:self.nativeADView];
    [self.view addSubview:self.fullScrennButton];
    [self addConstraint];
    [self allEventHandler];
}

- (void)addConstraint {
    [self.fullScrennButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.searchTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.top.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(LBAdapterHeight(196));
    }];
    
    CGFloat topPadding = 24;
    CGFloat vpnTopPadding = 34;
    if (!kLBIsIphoneX) {
        topPadding = 20;
        vpnTopPadding = 28;
    }
    [self.vpnEntranceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(335));
        make.height.mas_equalTo(LBAdapterHeight(100));
        make.top.mas_equalTo(self.searchTopView.mas_bottom).offset(LBAdapterHeight(topPadding));
        make.centerX.mas_equalTo(self.view);
    }];
    [self.iconListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.vpnEntranceView.mas_bottom).offset(LBAdapterHeight(vpnTopPadding));
        make.left.mas_equalTo(self.contentView.mas_left).offset(LBAdapterHeight(32));
        make.right.mas_equalTo(self.contentView.mas_right).offset(LBAdapterHeight(-32));
        make.height.mas_equalTo(LBAdapterHeight(168));
    }];
    [self.bottomToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(LBAdapterHeight(-34));
        make.width.mas_equalTo(LBAdapterHeight(335));
        make.height.mas_equalTo(LBAdapterHeight(56));
    }];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchTopView.mas_bottom);
        make.bottom.mas_equalTo(self.bottomToolbar.mas_top);
        make.left.right.mas_equalTo(self.contentView);
    }];
    [self.coverLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.webView);
    }];
    
    CGFloat bottomPadding = -18;
    if (!kLBIsIphoneX) {
        bottomPadding = -13;
    }
    [self.nativeADView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(LBAdapterHeight(20));
        make.right.mas_equalTo(self.contentView.mas_right).offset(LBAdapterHeight(-20));
        make.bottom.mas_equalTo(self.bottomToolbar.mas_top).offset(LBAdapterHeight(bottomPadding));
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
    }];
}

- (void)updateNativeAd {
    ///如果当前上层有 开屏广告，不展示首页广告
    if ([LBADOpenManager shareInstance].isShowingAd) {
        return;
    }
    [LBTBALogManager objcLogEventWithName:@"pro_impress" params:nil];
    [LBTBALogManager objcLogEventWithName:@"session_start" params:nil];
    
    if (!self.nativeADView.hidden) {
        __weak typeof(self) weakSelf = self;
        [[LBADNativeManager shareInstance] showNativeAd:LBADPositionHomeNative showLocation:LBADShowLocationHomePage searchTabKey:self.currentModel.tabKey showNativeBlock:^(GADNativeAd * _Nullable nativeAD) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.nativeADView configGADNativeAd:nativeAD];
        }];
    }
}

/// 处理各个模块的事件回调
- (void)allEventHandler {
    __weak typeof(self) weakSelf = self;
    
    /// 推荐金刚位
    self.iconListView.iconClickBlock = ^(NSString * _Nonnull urlString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadUrlString:urlString];
    };
    
    /// 底部工具栏
    self.bottomToolbar.toolBarClickBlock = ^(LBToolbarType type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        switch (type) {
            case LBToolbarTypePrev:
                [strongSelf.webView goBack];
                break;
            case LBToolbarTypeNext:
                [strongSelf.webView goForward];
                break;
            case LBToolbarTypeClean:
                [LBTBALogManager objcLogEventWithName:@"pro_clean" params:nil];
                [LBAlertView showWithSuperView:nil];
                break;
            case LBToolbarTypeSetting: {
                [LBSettingPopView popShowWithSuperView:nil tabWebModel:strongSelf.currentModel];
            }
                break;
            case LBToolbarTypeTag: {
                [strongSelf updateTabModelContent];
                LBTabManagerView * tabManagerVM = [LBTabManagerView popShowWithSuperView:nil fromModel:strongSelf.currentModel];
                tabManagerVM.backToBlock = ^{
                    [strongSelf updateNativeAd];
                };
            }
                break;
            default:
                break;
        }
    };
    
    /// 搜索清理按钮
    self.searchTopView.cleanInputBlock = ^{
       __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.webView.isLoading) {
            strongSelf.currentUrl = strongSelf.lastWebUrl?strongSelf.lastWebUrl:@"";
            [strongSelf.webView stopLoading];
        }
        
        if (!strongSelf.webView.canGoBack && !self.isLoadFinishPage) {
            [strongSelf showWebView:NO];
        }
        
    };
    
    /// 搜索
    self.searchTopView.searchInputBlock = ^(NSString * _Nonnull inputString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        /// 判断是不是网页，不是的话，使用google搜索
        if ([strongSelf verifyWebUrlAddress:inputString]) {
            [strongSelf loadUrlString:inputString];
        }else {
            NSString * googleSearchHost = @"https://www.google.com/search?q=";
            NSString * encdeString = [strongSelf URLUTF8EncodingString:inputString];
            NSString * realUrl = [NSString stringWithFormat:@"%@%@",googleSearchHost,encdeString];
            [strongSelf loadUrlString:realUrl];
        }
    };
    
    /// 搜索框开始编辑、键盘弹出
    /// 显示一个全屏透明视图，用于点击空白区域收回键盘
    self.searchTopView.textDidBeginEditBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.fullScrennButton.hidden = NO;
    };
}

/// url参数编码
- (NSString *)URLUTF8EncodingString:(NSString *)string {
    if (string.length == 0) {
        return string;
    }
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
    NSString *encodeStr = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    return encodeStr;
}


/// 监听 estimatedProgress 属性的变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        if (progress > 0.5) {
            self.coverLoadingView.hidden = YES;
        }
        [self.searchTopView updateProgressValue:progress];
    }
}

//使用系统提供的正则判断 输入的是否是url
- (BOOL)verifyWebUrlAddress:(NSString *)webUrl {
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];
    NSArray *matches = [detector matchesInString:webUrl
                                         options:NSMatchingReportProgress
                                           range:NSMakeRange(0, webUrl.length)];

    if (matches.count == 1) {
        NSTextCheckingResult *result = matches.firstObject;
        if (result.range.location == 0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)loadFromModel {
    if (self.currentModel.url && self.currentModel.url.length > 0) {
        if ([self.currentModel.url isEqualToString:@"empty"]) {
            [self showWebView:YES];
        }else {
            [self loadUrlString:self.currentModel.url];
        }
    }else {
        if (!self.isAppdelegate) {
            [self updateNativeAd];
            self.isAppdelegate = NO;
        }
    }
}

/// 加载url
- (void)loadUrlString:(NSString *)urlString {
    [self showWebView:YES];
    if (![urlString containsString:@"http"]) {
        urlString = [NSString stringWithFormat:@"https://%@",urlString];
    }
    NSURL * url = [NSURL URLWithString:urlString];
    if (url) {
        self.lastWebUrl = self.currentUrl;
        self.currentUrl = urlString;
        [self.searchTopView updateInputUrl:urlString];
        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:urlRequest];
        [self updateTabModelContent];
    }
}

- (void)showWebView:(BOOL)isShow {
    if (!self.isLoadFinishPage && isShow) {
        self.coverLoadingView.hidden = NO;
    }else {
        self.coverLoadingView.hidden = YES;
    }
    self.iconListView.hidden = isShow;
    self.vpnEntranceView.hidden = isShow;
    self.webView.hidden = !isShow;
    self.nativeADView.hidden = isShow;
    if (!isShow) {
        [self updateNativeAd];
    }
    if (!isShow) {
        self.currentUrl = @"";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.webView.backForwardList performSelector:NSSelectorFromString(@"_removeAllItems")];
#pragma clang diagnostic pop
        [self.bottomToolbar updateToolBarState:self.webView];
        [self updateTabModelContent];
    }
}

// 清除当前已存在的 WKWebView 的历史记录、缓存和 Cookie 等其他网站数据
- (void)clearCurrentWebViewData:(WKWebView *)webView {
    WKWebsiteDataStore *dataStore = webView.configuration.websiteDataStore;
    NSSet<NSString *> *dataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    [dataStore fetchDataRecordsOfTypes:dataTypes completionHandler:^(NSArray<WKWebsiteDataRecord *> *records) {
        [dataStore removeDataOfTypes:dataTypes forDataRecords:records completionHandler:^{
            NSLog(@"Cleared current WKWebView data");
        }];
    }];
}

- (void)updateTabModelContent {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.currentModel.url = self.currentUrl;
        self.currentModel.screenShot = [self.contentView takeScreenshot];
        [[LBWebPageTabManager shareInstance] updateTabModel:self.currentModel];
    });
}

- (void)fullClick {
    [self.searchTopView textFiledEndEdit];
    self.fullScrennButton.hidden = YES;
}
    
#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.bottomToolbar updateToolBarState:webView];
    [self.searchTopView updateWebviewLoading:webView];
    if (webView.loading && webView.URL) {
        [LBTBALogManager objcLogEventWithName:@"pro_requist" params:nil];
        NSString * urlString = webView.URL.absoluteString;
        if (urlString) {
            self.lastWebUrl = self.currentUrl;
            self.currentUrl = urlString;
        }
    }
}
    
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSInteger loadTime = arc4random_uniform(4) + 1;
    [LBTBALogManager objcLogEventWithName:@"pro_load" params:@{@"bro":@(loadTime)}];
    [self.bottomToolbar updateToolBarState:webView];
    self.coverLoadingView.hidden = YES;
    self.isLoadFinishPage = YES;
    [self.searchTopView updateWebviewLoading:webView];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.bottomToolbar updateToolBarState:webView];
    [self.searchTopView updateProgressValue:0.0f];
    if (![[LBAppManagerCenter shareInstance] checkShowNetworkNotReachableToast]) {
        [LBToast showMessage:@"Page loading failure" duration:1.2 finishHandler:nil];
    }
    [self.searchTopView updateWebviewLoading:webView];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.bottomToolbar updateToolBarState:webView];
    [self.searchTopView updateProgressValue:0.0f];
    [self.searchTopView updateWebviewLoading:webView];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = self.view.backgroundColor;
    }
    return _contentView;
}

- (LBSearchTopView *)searchTopView {
    if (!_searchTopView) {
        _searchTopView = [[LBSearchTopView alloc] init];
    }
    return _searchTopView;
}

- (LBIconListView *)iconListView {
    if (!_iconListView) {
        _iconListView = [[LBIconListView alloc] init];
    }
    return _iconListView;
}

- (LBSearchBottomToolbar *)bottomToolbar {
    if (!_bottomToolbar) {
        _bottomToolbar = [[LBSearchBottomToolbar alloc] init];
    }
    return _bottomToolbar;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.hidden = YES;
        _webView.scrollView.backgroundColor = self.view.backgroundColor;
        _webView.backgroundColor = self.view.backgroundColor;
        _webView.opaque=NO;
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webView;
}

- (UIView *)coverLoadingView {
    if (!_coverLoadingView) {
        _coverLoadingView = [[UIView alloc] init];
        _coverLoadingView.backgroundColor = [UIColor blackColor];
        _coverLoadingView.hidden = YES;
    }
    return _coverLoadingView;
}

- (LBVPNEntranceView *)vpnEntranceView {
    if (!_vpnEntranceView) {
        _vpnEntranceView = [[LBVPNEntranceView alloc] init];
    }
    return _vpnEntranceView;
}

- (UIButton *)fullScrennButton {
    if (!_fullScrennButton) {
        _fullScrennButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScrennButton addTarget:self action:@selector(fullClick) forControlEvents:UIControlEventTouchUpInside];
        _fullScrennButton.hidden = YES;
        _fullScrennButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f];
    }
    return _fullScrennButton;
}

- (LBNativeView *)nativeADView {
    if (!_nativeADView) {
        _nativeADView = [[LBNativeView alloc] init];
        [_nativeADView configGADNativeAd:nil];
    }
    return _nativeADView;
}

@end
