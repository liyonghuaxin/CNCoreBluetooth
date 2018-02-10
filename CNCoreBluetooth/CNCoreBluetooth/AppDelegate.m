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
#import "CNBlueCommunication.h"
#import "CNKeychainManager.h"
#import "CommonData.h"
#import "CNNavController.h"
#import "BlueHelp.h"

extern float lyh;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    char a = 'B';
    char b = '1';
    int c = 0x18;
    int num = a+b+c;//66 49  24
    
    Byte byte[] = {a, b, c};
    NSData *data = [NSData dataWithBytes:byte length:3];
    
    NSString *string = @"B1\x18";
    NSData *data2 = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *string3 = [BlueHelp getCurDateByBCDEncode];
    NSData *data3 = [string3 dataUsingEncoding:NSUTF8StringEncoding];
    
    if (kDevice_Is_iPhoneX) {
        iPhoneXTopPara = 24;
        iPhoneXBottomPara = 34;
    }
    scalePage = SCREENWIDTH/375.0;
    edgeDistancePage = 30*scalePage;
    
    //获得蓝牙mac地址
    CNKeychainManager *manager = [CNKeychainManager default];
    NSString *macAddress = [manager load:@"customMacAddress"];
    if (macAddress == nil) {
        //本地生成一个mac地址
        NSString *customMacAddress = [CNBlueCommunication makeMyBlueMacAddress];
        [CommonData sharedCommonData].macAddress = customMacAddress;
        [manager save:@"customMacAddress" data:customMacAddress];
    }else{
        [CommonData sharedCommonData].macAddress = macAddress;
    }
    
    //提前让CoreBluetooth对象初始化,不然会出现异常
    [CNBlueManager sharedBlueManager];
    //初始化数据库
    [CNDataBase sharedDataBase];
    //设置SVProgressHUD颜色
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    //初始化tabbar
    CGFloat offset = 5.0;
    if ([CommonData deviceIsIpad]){
        offset = 0.0;
    }
    NSArray *normalImageArr = @[@"tab_bar_mall1",@"tab_bar_refresh1",@"tab_bar_user1"];
    NSArray *selectImageArr = @[@"tab_bar_mall2",@"tab_bar_refresh2",@"tab_bar_user2"];
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:normalImageArr[0]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectImageArr[0]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    homeVC.tabBarItem.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
    CNNavController *nav1 = [[CNNavController alloc] initWithRootViewController:homeVC];
  
    SetViewController *setVC = [[SetViewController alloc] init];
    setVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:normalImageArr[1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectImageArr[1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    setVC.tabBarItem.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
    CNNavController *nav2 = [[CNNavController alloc] initWithRootViewController:setVC];
    
    HelpViewController *helpVC = [[HelpViewController alloc] init];
    helpVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:normalImageArr[2]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectImageArr[2]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    helpVC.tabBarItem.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
    CNNavController *nav3 = [[CNNavController alloc] initWithRootViewController:helpVC];
    
    UITabBarController *Controller = [[UITabBarController alloc] init];
    Controller.tabBar.translucent = NO;
    Controller.viewControllers = @[nav1, nav2, nav3];
    self.window.rootViewController = Controller;
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
