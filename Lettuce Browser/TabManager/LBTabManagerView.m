//
//  LBTabManagerView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/7.
//

#import "LBTabManagerView.h"
#import "LBTabWebCollectionViewCell.h"
#import "LBWebPageTabManager.h"
#import "LBSearchViewController.h"
#import "AppDelegate.h"
#import "LBWebPageTabModel.h"

@interface LBTabManagerView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) UIButton * addNewButton;
@property (nonatomic, strong) LBWebPageTabModel * fromModel;
@property (nonatomic, assign) BOOL isRemoved;

@end

@implementation LBTabManagerView

+ (LBTabManagerView *)popShowWithSuperView:(UIView *)superView fromModel:(nonnull LBWebPageTabModel *)fromModel{
    LBTabManagerView * popView = [[LBTabManagerView alloc] init];
    popView.fromModel = fromModel;
    popView.frame = CGRectMake(0, 0, kLBDeviceWidth, kLBDeviceHeight);
    popView.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
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
    }
    return self;
}

- (void)initializeAppearance {
    [self addSubview:self.collectionView];
    [self addSubview:self.addNewButton];
    [self addSubview:self.backButton];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(LBAdapterHeight(16));
        make.right.mas_equalTo(self.mas_right).offset(LBAdapterHeight(-16));
        make.top.mas_equalTo(self.mas_top).offset(LBAdapterHeight(64));
        make.bottom.mas_equalTo(self.mas_bottom).offset(LBAdapterHeight(-81));
    }];
    
    [self.addNewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(45));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.mas_bottom).offset(LBAdapterHeight(-36));
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.addNewButton.mas_centerY);
        make.left.mas_equalTo(self.mas_left).offset(LBAdapterHeight(20));
        make.width.mas_equalTo(LBAdapterHeight(40));
        make.height.mas_equalTo(LBAdapterHeight(20));
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
    [self removeHandler];
}

- (void)addNewClicked:(UIButton *)sender {
    [self addNewSerchVC:nil];
}

- (void)addNewSerchVC:(nullable LBWebPageTabModel *)fromModel {
    [self dismiss];
    [[LBWebPageTabManager shareInstance] addNewSerchVC:fromModel];
}

- (void)removeHandler {
    __weak typeof(self) weakSelf = self;
    [LBWebPageTabManager shareInstance].removeWebTabFinish = ^(NSDate * _Nonnull removeTabKey, LBWebPageTabModel * _Nonnull firstModel) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([removeTabKey isEqualToDate:strongSelf.fromModel.tabKey]) {
            strongSelf.fromModel = firstModel;
            strongSelf.isRemoved = YES;
        }
        [strongSelf.collectionView reloadData];
    };
}

- (void)backClicked:(UIButton *)sender {
    if (self.isRemoved) {
        [self addNewSerchVC:self.fromModel];
    }else {
        [self dismiss];
    }
}

- (void)dismiss {
    [self removeFromSuperview];
}

#pragma mark - UICollectionViewDataSource & delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [LBWebPageTabManager shareInstance].countOfScreenShotArrays;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBTabWebCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LBTabWebCollectionViewCell identifier] forIndexPath:indexPath];
    [cell loadTabModel:[[LBWebPageTabManager shareInstance] getAllWebTabVCScreenShot][indexPath.row] selectedKey:self.fromModel.tabKey];
    if ([LBWebPageTabManager shareInstance].countOfScreenShotArrays == 1) {
        [cell hiddenClose];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LBWebPageTabModel * model = [[LBWebPageTabManager shareInstance] getAllWebTabVCScreenShot][indexPath.row];
    if ([model.tabKey isEqualToDate:self.fromModel.tabKey] && !self.isRemoved) {
        [self dismiss];
    }else {
        [self addNewSerchVC:model];
    }
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.itemSize = CGSizeMake(LBAdapterHeight(180), LBAdapterHeight(216));
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
        [_collectionView registerClass:[LBTabWebCollectionViewCell class] forCellWithReuseIdentifier:[LBTabWebCollectionViewCell identifier]];
    }
    return _collectionView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)addNewButton {
    if (!_addNewButton) {
        _addNewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addNewButton setBackgroundImage:[UIImage imageNamed:@"home_webtab_addnew"] forState:UIControlStateNormal];
        [_addNewButton addTarget:self action:@selector(addNewClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNewButton;
}

@end
