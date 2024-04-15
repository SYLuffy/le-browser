//
//  LBTabWebCollectionViewCell.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBTabWebCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) LBWebPageTabModel * model;

+ (NSString *)identifier;

- (void)loadTabModel:(LBWebPageTabModel *)model selectedKey:(NSDate *)selectedKey;

- (void)hiddenClose;

@end

NS_ASSUME_NONNULL_END
