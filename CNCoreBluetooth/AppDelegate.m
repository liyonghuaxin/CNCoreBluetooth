//
//  AppDelegate.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "SetViewController.h"
#import "HelpViewController.h"
#import "CNBlueManager.h"
#import "SVProgressHUD.h"
#import "CNDataBase.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //提前让CoreBluetooth对象初始化,不然会出现异常
    [CNBlueManager sharedBlueManager];
    [CNDataBase sharedDataBase];
    
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    //NSArray *itemTitleArr = @[@"资讯",@"视频",@"我的"];
    CGFloat offset = 5.0;
    NSArray *normalImageArr = @[@"tab_bar_mall1",@"tab_bar_refresh1",@"tab_bar_user1"];
    NSArray *selectImageArr = @[@"tab_bar_mall2",@"tab_bar_refresh2",@"tab_bar_user2"];
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:normalImageArr[0]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectImageArr[0]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    homeVC.tabBarItem.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:homeVC];
    
    SetViewController *setVC = [[SetViewController alloc] init];
    setVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:normalImageArr[1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectImageArr[1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    setVC.tabBarItem.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:setVC];
    
    HelpViewController *helpVC = [[HelpViewController alloc] init];
    helpVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:normalImageArr[2]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectImageArr[2]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    helpVC.tabBarItem.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:helpVC];
    
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    tabbar.viewControllers = @[nav1, nav2, nav3];
    self.window.rootViewController = tabbar;
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
