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

typedef void(^periConnectedStateBlock)(CBPeripheral *peripheral, BOOL isConnect, BOOL isOpenTimer, BOOL isNeedReRnterPwd);

typedef void(^respondBlock)(RespondModel *model);

@interface CNBlueCommunication : NSObject

//lyh delete
+ (RespondModel *)parseResponseDataWithParameter:(NSData *)myData;

//监听 蓝牙锁连接状态

+ (void)monitorPeriConnectedState:(periConnectedStateBlock)periConnectedState;
+ (void)monitorLockState:(respondBlock)lockState;

/**
 app->锁具
 */
+ (void)cbSendInstruction:(InstructionEnum)instruction toPeripheral:(CBPeripheral *)peripheral  otherParameter:(id)para finish:(respondBlock)finish;
/**
 app->锁具
 */
+ (void)cbSendStringCon:(NSString *)str toPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic;
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
