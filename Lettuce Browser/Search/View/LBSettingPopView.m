//
//  LBSettingPopView.m
//  Lettuce Browser
//
//  Created by jojo on 2024/4/5.
//

#import "LBSettingPopView.h"
#import "LBSettingListModel.h"
#import "LBSettingListTableViewCell.h"
#import "LBPrivacyPolicyView.h"
#import "LBTermsOfUserView.h"
#import <StoreKit/StoreKit.h>

@interface LBSettingPopView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton * topButton;
@property (nonatomic, strong) UIView * boxView;
@property (nonatomic, strong) UIButton * addNewButton;
@property (nonatomic, strong) UIButton * shareButton;
@property (nonatomic, strong) UIButton * urlCopyButton;
@property (nonatomic, strong) UIView * lineView;
@property (nonatomic, strong) UITableView * listView;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) LBWebPageTabModel * tabWebModel;
@property (nonatomic, assign) BOOL isShareing;

@end

@implementation LBSettingPopView

+ (LBSettingPopView *)popShowWithSuperView:(UIView *)superView tabWebModel:(LBWebPageTabModel *)tabWebModel{
    LBSettingPopView * popView = [[LBSettingPopView alloc] init];
    popView.frame = CGRectMake(0, 0, kLBDeviceWidth, kLBDeviceHeight);
    popView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    popView.tabWebModel = tabWebModel;
    if (!superView) {
        [[UIApplication sharedApplication].windows.lastObject addSubview:popView];
    }else {
        [superView addSubview:popView];
    }
    return popView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
        [self initListDataSource];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat cornerRadius = LBAdapterHeight(32);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kLBDeviceWidth, LBAdapterHeight(330))
                                                   byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    self.boxView.layer.mask = maskLayer;
    self.boxView.clipsToBounds = YES;
}

- (void)initListDataSource {
    NSArray * iconNames = @[@"home_toolbarlist_rateus",@"home_toolbarlist_policy",@"home_toolbarlist_termsus"];
    NSArray * titleNames = @[@"Rate Us",@"Privacy Policy",@"Terms of user"];
    NSArray * typeArrays = @[@(LBSettingPopTypeRateUs),@(LBSettingPopTypePolicy),@(LBSettingPopTypeTermsofUser)];
    for (int i = 0; i < iconNames.count; i ++) {
        LBSettingListModel * model = [[LBSettingListModel alloc] init];
        model.iconName = iconNames[i];
        model.titleName = titleNames[i];
        model.typeName = typeArrays[i];
        [self.dataSource addObject:model];
    }
    [self.listView reloadData];
}

- (void)initializeAppearance {
    [self addSubview:self.boxView];
    [self addSubview:self.topButton];
    [self.boxView addSubview:self.addNewButton];
    [self.boxView addSubview:self.shareButton];
    [self.boxView addSubview:self.urlCopyButton];
    [self.boxView addSubview:self.lineView];
    [self.boxView addSubview:self.listView];
    
    [self addConstraint];
}

- (void)addConstraint {
    [self.topButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.boxView.mas_top);
        make.top.mas_equalTo(self.mas_top);
        make.left.right.mas_equalTo(self);
    }];
    [self.boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kLBDeviceWidth);
        make.height.mas_equalTo(LBAdapterHeight(330));
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    [self.addNewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(67));
        make.height.mas_equalTo(LBAdapterHeight(97));
        make.top.mas_equalTo(LBAdapterHeight(32));
        make.right.mas_equalTo(self.shareButton.mas_left).offset(LBAdapterHeight(-50));
    }];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(67));
        make.height.mas_equalTo(LBAdapterHeight(97));
        make.centerX.mas_equalTo(self.boxView.mas_centerX);
        make.top.mas_equalTo(self.boxView.mas_top).offset(LBAdapterHeight(32));
    }];
    [self.urlCopyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(67));
        make.height.mas_equalTo(LBAdapterHeight(97));
        make.top.mas_equalTo(LBAdapterHeight(32));
        make.left.mas_equalTo(self.shareButton.mas_right).offset(LBAdapterHeight(50));
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shareButton.mas_bottom).offset(LBAdapterHeight(20));
        make.left.mas_equalTo(self.boxView.mas_left).offset(LBAdapterHeight(20));
        make.right.mas_equalTo(self.boxView.mas_right).offset(LBAdapterHeight(-20));
        make.height.mas_equalTo(1);
    }];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(LBAdapterHeight(180));
        make.left.right.mas_equalTo(self.lineView);
        make.bottom.mas_equalTo(self.boxView.mas_bottom);
    }];
}

- (UIButton *)createButtonIconName:(NSString *)iconName title:(NSString *)title clickType:(LBSettingPopType)clickType {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = clickType;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [UIImage imageNamed:iconName];
    [button setImage:image forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(13)];
    [button setTitle:title forState:UIControlStateNormal];
    
    /// 图片在上，文字在下
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.imageEdgeInsets = UIEdgeInsetsMake(-(button.titleLabel.intrinsicContentSize.height + LBAdapterHeight(18)), 0, 0, -button.titleLabel.intrinsicContentSize.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -(button.imageView.frame.size.width + button.imageView.frame.size.width), -(button.imageView.frame.size.height + LBAdapterHeight(18)), 0);
    return button;
}

- (void)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case LBSettingPopTypeAddNew:
            [self dismiss];
            [[LBWebPageTabManager shareInstance] addNewSerchVC:nil];
            break;
        case LBSettingPopTypeShare:
            [self shareContent];
            break;
        case LBSettingPopTypeCopy: {
            NSString * stringToCopy = self.tabWebModel.url;
            NSString * toastString = @"There is currently no linked content to copy！";
            if (stringToCopy && stringToCopy.length > 0) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:stringToCopy];
                toastString = @"Copy successfully.";
            }
            [LBToast showMessage:toastString inView:self duration:1.5 finishHandler:nil];
        }
            break;
        default:
            break;
    }
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)openAppStoreReviewPage {
    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    } else {
        // 在 iOS 10.2 及更低版本上无法打开应用程序评分页面，
        [LBToast showMessage:@"This feature is currently under development, please stay tuned ~~" duration:1.5 finishHandler:nil];
    }
}

- (void)shareContent {
    if (self.isShareing) {
        return;
    }
    self.isShareing = YES;
    if (self.tabWebModel.url && self.tabWebModel.url.length > 0) {
        NSString *textToShare = @"share url";
        NSURL *urlToShare = [NSURL URLWithString:self.tabWebModel.url];
       
        NSArray *activityItems = @[textToShare, urlToShare];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        
        UIViewController * currentVC = [self jjc_getCurrentUIVC];
        
        // 在 iPad 上，需要设置 popoverPresentationController 来指定分享界面的弹出位置
        activityViewController.popoverPresentationController.sourceView = currentVC.view;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(currentVC.view.bounds), CGRectGetMidY(currentVC.view.bounds), 0, 0);
        __weak typeof(self) weakSelf = self;
        [currentVC presentViewController:activityViewController animated:YES completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.isShareing = NO;
            [strongSelf dismiss];
        }];
    }else {
        /// 未上线 暂时没有商店地址
        [LBToast showMessage:@"This feature is currently under development, please stay tuned ~~" duration:1.5 finishHandler:nil];
        self.isShareing = NO;
    }
}

#pragma mark - UITableViewDataSource And Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LBAdapterHeight(52);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBSettingListTableViewCell * cell = (LBSettingListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LBSettingListTableViewCell identifier]];
    [cell loadModel:self.dataSource[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LBSettingListModel * model = self.dataSource[indexPath.row];
    NSNumber * type = model.typeName;
    switch (type.integerValue) {
        case LBSettingPopTypeRateUs:
            [self openAppStoreReviewPage];
            break;
        case LBSettingPopTypePolicy: {
            [LBPrivacyPolicyView popShowWithSuperView:nil];
        }
            break;
        case LBSettingPopTypeTermsofUser: {
            [LBTermsOfUserView popShowWithSuperView:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getter

- (UIButton *)topButton {
    if (!_topButton) {
        _topButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _topButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f];
        [_topButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topButton;
}

- (UIView *)boxView {
    if (!_boxView) {
        _boxView = [[UIView alloc] init];
        _boxView.backgroundColor = [UIColor LB_colorWithHex:0xff222227];
    }
    return _boxView;
}

- (UIButton *)addNewButton {
    if (!_addNewButton) {
        _addNewButton = [self createButtonIconName:@"home_setting_new" title:@"New " clickType:LBSettingPopTypeAddNew];
    }
    return _addNewButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [self createButtonIconName:@"home_setting_share" title:@"Share" clickType:LBSettingPopTypeShare];
    }
    return _shareButton;
}

- (UIButton *)urlCopyButton {
    if (!_urlCopyButton) {
        _urlCopyButton = [self createButtonIconName:@"home_setting_copy" title:@"Copy" clickType:LBSettingPopTypeCopy];
    }
    return _urlCopyButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor LB_colorWithHex:0xff535359];
    }
    return _lineView;
}

- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.scrollEnabled = NO;
        _listView.backgroundColor = [UIColor LB_colorWithHex:0xff222227];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listView registerClass:[LBSettingListTableViewCell class] forCellReuseIdentifier:[LBSettingListTableViewCell identifier]];
    }
    return _listView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end
