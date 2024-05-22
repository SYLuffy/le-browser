//
//  LBWebPageTabManager.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/9.
//

#import "LBWebPageTabManager.h"
#import "LBSearchViewController.h"
#import "LBSearchViewController.h"

static LBWebPageTabManager * webManager = nil;

@interface LBWebPageTabManager ()

@property (nonatomic, strong) NSMutableArray * webTabArrays;
@property (nonatomic, strong) NSString * sandboxFilePath;

@end

@implementation LBWebPageTabManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webManager = [[LBWebPageTabManager alloc] init];
        webManager.sandboxFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"webtabs.archiver"];
        webManager.webTabArrays = [NSKeyedUnarchiver unarchiveObjectWithFile:webManager.sandboxFilePath];
    });
    return webManager;
}

- (LBWebPageTabModel *)addNewWebTabScreenShot:(UIImage *)screenShot {
    LBWebPageTabModel * model = [[LBWebPageTabModel alloc] init];
    model.tabKey = [NSDate date];
    model.url = @"";
    model.screenShot = screenShot;
    [self.webTabArrays insertObject:model atIndex:0];
    [self updateSandbox];
    return model;
}

- (void)updateTabModel:(LBWebPageTabModel *)model {
    LBWebPageTabModel * tempModel = [[LBWebPageTabModel alloc] init];
    NSInteger index = 0;
    for (LBWebPageTabModel * oldModel in self.webTabArrays) {
        if ([oldModel.tabKey isEqualToDate:model.tabKey]) {
            tempModel = oldModel;
            break;
        }
        index ++;
    }
    [self.webTabArrays removeObject:tempModel];
    [self.webTabArrays insertObject:model atIndex:index];
    [self updateSandbox];
}

- (void)removeWebTabfor:(LBWebPageTabModel *)tabModel {
    [self.webTabArrays removeObject:tabModel];
    if (self.removeWebTabFinish) {
        self.removeWebTabFinish(tabModel.tabKey, self.webTabArrays[0]);
    }
    [self updateSandbox];
}

- (NSArray *)getAllWebTabVCScreenShot {
    return self.webTabArrays.copy;
}

- (NSInteger)countOfScreenShotArrays {
    return self.webTabArrays.count;
}

- (void)addNewSerchVC:(nullable LBWebPageTabModel *)fromModel {
    LBSearchViewController * LBHomeVC = [[LBSearchViewController alloc] initWithStartMode:LBHomeStartModeAddNew fromModel:fromModel isAppdelegate:NO];
    [[UIApplication sharedApplication] delegate].window.rootViewController = LBHomeVC;
}

- (void)removeAllWebTab {
    [self.webTabArrays removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtPath:self.sandboxFilePath error:nil];
}

- (void)updateSandbox {
    [NSKeyedArchiver archiveRootObject:self.webTabArrays toFile:self.sandboxFilePath];
}

- (LBWebPageTabModel *)getFirstTabModel {
    if (self.webTabArrays && self.webTabArrays.count > 0) {
        return self.webTabArrays[0];
    }
    return nil;
}

#pragma mark - Getter

- (NSMutableArray *)webTabArrays {
    if (!_webTabArrays) {
        _webTabArrays = [[NSMutableArray alloc] init];
    }
    return _webTabArrays;
}

@end
