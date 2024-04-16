//
//  LBSmartServerViewController.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import "LBSmartServerViewController.h"
#import "LBVpnModel.h"
#import "LBSmartServerCollectionViewCell.h"

@interface LBSmartServerViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)UIButton * backButton;
@property (nonatomic, strong)UIImageView * iconImgView;

@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation LBSmartServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    [self initializeAppearance];
}

- (void)initDataSource {
    [self.dataSource addObjectsFromArray:[LBAppManagerCenter shareInstance].vpnModelList];
}

- (void)initializeAppearance {
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.iconImgView];
    [self.bgView addSubview:self.collectionView];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(LBAdapterHeight(20));
        make.top.mas_equalTo(self.view.mas_top).offset(LBAdapterHeight(66));
        make.left.mas_equalTo(LBAdapterHeight(20));
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LBAdapterHeight(128));
        make.height.mas_equalTo(LBAdapterHeight(17));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(LBAdapterHeight(32));
        make.right.mas_equalTo(self.view.mas_right).offset(LBAdapterHeight(-13));
        make.top.mas_equalTo(self.iconImgView.mas_bottom).offset(LBAdapterHeight(62));
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    [self.collectionView reloadData];
}

- (void)backClicked:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource & delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBSmartServerCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LBSmartServerCollectionViewCell identifier] forIndexPath:indexPath];
    [cell loadServerModel:self.dataSource[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LBVpnModel * vpnModel = self.dataSource[indexPath.row];
    /// 如果服务器与当前连接选择相同 就不管
    if ([LBVpnUtil shareInstance].vpnState == LBVpnStateConnected) {
        if ([vpnModel.iconName isEqualToString:[LBAppManagerCenter shareInstance].currentVpnModel.iconName]) {
            return;
        }
    }
    [LBAppManagerCenter shareInstance].currentVpnModel = vpnModel;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReconnectionVpnNoti object:nil];
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
        _iconImgView.image = [UIImage imageNamed:@"vpn_smartserver_icon"];
    }
    return _iconImgView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
    }
    return _bgView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.itemSize = CGSizeMake(LBAdapterHeight(165), LBAdapterHeight(124));
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor LB_colorWithHex:0xff030B08];
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[LBSmartServerCollectionViewCell class] forCellWithReuseIdentifier:[LBSmartServerCollectionViewCell identifier]];
    }
    return _collectionView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end
