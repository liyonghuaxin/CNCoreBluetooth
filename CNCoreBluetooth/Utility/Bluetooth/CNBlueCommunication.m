//
//  CNBlueCommunication.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNBlueCommunication.h"
#import "CommonData.h"

@implementation CNBlueCommunication

//一个手机只调一次，此方法生成的地址将保存到钥匙串keychain
+(NSString *)makeMyBlueMacAddress{
    //D2C82D25-B100-4C44-BB0B-2ED76AF43304
    //D2B14CBB2ED7
    NSString *idfvStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSArray *arr = [idfvStr componentsSeparatedByString:@"-"];
    NSMutableString *uidStr = [[NSMutableString alloc] init];
    for (int i = 0; i<arr.count; i++) {
        if (i == arr.count - 1) {
            NSString *str = [NSString stringWithFormat:@"%@",arr[i]];
            [uidStr appendString:[str substringWithRange:NSMakeRange(0, 4)]];
        }else{
            NSString *str = [NSString stringWithFormat:@"%@",arr[i]];
            [uidStr appendString:[str substringWithRange:NSMakeRange(0, 2)]];
        }
    }
    return uidStr;
}
/*
 关于写数据
 CBCharacteristicWriteWithResponse方法给外围设备写数据时，会回调 其代理的peripheral:didWriteValueForCharacteristic:error:方法。
 */
+ (void)cbSenddata:(NSString *)str toPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic{
    if (characteristic){
        CBCharacteristicWriteType type = CBCharacteristicWriteWithoutResponse;
        if (characteristic.properties & CBCharacteristicPropertyWrite){
            type = CBCharacteristicWriteWithResponse;
        }
        //lyh 这个读操作是发送指令后，来获取响应数据？待测
        [peripheral readValueForCharacteristic:characteristic];
        NSData *rdata = [CNBlueCommunication getDataPacketWith:str];
        [peripheral writeValue:rdata forCharacteristic:characteristic  type:type];
    }
}

+(void)cbCorrectTime:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    
    //data：2018-02-01 06:29:25 +0000
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY-MM-dd-hh-mm"];
    //dateString：18-02-01-02-29   已转为中国时间了
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSArray *time_strs = [dateString componentsSeparatedByString:@"-"];
    NSLog(@"time_strs = %@",time_strs);
    // (18, 02, 01, 02, 29)
    int num3 =[time_strs[0] intValue];
    int num4 =[time_strs[1] intValue];
    int num5 =[time_strs[2] intValue];
    int num6 =[time_strs[3] intValue];
    int num7 =[time_strs[4] intValue];
    
    //后三位90-11-5是把CMD_HEAD CMD_LENGHT CMD_SORT 转成的10进制
    int num8 = num3 + num4 +num5 +num6 +num7 +90+11+5;
    Byte   CMD_HEAD = 0x5A;//ASCII Z
    Byte   CMD_LENGHT = 0x0B;//ASCII  VT 制表符
    Byte   CMD_SORT = 0x05;//ASCII 5

    Byte byte4[] = {CMD_HEAD,CMD_LENGHT,CMD_SORT,num3,num4,num5,num6,num7,num8,0,0};
    NSData *data23 = [NSData dataWithBytes:byte4 length:sizeof(byte4)];
    /*
     byte4：
     十六进制
     (Byte [11]) byte4 = ([0] = 'Z', [1] = '\v', [2] = '\x05', [3] = '\x12', [4] = '\x02', [5] = '\x01', [6] = '\x02', [7] = '\x1d', [8] = '\x9e', [9] = '\0', [10] = '\0')
     
     data23：
     <5a0b0512 0201021d 9e0000>
     */
    
}

/*  蓝牙mac地址
    app向蓝牙发送指令(这是我们设备的一个指令,由于现在iOS不能直接获取蓝牙mac地址了,我们设备的厂家就写了一个指令来获取,这个指令是自定义的,不适用于其他设备,方法通用)
 */
+(void)cbGetMacID:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    //测试先这样 68:96:7B:ED:4D:29
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

#pragma mark 数据转换
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

//将传入的NSData类型转换成NSString并返回
+ (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

//将传入的NSString类型转换成ASCII码并返回
+ (NSData*)dataWithString:(NSString *)string{
    unsigned char *bytes = (unsigned char *)[string UTF8String];
    NSInteger len = string.length;
    return [NSData dataWithBytes:bytes length:len];
}
#pragma mark   生成发送数据
//生成数据包
+ (NSData *)getDataPacketWith:(NSString *)str{
    //字符串补零操作
    NSString *lengthDomainStr = [NSString stringWithFormat:@"%lu",(unsigned long)str.length];
    lengthDomainStr = [CNBlueCommunication addZero:lengthDomainStr withLength:3];

    //校验位计算
    NSString *verifyStr;
    const char *lengthD = [lengthDomainStr UTF8String];//定义一个指向字符常量的指针
    const char *dataD = [str UTF8String];//定义一个指向字符常量的指针
    int sumChar = 0;
    //注意：计算字符串所占的字节数（包括串尾的串结束符'\0'在内)
    for (int i = 0; i<sizeof(lengthD)-1; i++) {
        sumChar += lengthD[i];
    }
    for (int i = 0; i<sizeof(dataD)-1; i++) {
        sumChar += dataD[i];
    }
    sumChar = sumChar % 128;//ascii码一共128个
    if (sumChar < 32) {
        //0x20 避开控制符
        sumChar = sumChar + 32;
    }
    //十进制转ascii 或者说char
    verifyStr = [NSString stringWithFormat:@"%c",sumChar];
    
    //mac地址
    NSString *macAddress = [CommonData sharedCommonData].macAddress;
    
    //拼接数据包
    NSString *packetName = @"BL";
    NSString *dataPacketStr = [NSString stringWithFormat:@"%@%@%@%@%@",packetName,macAddress,lengthDomainStr,str,verifyStr];
    NSData *data = [dataPacketStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

//字符串补零操作
+(NSString *)addZero:(NSString *)str withLength:(int)length{
    NSString *string = nil;
    if (str.length==length) {
        return str;
    }
    if (str.length<length) {
        NSUInteger inter = length-str.length;
        for (int i=0;i< inter; i++) {
            string = [NSString stringWithFormat:@"0%@",str];
            str = string;
        }
    }
    return string;
}
#pragma mark   解析响应数据
+ (NSDictionary *)parseResponseDataWithParameter:(NSData *)data withType:(ResponseEnum)type{
    //模拟同步回执
    NSString *str = @"BLD2B14CBB2ED70048010]";
    NSData *myData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *responseString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseString);
    return nil;

    switch (type) {
        case ENAutoSynchro:{
            //自动同步
            
            break;
        }
        case ENLock:{
            //开锁
            break;
        }
        case ENChangeNameAndPwd:{
            //广播名称及配对密码修改
            break;
        }
        case ENLookLockLog:{
            //开锁记录查询
            break;
        }
        case ENLookHasPair:{
            //已配对设备查询
            break;
        }
        case ENUnpair:{
            //解除配对
            break;
        }
        case ENLockStateReport:{
            //锁具状态上报
            break;
        }
        default:
            break;
    }
}
@end
