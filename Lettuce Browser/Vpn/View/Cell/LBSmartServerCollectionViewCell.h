//
//  LBSmartServerCollectionViewCell.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LBVpnModel;
@interface LBSmartServerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)LBVpnModel * model;

+ (NSString *)identifier;

- (void)loadServerModel:(LBVpnModel *)model;

@end

NS_ASSUME_NONNULL_END
