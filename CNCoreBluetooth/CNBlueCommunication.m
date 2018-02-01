//
//  CNBlueCommunication.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNBlueCommunication.h"

@implementation CNBlueCommunication

+ (void)cbSenddata:(NSString *)str toPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic{
    if (characteristic){
        CBCharacteristicWriteType type = CBCharacteristicWriteWithoutResponse;
        if (characteristic.properties & CBCharacteristicPropertyWrite){
            type = CBCharacteristicWriteWithResponse;
        }
        //lyh 这个读操作是发送指令后，来获取响应数据？待测
        [peripheral readValueForCharacteristic:characteristic];
        NSData *rdata = [str dataUsingEncoding:NSUTF8StringEncoding];
        [peripheral writeValue:rdata forCharacteristic:characteristic  type:type];
    }
}

+(void)cbCorrectTime:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    
}

/*  蓝牙mac地址
    app向蓝牙发送指令(这是我们设备的一个指令,由于现在iOS不能直接获取蓝牙mac地址了,我们设备的厂家就写了一个指令来获取,这个指令是自定义的,不适用于其他设备,方法通用)
 */
+(void)cbGetMacID:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    NSLog(@"MAC地址");
    Byte b[] = {0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0};
    NSData *data = [NSData dataWithBytes:&b length:8];
    [CNBlueCommunication writePeripheral:peripheral characteristic:characteristic value:data];
}

//通用发送指令方法
+ (void)writePeripheral:(CBPeripheral *)p
         characteristic:(CBCharacteristic *)c
                  value:(NSData *)value {
    //判断属性是否可写
    if (c.properties & CBCharacteristicPropertyWrite) {
        [p writeValue:value forCharacteristic:c type:CBCharacteristicWriteWithResponse];
    } else {
        NSLog(@"该属性不可写");
    }
}

+(void)cbReadOfflineData:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    
}

@end
