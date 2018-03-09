//
//  CNBlueCommunication.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNBlueCommunication.h"
#import "CommonData.h"
#import "RespondModel.h"
#import "BlueHelp.h"
#import "CNDataBase.h"

static CBCharacteristic *blCharacteristic = nil;
static respondBlock openLogBlock;
static respondBlock lockStateBlock;
static respondBlock modifyPwdBlock;
static respondBlock pairedLockLogBlock;
static respondBlock unpairBlock;
static periConnectedStateBlock periStateBlock;

@implementation CNBlueCommunication

+ (void)initCharacteristic:(CBCharacteristic *)chara{
    if (blCharacteristic == nil) {
        blCharacteristic = chara;
    }
}

+(void)monitorLockState:(respondBlock)lockState{
    lockStateBlock = lockState;
}

+(void)monitorPeriConnectedState:(periConnectedStateBlock)periConnectedState{
    periStateBlock = periConnectedState;
}

#pragma mark 生成自定义mac地址
//一个手机只调一次，此方法生成的地址将保存到钥匙串keychain
+(NSString *)makeMyBlueMacAddress{
    //uuid：D2C82D25-B100-4C44-BB0B-2ED76AF43304
    //自定义mac地址：D2B14CBB2ED7
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
#pragma mark ----------发送数据-------------
+ (void)cbSendInstruction:(InstructionEnum)instruction toPeripheral:(CBPeripheral *)peripheral otherParameter:(id)para finish:(respondBlock)finish{
    if (blCharacteristic == nil || peripheral == nil) {
        return;
    }
    CNPeripheralModel *localModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:peripheral.identifier.UUIDString];
    switch (instruction) {
        case ENAutoLogin:{
            //自动登录
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"00"];
            [dataStr appendString:[BlueHelp getCurDateByBCDEncode]];
            if(localModel){
                //已配对
                NSLog(@"已配对");
                [dataStr appendString:localModel.isTouchUnlock?@"1":@"0"];
                [dataStr appendString:localModel.periPwd];
                //获取密码方式
                [dataStr appendString:@"0"];
                [dataStr appendString:[BlueHelp getCurDeviceName]];
            }else{
                //新配对
                NSLog(@"新配对");
                [dataStr appendString:@"0"];
                for (NSDictionary *dic in [CommonData sharedCommonData].deviceInfoArr) {
                    CBPeripheral *lock = [dic objectForKey:@"device"];
                    if ([lock.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                        NSString *pwdStr = [dic objectForKey:@"pwd"];
                        if (pwdStr) {
                            [dataStr appendString:pwdStr];
                        }
                        break;
                    }
                }
                //获取密码方式
                [dataStr appendString:@"1"];
                [dataStr appendString:[BlueHelp getCurDeviceName]];
            }
            NSData *data = [self getDataPacketWith:dataStr];
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENOpenLock:{
            //开锁
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"01"];
            NSData *data = [self getDataPacketWith:dataStr];
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENChangeNameAndPwd:{
            //广播名称及配对密码修改
            modifyPwdBlock = finish;
            CNPeripheralModel *model = [[CNDataBase sharedDataBase] searchPeripheralInfo:peripheral.identifier.UUIDString];
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"05"];
            [dataStr appendString:model.periname];
            [dataStr appendString:model.periPwd];
            NSData *data = [self getDataPacketWith:dataStr];
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENLookLockLog:{
            //开锁记录查询
            openLogBlock = finish;
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"06"];
            [dataStr appendString:[BlueHelp getCurDateByBCDEncode]];
            NSData *data = [self getDataPacketWith:dataStr];
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENLookHasPair:{
            //已配对设备查询
            pairedLockLogBlock = finish;
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"07"];
            NSData *data = [self getDataPacketWith:dataStr];
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENUnpair:{
            //解除配对
            unpairBlock = finish;
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"08"];
            [dataStr appendString:para];
            NSData *data = [self getDataPacketWith:dataStr];
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENLockStateReport:{
            //app回执
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"C0"];
            [dataStr appendString:@"1"];
            NSData *data = [self getDataPacketWith:dataStr];
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        default:
            break;
    }
}

+ (void)cbSendData:(NSData *)data toPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic{
    CBCharacteristicWriteType type = CBCharacteristicWriteWithoutResponse;
    if (characteristic.properties & CBCharacteristicPropertyWrite){
        type = CBCharacteristicWriteWithResponse;
    }
    [peripheral readValueForCharacteristic:characteristic];
    [peripheral writeValue:data forCharacteristic:characteristic  type:type];
}
/*
 关于写数据
 CBCharacteristicWriteWithResponse方法给外围设备写数据时，会回调 其代理的peripheral:didWriteValueForCharacteristic:error:方法。
 */
+ (void)cbSendStringCon:(NSString *)str toPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic{
    if (characteristic){
        CBCharacteristicWriteType type = CBCharacteristicWriteWithoutResponse;
        if (characteristic.properties & CBCharacteristicPropertyWrite){
            type = CBCharacteristicWriteWithResponse;
        }
        [peripheral readValueForCharacteristic:characteristic];
        NSData *rdata = [CNBlueCommunication getDataPacketWith:str];
        [peripheral writeValue:rdata forCharacteristic:characteristic  type:type];
    }
}
//生成数据包
+ (NSData *)getDataPacketWith:(NSString *)str{
    
    //字符串补零操作
    NSString *lengthDomainStr = [NSString stringWithFormat:@"%lu",(unsigned long)str.length];
    lengthDomainStr = [CNBlueCommunication addZero:lengthDomainStr withLength:4];
    
    //涉及到汉子放弃这种办法
    //校验位计算
//    NSString *verifyStr;
//    const char *lengthD = [lengthDomainStr UTF8String];//定义一个指向字符常量的指针
//    const char *dataD = [str UTF8String];//定义一个指向字符常量的指针
//    int sumChar = 0;
//    for (int i = 0; i<strlen(lengthD); i++) {
//        sumChar += lengthD[i];
//    }
//    for (int i = 0; i<strlen(dataD); i++) {
//        NSLog(@">>>>%d",dataD[i]);
//        sumChar += dataD[i];
//    }
//    sumChar = sumChar % 128;//ascii码一共128个
//    if (sumChar < 32) {
//        //0x20 避开控制符
//        sumChar = sumChar + 32;
//    }
//
//    //十进制转ascii 或者说char
//    verifyStr = [NSString stringWithFormat:@"%c",sumChar];
    
    //mac地址
    NSString *macAddress = [CommonData sharedCommonData].macAddress;
    
    //拼接数据包
    NSString *packetName = @"BL";
    //转化为data、再计算校验位
    //NSString *dataPacketStr = [NSString stringWithFormat:@"%@%@%@%@%@",packetName,macAddress,lengthDomainStr,str,verifyStr];
    NSString *dataPacketStr = [NSString stringWithFormat:@"%@%@%@%@",packetName,macAddress,lengthDomainStr,str];
    
    //拼接校验位
    NSData *data = [dataPacketStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mData = [[NSMutableData alloc] initWithData:data];
    Byte *bytes = (Byte *)[data bytes];
    int checkNum = 0;
    for(int i=14;i<[data length];i++){
        checkNum += bytes[i];
    }
    checkNum = checkNum % 128;//ascii码一共128个
    Byte checkBytes[] = {checkNum};
    [mData appendBytes:checkBytes length:1];
    return mData;
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
#pragma mark ----------读取数据-------------
+(void)cbReadData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic{
    
    RespondModel *respondModel = [self parseResponseDataWithParameter:data];

    if (respondModel) {
        switch (respondModel.type) {
            case ENAutoLogin:{
                //自动登录
                CNPeripheralModel *periModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:peripheral.identifier.UUIDString];
                if ([respondModel.state intValue] == 0) {
                    //登录成功
                    [[CommonData sharedCommonData].reportIDArr removeObject:peripheral.identifier.UUIDString];
                    if (!periModel) {
                        [CNPromptView showStatusWithString:@"Lock Paired"];
                        //连接上设备，数据本地保存
                        CNPeripheralModel *periModel = [[CNPeripheralModel alloc] init];
                        periModel.periID = peripheral.identifier.UUIDString;
                        periModel.periname = peripheral.name;
                        periModel.isAdmin = [respondModel.isadmin intValue];
                        for (NSDictionary *dic in [CommonData sharedCommonData].deviceInfoArr) {
                            CBPeripheral *lock = [dic objectForKey:@"device"];
                            if ([lock.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                                NSString *pwdStr = [dic objectForKey:@"pwd"];
                                if (pwdStr) {
                                    periModel.periPwd = pwdStr;
                                }
                            }
                            
                        }            
                        periModel.lockState = respondModel.lockState;
                        [[CNDataBase sharedDataBase] addPeripheralInfo:periModel];
                    }else{
                        periModel.periID = peripheral.identifier.UUIDString;
                        periModel.periname = peripheral.name;
                        periModel.isAdmin = [respondModel.isadmin intValue];
                        periModel.lockState = respondModel.lockState;
                        //密码修改、重新输入密码正确
                        for (NSDictionary *dic in [CommonData sharedCommonData].deviceInfoArr) {
                            CBPeripheral *lock = [dic objectForKey:@"device"];
                            if ([lock.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                                NSString *pwdStr = [dic objectForKey:@"pwd"];
                                if (pwdStr) {
                                    periModel.periPwd = pwdStr;
                                }
                            }
                            
                        }
                        [[CNDataBase sharedDataBase] updatePeripheralInfo:periModel];
                    }
                    if (periStateBlock) {
                        periStateBlock(peripheral, YES, NO, NO);
                    }
                }else if([respondModel.state intValue] == 1){
                    //自动登录失效，需要用户重新手动输入密码
                    if (periStateBlock) {
                        periStateBlock(peripheral, NO, NO, YES);
                    }
                }else if([respondModel.state intValue] == 2){
                    //(配对)密码错误
                    [CNPromptView showStatusWithString:@"Lock Unpaired"];
                    if (periStateBlock) {
                        periStateBlock(peripheral, NO, NO, NO);
                    }
                }else{
                    //密码正确但同步失败
                    if (periStateBlock) {
                        periStateBlock(peripheral, YES, YES, NO);
                    }
                }
                break;
            }
            case ENOpenLock:{
                //开锁
                if ([respondModel.state intValue] == 1) {
                    [CNPromptView showStatusWithString:@"Lock is Open"];
                    //更新列表状态
                    if (lockStateBlock) {
                        respondModel.lockIdentifier = peripheral.identifier.UUIDString;
                        lockStateBlock(respondModel);
                    }
                }else{
                    
                }
                break;
            }
            case ENChangeNameAndPwd:{
                //广播名称及配对密码修改
                if (modifyPwdBlock) {
                    modifyPwdBlock(respondModel);
                }
                break;
            }
            case ENLookLockLog:{
                //开锁记录查询
                if (openLogBlock) {
                    openLogBlock(respondModel);
                }
                break;
            }
            case ENLookHasPair:{
                //已配对设备查询
                if (pairedLockLogBlock) {
                    pairedLockLogBlock(respondModel);
                }
                break;
            }
            case ENUnpair:{
                //解除配对
                if (unpairBlock) {
                    unpairBlock(respondModel);
                }
                break;
            }
            case ENLockStateReport:{
                //锁具状态上报
                if (lockStateBlock) {
                    respondModel.lockIdentifier = peripheral.identifier.UUIDString;
                    lockStateBlock(respondModel);
                }
                [self cbSendInstruction:ENLockStateReport toPeripheral:peripheral otherParameter:nil finish:nil];
                break;
            }
            default:
                break;
        }
    }
}

/*
 问题1、时间是17个字节吧？
 问题2、已配对设备查询、开锁记录上传 数据有丢失问题？
 问题3、汉子占三个字节，已配对设备查询目前限制10个字节
 问题4、开锁记录上传中的开锁方式RFID、触摸、APP操作  ID指？
 */
//解析锁具发给app的数据
+ (RespondModel *)parseResponseDataWithParameter:(NSData *)myData{
    /*
     -----⭐️------假数据测试------⭐️-----
     假设D2B14CBB2ED7是锁mac地址
     
     同步：成功、锁开        BL D2B14CBB2ED7 004 8010 ]
     开锁请求回执：成功      BLD2B14CBB2ED7 003 811 -
     修改回执：成功  BL D2B14CBB2ED7 003 851 1
     开锁记录查询: 逐条上传，直到状态码为0
     BL D2B14CBB2ED7 033 861118/02/04/09/35/40AABBCCDDEEFF f
     已配对设备查询：
     BL D2B14CBB2ED7 025 871AABBCCDDEEFFLOCKNAME空格空格 w
     解除配对：
     BL D2B14CBB2ED7 003 881 4
     锁具状态上报
     BL D2B14CBB2ED7 003 401 (
     */
    
    //debug 计算校验位
    //NSArray *array = @[@"0048010", @"003811", @"003851", @"033861118/02/04/09/35/40AABBCCDDEEFF", @"025 871AABBCCDDEEFFLOCKNAME  ", @"003881", @"003401"];
    //for (NSString *string in array) {
        //NSString *stringTemp = [CNBlueCommunication getCheckCode:string];
        //NSLog(@"===%@===",stringTemp);
    //}
    
    //debug
    //示例： 同步回执 BLD2B14CBB2ED70048010]——》“BL D2B14CBB2ED7 0048010 ]”
    //假数据
    NSString *str1 = @"80101";//同步成功
    NSString *str2 = @"811";//开锁请求回执
    NSString *str3 = @"851";//名称密码修改回执
    NSString *curTime = [BlueHelp getCurDateByBCDEncode];
    NSString *str4 = [NSString stringWithFormat:@"8613%@aabbccddeeff",curTime];//开锁记录查询
    NSString *str5 = @"871aabbccddeeff000000name";//已配对设备查询上传
    NSString *str6 = @"881";//解除配对关系回执
    NSString *str7 = @"401";//上报锁具状态
  
    NSString *str8 = @"80001";//同步成功

    int temp = 1;
    switch (temp) {
        case 1:
            myData = [self getDataPacketWith:str1];
            break;
        case 2:
            myData = [self getDataPacketWith:str2];
            break;
        case 3:
            myData = [self getDataPacketWith:str3];
            break;
        case 4:
            myData = [self getDataPacketWith:str4];
            break;
        case 5:
            myData = [self getDataPacketWith:str5];
            break;
        case 6:
            myData = [self getDataPacketWith:str6];
            break;
        case 7:
            myData = [self getDataPacketWith:str7];
            break;
        case 8:
            myData = [self getDataPacketWith:str8];
            break;
        default:
            break;
    }
    //解析数据，暂没用校验位
    RespondModel *resModel = [[RespondModel alloc] init];
    NSString *responseString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    NSUInteger length = responseString.length;
    if (length<15) {
        return nil;
    }
    responseString = [responseString substringWithRange:NSMakeRange(14, length-14-1)];
    if (responseString.length<4) {
        return nil;
    }
    //长度域
    NSString *lengthDStr = [responseString substringWithRange:NSMakeRange(0, 4)];
    //数据域长度
    int dataDlen = [lengthDStr intValue];
    //数据域
    NSString *dataDomainStr = [responseString substringWithRange:NSMakeRange(4, responseString.length-4)];
    if (dataDomainStr.length != dataDlen) {
        return nil;
    }
    //指令码
    NSString *instructionStr = [dataDomainStr substringWithRange:NSMakeRange(0, 2)];
    if ([instructionStr isEqualToString:@"80"]) {
        //自动同步
        resModel.type = ENAutoLogin;
        resModel.state = [dataDomainStr substringWithRange:NSMakeRange(2, 1)];
        resModel.lockState = [dataDomainStr substringWithRange:NSMakeRange(3, 1)];
        resModel.isadmin = [dataDomainStr substringWithRange:NSMakeRange(4, 1)];
    }else if ([instructionStr isEqualToString:@"81"]){
        //开锁
        resModel.type = ENOpenLock;
        resModel.state = [dataDomainStr substringWithRange:NSMakeRange(2, 1)];
        resModel.lockState =  [dataDomainStr substringWithRange:NSMakeRange(2, 1)];
    }else if ([instructionStr isEqualToString:@"85"]){
        //广播名称及配对密码修改
        resModel.type = ENChangeNameAndPwd;
        resModel.state = [dataDomainStr substringWithRange:NSMakeRange(2, 1)];
    }else if ([instructionStr isEqualToString:@"86"]){
        //开锁记录查询
        resModel.type = ENLookLockLog;
        //状态码上传为0则上传完毕
        resModel.state = [dataDomainStr substringWithRange:NSMakeRange(2, 1)];
        //开锁方式 1滑动2触摸3密码
        resModel.lockMethod = [[dataDomainStr substringWithRange:NSMakeRange(3, 1)] intValue];
        //时间bcd编码
        NSString *openTimeStr = [dataDomainStr substringWithRange:NSMakeRange(4, 6)];
        resModel.date = [BlueHelp getDateWith:openTimeStr];
        resModel.IDAddress = [dataDomainStr substringWithRange:NSMakeRange(10, 12)];
    }else if ([instructionStr isEqualToString:@"87"]){
        //已配对设备查询
        resModel.type = ENLookHasPair;
        resModel.state = [dataDomainStr substringWithRange:NSMakeRange(2, 1)];
        resModel.lockMacAddress = [dataDomainStr substringWithRange:NSMakeRange(3, 12)];
        //锁具名称
        resModel.lockName = [dataDomainStr substringWithRange:NSMakeRange(15, 10)];
    }else if ([instructionStr isEqualToString:@"88"]){
        //解除配对
        resModel.type = ENUnpair;
        resModel.state = [dataDomainStr substringWithRange:NSMakeRange(2, 1)];
    }else if ([instructionStr isEqualToString:@"40"]){
        //锁具状态上报
        resModel.type = ENLockStateReport;
        resModel.lockState = [dataDomainStr substringWithRange:NSMakeRange(2, 1)];
    }
    return resModel;
}

//生成校验码 仅对ascii码有效
+ (NSString *)getCheckCode:(NSString *)lenDAndDataDStr{
    //lenDAndDataDStr为长度域和数据域的字符串
    NSString *verifyStr;
    const char *lenDAndDataD = [lenDAndDataDStr UTF8String];//定义一个指向字符常量的指针
    int sumChar = 0;
    for (int i = 0; i<strlen(lenDAndDataD); i++) {
        sumChar += lenDAndDataD[i];
    }
    sumChar = sumChar % 128;//ascii码一共128个
    if (sumChar < 32) {
        //0x20 避开控制符
        sumChar = sumChar + 32;
    }
    //十进制转ascii 或者说char
    verifyStr = [NSString stringWithFormat:@"%c",sumChar];
    return verifyStr;
}

#pragma mark ----------数据转换-------------

#pragma mark 备用
- (unsigned)parseIntFromData:(NSData *)data{
    
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    return intData;
}

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
     byte4：十六进制对应的asciii码
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

@end
