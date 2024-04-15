//
//  AppDelegate.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import "AppDelegate.h"
#import "LBSearchViewController.h"
#import "LBBootLoadingView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [LBVpnUtil.shareInstance load:nil];
    ///初始化tab管理器
    LBWebPageTabModel * model = [[LBWebPageTabManager shareInstance] getFirstTabModel];
    [LBAppManagerCenter shareInstance];
    
    LBSearchViewController * homeVC = [[LBSearchViewController alloc] initWithStartMode:LBHomeStartModeCold fromModel:model];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = homeVC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [LBBootLoadingView showLoadingMode:LBLoadingModeFireBoot superView:nil];
}

@end
