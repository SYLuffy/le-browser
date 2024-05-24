//
//  AppDelegate.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import "AppDelegate.h"
#import "LBSearchViewController.h"
#import "LBBootLoadingView.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import "LBADOpenManager.h"
#import <Firebase/Firebase.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    [LBGoogleADUtil shareInstance];
    [LBVpnUtil.shareInstance load:nil];
    ///初始化tab管理器
    LBWebPageTabModel * model = [[LBWebPageTabManager shareInstance] getFirstTabModel];
    [LBAppManagerCenter shareInstance];
    [[LBADOpenManager shareInstance] loadAd];
    
    LBSearchViewController * homeVC = [[LBSearchViewController alloc] initWithStartMode:LBHomeStartModeCold fromModel:model isAppdelegate:YES];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = homeVC;
    [self.window makeKeyAndVisible];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                           didFinishLaunchingWithOptions:launchOptions];;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                         openURL:url
                                               sourceApplication:sourceApplication
                                                      annotation:annotation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [LBBootLoadingView showLoadingMode:LBLoadingModeFireBoot superView:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self userTraking];
    [FBSDKAppEvents.shared activateApp];
}
- (void)userTraking {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusDenied:
                    NSLog(@"用户拒绝");
                    break;
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    NSLog(@"用户允许");
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    NSLog(@"用户未做选择");
                    break;
                default:
                    break;
            }
        }];
    }
}

@end
