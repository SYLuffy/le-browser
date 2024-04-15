//
//  LBSettingListTableViewCell.h
//  Lettuce Browser
//
//  Created by jojo on 2024/4/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LBSettingListModel;
@interface LBSettingListTableViewCell : UITableViewCell

+ (NSString *)identifier;

- (void)loadModel:(LBSettingListModel *)model;

@end

NS_ASSUME_NONNULL_END
