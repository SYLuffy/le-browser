//
//  NSObject+JJCController.m
//
//  Created by shenyi on 2024/4/1.
//

#import "NSObject+JJCController.h"

@implementation NSObject (JJCController)

- (UIViewController *)jjc_getCurrentUIVC {
    return [self jjc_getCurrentVC];
}

- (UIViewController *)jjc_getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [self jjc_getCurrentVCFrom:[rootVC presentedViewController]];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self jjc_getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self jjc_getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

- (UIViewController *)jjc_getCurrentVC {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self jjc_getCurrentVCFrom:rootViewController];

    return currentVC;
}

+ (nullable UIViewController *)jjc_getViewControllerFromCurrentStackWithClassName:(Class)className {
    return [self jjc_getViewControllerFromStack:[self jjc_getCurrentAvailableNavController] WithClassName:className];
}

+ (nullable UINavigationController *)jjc_getCurrentAvailableNavController {
    UIViewController *currentVC = [self jjc_getCurrentVC];
    if (currentVC) {
        return currentVC.navigationController;
    }
    return nil;
}

+ (nullable UIViewController *)jjc_getViewControllerFromStack:(UINavigationController *)nav WithClassName:(Class)className {
    NSArray *vcs = nav.viewControllers;
    UIViewController *tempVC = nil;
    for (id vc in vcs) {
        if ([vc isMemberOfClass:className]) {
            tempVC = vc;
            break;
        }
    }
    return tempVC;
}

+ (BOOL)jjc_currentStackisContainClass:(Class)className {
    return [self jjc_oneStackisContainClass:className WithStack:[self jjc_getCurrentAvailableNavController]];
}

+ (BOOL)jjc_oneStackisContainClass:(Class)className WithStack:(UINavigationController *)nav {
    BOOL flag = NO;
    NSArray *vcs = nav.viewControllers;
    for (id vc in vcs) {
        if ([vc isMemberOfClass:className]) {
            flag = YES;
            break;
        }
    }
    return flag;
}

+ (void)jjc_popToVCFromCurrentStackTargetVCClass:(Class)className {
    UIViewController *vc = [self jjc_getViewControllerFromCurrentStackWithClassName:className];
    if (vc) {
        [vc.navigationController popToViewController:vc animated:YES];
    }
}

+ (BOOL)jjc_cleanFromCurrentStackTargetVCClass:(Class)className {
    UIViewController *tempVC = [self jjc_getViewControllerFromCurrentStackWithClassName:className];
    if (tempVC) {
        [self jjc_removeVCFromCurrentStack:tempVC];
        return YES;
    }
    return NO;
}

+ (void)jjc_cleanFromCurrentStackTargetVCArrayClass:(NSArray<Class> *)classArray {
    NSMutableArray *tempVCS = [NSMutableArray new];
    UIViewController *currentVC = [self jjc_getCurrentVC];
    NSMutableArray *vcs = currentVC.navigationController.viewControllers.mutableCopy;
    for (Class className in classArray) {
        for (UIViewController *containVC in vcs) {
            if ([containVC isMemberOfClass:className]) {
                if (![tempVCS containsObject:containVC]) {
                    [tempVCS addObject:containVC];
                }
            }
        }
    }
    [vcs removeObjectsInArray:tempVCS];
    [currentVC.navigationController setViewControllers:vcs.copy];
}

+ (void)jjc_removeVCFromCurrentStack:(__kindof UIViewController *)vcToRemove {
    UINavigationController *nav = [self jjc_getCurrentAvailableNavController];
    NSMutableArray *vcs = nav.viewControllers.mutableCopy;
    [vcs enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == vcToRemove) {
            [vcs removeObject:obj];
        }
    }];
    nav.viewControllers = vcs;
}

+ (void)jjc_removeVCsFromCurrentStack:(NSArray <__kindof UIViewController *>*)vcsToRemove {
    UIViewController *vc = [vcsToRemove lastObject];
    NSMutableArray *vcs = vc.navigationController.viewControllers.mutableCopy;
    NSMutableArray *tempVcsToRemove = [NSMutableArray new];
    for (id vcToRemove in vcsToRemove) {
        for (UIViewController *tempVC in vcs) {
            if ([vcToRemove isEqual:tempVC]) {
                [tempVcsToRemove addObject:tempVC];
                break;
            }
        }
    }
    [vcs removeObjectsInArray:tempVcsToRemove];
    [vc.navigationController setViewControllers:vcs];
}

+ (void)jjc_addVCToCurrentStack:( __kindof UIViewController * _Nonnull)vc toIndex:(NSUInteger)index {
    [self jjc_addVCsToCurrentStack:@[vc] toIndex:index];
}

+ (void)jjc_addVCsToCurrentStack:(NSArray <__kindof UIViewController * > * _Nonnull)vcs toIndex:(NSUInteger)index {
    UIViewController *currentVC = [self jjc_getCurrentVC];
    NSMutableArray *array = currentVC.navigationController.viewControllers.mutableCopy;
    if (index >= array.count) {
        [array addObjectsFromArray:vcs];
    } else {
        [array insertObjects:vcs atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, vcs.count)]];
    }
    [currentVC.navigationController setViewControllers:array];
}

+ (void)jjc_keepOnlyVC:(UIViewController *)vc FormStackWithNavigationController:(UINavigationController *)nav {
    NSMutableArray *tempVCS = [NSMutableArray new];
    NSMutableArray *vcs = nav.navigationController.viewControllers.mutableCopy;
    for (UIViewController *tempVC in vcs) {
        // 得到当前控制器中所有的vc
        if ([tempVC isMemberOfClass:[vc class]]) {
            [tempVCS addObject:tempVC];
        }
    }
    // 保留最后一个
    [tempVCS removeLastObject];
    [vcs removeObjectsInArray:tempVCS];
    [nav setViewControllers:vcs];
}

+ (void)jjc_keepOnlyVC:(UIViewController *)vc {
     [self jjc_keepOnlyVC:vc FormStackWithNavigationController:[self jjc_getCurrentAvailableNavController]];
}

@end
