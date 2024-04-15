//
//  LBIconListView.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBIconListView : UIView

@property (nonatomic, copy) void(^iconClickBlock)(NSString * urlString);

@end

NS_ASSUME_NONNULL_END
