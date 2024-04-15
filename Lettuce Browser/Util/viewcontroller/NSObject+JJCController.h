//
//  NSObject+JJCController.h
//
//  Created by shenyi on 2024/4/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JJCController)

/**
 *  获取当前屏幕的viewcontroller
 *
 *  @return 当前屏幕显示的最顶层的vc
 */
- (UIViewController *)jjc_getCurrentUIVC;

/**
 *  从导航栏控制器中获取一个类的实例
 *  @param className 类名
 *
 *  @return 该类的实例
 */
+ (nullable UIViewController *)jjc_getViewControllerFromCurrentStackWithClassName:(Class)className;

/**
 * 从导航栏控制器中获取一个类的实例
 * @param nav 控制器
 * @param className 类名
 *
 * @return 该类的实例
 */
+ (nullable UIViewController *)jjc_getViewControllerFromStack:(UINavigationController *)nav WithClassName:(Class)className;

/**
 *  导航栏控制器中是否存在类
 *  @param className 类型
 *
 *  @return YES 存在
 */
+ (BOOL)jjc_currentStackisContainClass:(Class)className;

/**
 *  导航栏控制器中是否存在类
 *  @param className 类型
 *
 *  @return YES 存在
 */
+ (BOOL)jjc_oneStackisContainClass:(Class)className WithStack:(UINavigationController *)nav;

/**
 *  pop 到指定类名的vc
 *  @param className 类名
 */
+ (void)jjc_popToVCFromCurrentStackTargetVCClass:(Class)className;

/**
 *  导航栏控制器中移除类
 *  @param className 类名
 *
 *  @return YES 成功
 */
+ (BOOL)jjc_cleanFromCurrentStackTargetVCClass:(Class)className;

/**
 *  导航栏控制器中移除类的数组
 *  @param classArray 类名数组
 */
+ (void)jjc_cleanFromCurrentStackTargetVCArrayClass:(NSArray<Class> *)classArray;

/**
 *  移除当前控制器中，指定的类
 *  @param vcToRemove 要移除的类
 */
+ (void)jjc_removeVCFromCurrentStack:(__kindof UIViewController *)vcToRemove;

/**
 *  移除当前控制器中，指定的类,数组
 *  @param vcsToRemove 要移除的类的数组
 */
+ (void)jjc_removeVCsFromCurrentStack:(NSArray <__kindof UIViewController *>*)vcsToRemove;

/**
 *  在当前控制器栈中添加一个vc到index位置
 *  @param vc vc
 *  @param index 要添加到位置
 */
+ (void)jjc_addVCToCurrentStack:( __kindof UIViewController * _Nonnull)vc toIndex:(NSUInteger)index;

/**
 *  在当前控制器栈中添加一个vc到index位置
 *  @param vcs vcs
 *  @param index 要添加到位置
 */
+ (void)jjc_addVCsToCurrentStack:(NSArray <__kindof UIViewController * > * _Nonnull)vcs toIndex:(NSUInteger)index;

/**
 *  保持栈中仅有一个该类
 *  @param vc 类的实例
 *  @param nav 导航栏控制器
 */
+ (void)jjc_keepOnlyVC:(UIViewController *)vc FormStackWithNavigationController:(UINavigationController *)nav;

/**
 *  保持栈中仅有一个该类
 *  @param vc 类的实例
 */
+ (void)jjc_keepOnlyVC:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
