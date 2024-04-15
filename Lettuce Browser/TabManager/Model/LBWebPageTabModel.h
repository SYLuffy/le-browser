//
//  LBWebPageTabModel.h
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBWebPageTabModel : NSObject <NSCoding>

///tab页的唯一标识 空url的情况下，代表默认导航页
@property (nonatomic, strong) NSDate * tabKey;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) UIImage * screenShot;

@end

NS_ASSUME_NONNULL_END
