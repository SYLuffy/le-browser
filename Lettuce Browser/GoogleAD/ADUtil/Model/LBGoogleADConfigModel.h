//
//  LBGoogleADConfigModel.h
//  Lettuce Browser
//
//  Created by shen on 2024/5/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBGoogleADValueModel : NSObject

@property (nonatomic, assign) NSInteger theAdPriority;
@property (nonatomic, strong) NSString * theAdID;

@end

@interface LBGoogleADModel : NSObject

@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * type;
///是否展示过
@property (nonatomic, assign) BOOL isDisPlay;
@property (nonatomic, strong) NSArray <LBGoogleADValueModel *>* value;

@end

@interface LBGoogleADConfigModel : NSObject

@property (nonatomic, assign) BOOL installOnlyTouch;
@property (nonatomic, assign) NSInteger showTimes;
@property (nonatomic, assign) NSInteger clickTimes;
@property (nonatomic, strong) NSArray <LBGoogleADModel *>* ads;

@end

NS_ASSUME_NONNULL_END
