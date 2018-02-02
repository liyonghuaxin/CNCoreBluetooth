//
//  CNBlueCommunication.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CNBlueCommunication : NSObject

/*
 一、广播包格式
 
 二、数据包格式
 1、自动同步
 2、开锁
 3、广播名称及配对密码修改
 4、开锁记录查询
 5、已配对设备查询
 6、解除配对
 7、锁具状态上报
 */
+ (void)cbSenddata:(NSString *)str toPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic;
/*
 获取手机蓝牙mac地址
 由于现在iOS不能直接获取蓝牙mac地址了,需要设备的厂家就写了一个指令来获取
 */
+ (void)cbGetMacID:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;
+ (void)cbCorrectTime:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;
+ (void)cbReadOfflineData:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;

@end
