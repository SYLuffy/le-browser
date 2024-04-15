//
//  LBSettingPopView.h
//  Lettuce Browser
//
//  Created by jojo on 2024/4/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LBSettingPopType) {
    LBSettingPopTypeAddNew,
    LBSettingPopTypeShare,
    LBSettingPopTypeCopy,
    LBSettingPopTypeRateUs,
    LBSettingPopTypePolicy,
    LBSettingPopTypeTermsofUser,
};

@interface LBSettingPopView : UIView

+ (LBSettingPopView *)popShowWithSuperView:(nullable UIView *)superView tabWebModel:(LBWebPageTabModel *)tabWebModel;

@end

NS_ASSUME_NONNULL_END
