//
//  CNBlueCommunication.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RespondModel.h"

@interface CNBlueCommunication : NSObject
/*
 一、广播包格式
 蓝牙名称：Quick Safe  默认密码：123456
 蓝牙服务UUID: FFE0 蓝牙特征UUID：FFE1
 二、数据包格式
 1、自动同步    2、开锁    3、广播名称及配对密码修改    4、开锁记录查询
 5、已配对设备查询    6、解除配对    7、锁具状态上报
 */

+(BOOL)cbIsPaire:(NSString *)pwdStr;

/**
 app->锁具
 */
+ (void)cbSendInstruction:(InstructionEnum)instruction toPeripheral:(CBPeripheral *)peripheral;
/**
 app->锁具
 */
+ (void)cbSendData:(NSString *)str toPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic;
/**
 锁具->app
 */
+ (void)cbReadData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic;
/**
 解析锁具返回的数据
 */
+ (RespondModel *)parseResponseDataWithParameter:(NSData *)data;
//生成一个本地蓝牙地址
+ (NSString *)makeMyBlueMacAddress;
+ (void)initCharacteristic:(CBCharacteristic *)chara;

// 获取手机蓝牙mac地址
+ (void)cbGetMacID:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;
+ (void)cbCorrectTime:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;
+ (void)cbReadOfflineData:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;

+ (NSData*)dataWithString:(NSString *)string;
+ (NSString*)hexadecimalString:(NSData *)data;

@end
