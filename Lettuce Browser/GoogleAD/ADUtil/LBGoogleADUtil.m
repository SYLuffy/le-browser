//
//  LBGoogleADUtil.m
//  Lettuce Browser
//
//  Created by shen on 2024/5/20.
//

#import "LBGoogleADUtil.h"
#import <Firebase/Firebase.h>

static NSString * adClickTimesKey = @"adClickTimesKey";
static NSString * adShowTimesKey = @"adShowTimesKey";
static NSString * adLimitDateKey = @"adLimitDateKey";

@interface LBGoogleADUtil ()

@property (nonatomic, strong) LBGoogleADConfigModel * adConfigModel;
@property (nonatomic, assign) NSInteger adClickNumber;
@property (nonatomic, assign) NSInteger adImpressNumber;
@property (nonatomic, strong) NSDate * adLimitDate;

@end

@implementation LBGoogleADUtil

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static LBGoogleADUtil *adUtil = nil;
    dispatch_once(&onceToken, ^{
        adUtil = [[LBGoogleADUtil alloc] init];
        [adUtil loadADConfig];
    });
    return adUtil;
}

- (void)loadADConfig {
    self.adLimitDate = [[NSUserDefaults standardUserDefaults] objectForKey:adLimitDateKey];
    self.adClickNumber = [[NSUserDefaults standardUserDefaults] integerForKey:adClickTimesKey];
    self.adImpressNumber = [[NSUserDefaults standardUserDefaults] integerForKey:adShowTimesKey];
    [self recordADLimitDate];
    ///远程拉取
    [self localADConfig];
}

- (void)localADConfig {
    /// 加载本地广告配置
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"admob_pro" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    self.adConfigModel = [LBGoogleADConfigModel yy_modelWithJSON:dictionary];
    [self initAllADModels];
//    [self fetchRemoteConfig];
}

- (void)fetchRemoteConfig {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *settings = [[FIRRemoteConfigSettings alloc] init];
    remoteConfig.configSettings = settings;
    [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"[Config] Config fetcher! ✅");
            [remoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
                NSArray *keys = [remoteConfig allKeysFromSource:FIRRemoteConfigSourceRemote];
                NSLog(@"[Config] config params = %@", keys);
                NSString *remoteAd = [remoteConfig configValueForKey:@"ADConfig"].stringValue;
                if (remoteAd) {
                    // base64 的remote 需要解码
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:remoteAd options:0];
                    if (data) {
                        NSError * error = nil;
                        NSDictionary * adConfigDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                        if (adConfigDict) {
                            self.adConfigModel = [LBGoogleADConfigModel yy_modelWithJSON:adConfigDict];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self initAllADModels];
                            });
                        }else {
                            NSLog(@"[Config] Config config 'ad_config' 不是一个符合格式的json");
                        }
                    }else {
                        NSLog(@"[Config] Config config 'ad_config' 不是一个base64的字符串");
                    }
                } else {
                    NSLog(@"[Config] Config config 'ad_config' is nil or config not json.");
                }
            }];
        } else {
            NSLog(@"[Config] config not fetcher, error = %@", error.localizedDescription);
        }
    }];
}

- (void)initAllADModels {
    for (LBGoogleADModel * model in self.adConfigModel.ads) {
        /// 开屏
        if ([model.type isEqualToString:@"open"]) {
            [LBADOpenManager shareInstance].adModel = [self sortAdModel:model];
        }
        
        /// 插屏
        if ([model.key isEqualToString:[self getPositionKeyWith:LBADPositionConnect]]) {
            [LBADInterstitialManager shareInstance].vpnConnectADModel = [self sortAdModel:model];
        }
        
        if ([model.key isEqualToString:[self getPositionKeyWith:LBADPositionBack]]) {
            [LBADInterstitialManager shareInstance].backADModel = [self sortAdModel:model];
        }
        
        /// 原生
        if ([model.key isEqualToString:[self getPositionKeyWith:LBADPositionHomeNative]]) {
            [LBADNativeManager shareInstance].homeNativeModel = [self sortAdModel:model];
        }
        
        if ([model.key isEqualToString:[self getPositionKeyWith:LBADPositionResultNative]]) {
            [LBADNativeManager shareInstance].resultNativeModel = [self sortAdModel:model];
        }
    }
}

- (LBGoogleADModel *)sortAdModel:(LBGoogleADModel *)model{
    NSArray *sortedArray = [model.value sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"theAdPriority" ascending:YES]]];
    model.value = sortedArray;
    return model;
}

- (void)recordADClickNumber {
    if (self.adClickNumber == self.adConfigModel.clickTimes) {
        return;
    }
    self.adClickNumber += 1;
    NSLog(@"[AD] [LIMIT] 当前广告点击次数:%ld 😄😄😄",self.adClickNumber);
    [[NSUserDefaults standardUserDefaults] setInteger:self.adClickNumber forKey:adClickTimesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)recordADImpressNumber {
    if (self.adImpressNumber == self.adConfigModel.showTimes) {
        return;
    }
    self.adImpressNumber += 1;
    NSLog(@"[AD] [LIMIT] 当前广告显示次数:%ld 😄😄😄",self.adImpressNumber);
    [[NSUserDefaults standardUserDefaults] setInteger:self.adImpressNumber forKey:adShowTimesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)recordADLimitDate {
    if (!self.adLimitDate) {
        self.adLimitDate = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:self.adLimitDate forKey:adLimitDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else {
        /// 不是同一天 重置次数
        if (![self isToday:self.adLimitDate]) {
            self.adLimitDate = [NSDate date];
            self.adClickNumber = -1;
            self.adImpressNumber = -1;
            [self recordADLimitDate];
            [self recordADClickNumber];
            [[NSUserDefaults standardUserDefaults] setObject:self.adLimitDate forKey:adLimitDateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (BOOL)isToday:(NSDate *)someDate {
    NSDate * currentDate = [NSDate date];
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units fromDate:someDate];
    BOOL isToday = (components.year == [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:currentDate] &&
                   components.month == [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:currentDate] &&
                   components.day == [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:currentDate]);
    return isToday;
}

- (BOOL)installOnlyTouch {
    return self.adConfigModel.installOnlyTouch;
}

- (BOOL)isADLimit {
    if (self.adConfigModel) {
        if ((self.adClickNumber >= self.adConfigModel.clickTimes || self.adImpressNumber >= self.adConfigModel.showTimes) && [self isToday:self.adLimitDate]) {
            NSLog(@"[AD] 用戶超限制。");
            return YES;
        }
    }
    return NO;
}

- (NSString *)getPositionKeyWith:(LBADPosition)position {
    NSString * positionKey = @"";
    switch (position) {
        case LBADPositionLoadingOpen:
            positionKey = @"loadingOpen";
            break;
        case LBADPositionHomeNative:
            positionKey = @"homeNative";
            break;
        case LBADPositionResultNative:
            positionKey = @"resultNative";
            break;
        case LBADPositionConnect:
            positionKey = @"vpnConnect";
            break;
        case LBADPositionBack:
            positionKey = @"back";
            break;
        default:
            break;
    }
    return positionKey;
}

@end
