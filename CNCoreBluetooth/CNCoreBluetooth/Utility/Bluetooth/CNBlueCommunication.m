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
#include <math.h>

static CBCharacteristic *blCharacteristic = nil;
static NSMutableDictionary *blCharacteristicDic = nil;
static respondBlock autoLoginBlock;
static respondBlock openLogBlock;
static respondBlock lockStateBlock;
static respondBlock modifyPwdBlock;
static respondBlock pairedLockLogBlock;
static respondBlock unpairBlock;
static periConnectedStateBlock periStateBlock;
static NSDate  *getLoginConDate;

@implementation CNBlueCommunication

+ (void)initCharacteristic:(CBCharacteristic *)chara{
    if (blCharacteristic == nil) {
        blCharacteristic = chara;
    }
}

+(void)setCharacteristicDic:(NSMutableDictionary *)dic{
    blCharacteristicDic = dic;
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
    blCharacteristic = [blCharacteristicDic objectForKey:peripheral.identifier.UUIDString];
    if (blCharacteristic == nil || peripheral == nil) {
        return;
    }
    CNPeripheralModel *localModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:peripheral.identifier.UUIDString];
    switch (instruction) {
        case ENAutoLogin:{
            autoLoginBlock = finish;
            //自动登录
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"00"];
            [dataStr appendString:[BlueHelp getCurDateByBCDEncode]];
            if(localModel){
                //已配对
                NSLog(@"已配对");
                [dataStr appendString:localModel.isTouchUnlock?@"1":@"0"];
                //被管理员踢了或旧密码失效两种情况新输入的密码已更新到数据库
                //正常的自动登录还继续用以前的保存的旧密码
                [dataStr appendString:localModel.periPwd];
                
                BOOL isManual = NO;
                for (NSDictionary *dic in [CommonData sharedCommonData].deviceInfoArr) {
                    CBPeripheral *lock = [dic objectForKey:@"device"];
                    if ([lock.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                        isManual = YES;
                        break;
                    }
                }
                
                if(isManual){
                    //获取密码方式
                    [dataStr appendString:@"1"];
                    //delete
                    NSIndexSet *indexSet = [[CommonData sharedCommonData].deviceInfoArr indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        CBPeripheral *lock = [obj objectForKey:@"device"];
                        return [lock.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString];
                    }];
                    [[CommonData sharedCommonData].deviceInfoArr removeObjectsAtIndexes:indexSet];
                }else{
                    //获取密码方式
                    [dataStr appendString:@"0"];
                }

                [dataStr appendString:[BlueHelp getCurDeviceName]];
            }else{
                //新配对
                NSLog(@"新配对");
                [dataStr appendString:@"0"];
                NSString *pwdStr = @"000000";
                for (NSDictionary *dic in [CommonData sharedCommonData].deviceInfoArr) {
                    CBPeripheral *lock = [dic objectForKey:@"device"];
                    if ([lock.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                        pwdStr = [dic objectForKey:@"pwd"];
                        break;
                    }
                }
                [dataStr appendString:pwdStr];
                //获取密码方式
                [dataStr appendString:@"1"];
                [dataStr appendString:[BlueHelp getCurDeviceName]];
            }
            NSData *data = [self getDataPacketWith:dataStr];
            NSLog(@"======%@",dataStr);
            NSLog(@"======%@",data);
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENOpenLock:{
            //开锁
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"01"];
            NSData *data = [self getDataPacketWith:dataStr];
            NSLog(@"%@",dataStr);
            NSLog(@"%@",data);
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENChangeNameAndPwd:{
            //广播名称及配对密码修改
            modifyPwdBlock = finish;
            CNPeripheralModel *model = (CNPeripheralModel *)para;
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"05"];
            [dataStr appendString:[BlueHelp adjustLockDeviceName:model.periname]];
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
            NSString *str = para;
            [dataStr appendString:[BlueHelp getLastDateAboutLog:str]];
            NSData *data = [self getDataPacketWith:dataStr];
            NSLog(@"%@",dataStr);
            NSLog(@"%@",data);
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENLookHasPair:{
            //已配对设备查询
            pairedLockLogBlock = finish;
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"07"];
            NSData *data = [self getDataPacketWith:dataStr];
            NSLog(@"%@",dataStr);
            NSLog(@"%@",data);
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
            NSLog(@"%@",dataStr);
            NSLog(@"%@",data);
            [self cbSendData:data toPeripheral:peripheral withCharacteristic:blCharacteristic];
            break;
        }
        case ENLockStateReport:{
            //app回执
            NSMutableString *dataStr = [[NSMutableString alloc] init];
            [dataStr appendString:@"C0"];
            [dataStr appendString:@"1"];
            NSData *data = [self getDataPacketWith:dataStr];
            NSLog(@"%@",dataStr);
            NSLog(@"%@",data);
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
    /*
     该方法执行，代理方法
     -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
     立马响应
     */
    //lyh debug
    //[peripheral readValueForCharacteristic:characteristic];
    [peripheral writeValue:data forCharacteristic:characteristic  type:type];
}

//生成数据包
+ (NSData *)getDataPacketWith:(NSString *)str{
    
    //字符串补零操作
    NSString *lengthDomainStr = [NSString stringWithFormat:@"%lu",(unsigned long)str.length];
    //lyh 重写
    NSData *lengthData = [str dataUsingEncoding:NSUTF8StringEncoding];
    lengthDomainStr = [NSString stringWithFormat:@"%lu",(unsigned long)lengthData.length];
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
    if (checkNum < 32) {
        checkNum += 32;
    }
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
    if (respondModel == nil) {
        return;
    }
    
    if (respondModel) {
        switch (respondModel.type) {
            case ENAutoLogin:{
                //自动登录
                CNPeripheralModel *periModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:peripheral.identifier.UUIDString];
                if ([respondModel.state intValue] == 0) {
                    //登录成功
                    [[CommonData sharedCommonData].reportIDArr removeObject:peripheral.identifier.UUIDString];
                    if (!periModel) {
                        //连接上设备，数据本地保存
                        CNPeripheralModel *periModel = [[CNPeripheralModel alloc] init];
                        periModel.periID = peripheral.identifier.UUIDString;
                        if(respondModel.lockName){
                            periModel.periname = respondModel.lockName;
                        }else{
                            periModel.periname = [peripheral.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            periModel.periname = [peripheral.name stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                        }
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
                        if(respondModel.lockName){
                            periModel.periname = respondModel.lockName;
                        }else{
                            periModel.periname = [peripheral.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            periModel.periname = [peripheral.name stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                        }
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
                    if(respondModel.lockName){
                        periModel.periname = respondModel.lockName;
                        [[CNDataBase sharedDataBase] updatePeripheralInfo:periModel];
                    }
                }else if([respondModel.state intValue] == 2){
                    if (!periModel) {
                        //配对密码错误
                        [CNPromptView showStatusWithString:@"Incorrect Password"];
                        if (periStateBlock) {
                            periStateBlock(peripheral, NO, NO, NO);
                        }
                    }else{
                        //别人改变密码了重新输密码
                        if (periStateBlock) {
                            periStateBlock(peripheral, NO, NO, YES);
                        }
                    }
                    if(respondModel.lockName){
                        periModel.periname = respondModel.lockName;
                        [[CNDataBase sharedDataBase] updatePeripheralInfo:periModel];
                    }
                }else{
                    //密码正确但同步失败
                    if (periStateBlock) {
                        periStateBlock(peripheral, YES, YES, NO);
                    }
                }
                if (autoLoginBlock) {
                    autoLoginBlock(respondModel);
                }
                break;
            }
            case ENOpenLock:{
                //开锁
                if ([respondModel.state intValue] == 1) {
                    [CNPromptView showStatusWithString:@"Lock is Open"];
                    //主动调锁状态回调 更新列表
                    if (lockStateBlock) {
                        respondModel.lockIdentifier = peripheral.identifier.UUIDString;
                        lockStateBlock(respondModel);
                    }
                }else{
                    //lyh 开锁失败
                    //[CNPromptView showStatusWithString:@"Lock is Open"];
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
                //开锁日志查询
                if (openLogBlock) {
                    openLogBlock(respondModel);
                }
                break;
            }
            case ENLookHasPair:{
                //登录设备查询
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

+ (RespondModel *)parseResponseDataWithParameter:(NSData *)myData{
    //假数据
    NSString *str1 = @"80001";//同步成功
    NSString *str2 = @"811";//开锁请求回执
    NSString *str3 = @"851";//名称密码修改回执
    NSString *curTime = [BlueHelp getCurDateByBCDEncode];
    NSString *str4 = [NSString stringWithFormat:@"8613%@aabbccddeeff",curTime];//开锁记录查询
    NSString *str5 = @"871aabbccddeeffname      ";//已配对设备查询上传
    NSString *str6 = @"881";//解除配对关系回执
    NSString *str7 = @"401";//上报锁具状态
    
    NSString *str8 = @"80001";//同步成功
    //lyh debug
    int temp = 1000;
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
    //---------------过滤data获得有效数据------------------
    Byte *bytes = (Byte *)[myData bytes];
    //过滤BL之前的数据
    for (int i = 0; i < myData.length; i++) {
        if (bytes[i] == 66 && bytes[i+1] == 76) {
            myData = [myData subdataWithRange:NSMakeRange(i, myData.length-i)];
            break;
        }
    }
    bytes = (Byte *)[myData bytes];
    //根据数据域长度计算有效数据
    int dataLength = 0;
    for (int i = 14; i < 18; i++) {
        dataLength += (bytes[i]-48)*pow(10, 17-i);
    }
    //获取有效数据域
    int totalLength = 2+12+4+dataLength+1;
    if (myData.length >= totalLength) {
        myData = [myData subdataWithRange:NSMakeRange(0, totalLength)];
    }
    //--------------------解析有效数据包------------------
    if(myData.length < 18+dataLength){
        return nil;
    }
    //获取数据域
    NSData *dataDomain = [myData subdataWithRange:NSMakeRange(18, dataLength)];
    //指令码
    NSString *instructionStr = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(0, 2)]];
    RespondModel *resModel = [[RespondModel alloc] init];
    if ([instructionStr isEqualToString:@"80"]) {
        //自动同步
        resModel.type = ENAutoLogin;
        resModel.state = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(2, 1)]];
        resModel.lockState = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(3, 1)]];
        resModel.isadmin = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(4, 1)]];
        resModel.lockName = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(5, 18)]];
        resModel.lockName = [resModel.lockName stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        resModel.lockName = [resModel.lockName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }else if ([instructionStr isEqualToString:@"81"]){
        //开锁
        resModel.type = ENOpenLock;
        resModel.state = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(2, 1)]];
        //锁状态跟state参数对应，稍后用来进行锁状态回调
        resModel.lockState = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(2, 1)]];
    }else if ([instructionStr isEqualToString:@"85"]){
        //广播名称及配对密码修改
        resModel.type = ENChangeNameAndPwd;
        resModel.state = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(2, 1)]];
    }else if ([instructionStr isEqualToString:@"86"]){
        //开锁记录查询
        resModel.type = ENLookLockLog;
        //状态码上传为0则上传完毕
        resModel.state = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(2, 1)]];
        //开锁方式 1RFID2触摸3APP
        resModel.lockMethod = [[self stringFromData:[dataDomain subdataWithRange:NSMakeRange(3, 1)]] intValue];
        //时间bcd编码
        NSString *openTimeStr = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(4, 6)]];
        resModel.date = [BlueHelp getDateWith:openTimeStr];
        resModel.IDAddress = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(10, 12)]];
    }else if ([instructionStr isEqualToString:@"87"]){
        //已配对设备查询
        resModel.type = ENLookHasPair;
        resModel.state = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(2, 1)]];
        resModel.lockMacAddress = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(3, 12)]];
        NSString *appName = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(15, 20)]];;
        resModel.appName = [appName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }else if ([instructionStr isEqualToString:@"88"]){
        //解除配对
        resModel.type = ENUnpair;
        resModel.state = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(2, 1)]];
    }else if ([instructionStr isEqualToString:@"40"]){
        //锁具状态上报
        resModel.type = ENLockStateReport;
        resModel.lockState = [self stringFromData:[dataDomain subdataWithRange:NSMakeRange(2, 1)]];
    }
    return resModel;
}

+ (NSString *)stringFromData:(NSData *)data{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

/*
 汉子占三个字节，已配对设备查询目前限制10个字节
 */
//（弃用）解析锁具发给app的数据
+ (RespondModel *)debugParseResponseDataWithParameter:(NSData *)myData{
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
    NSString *str1 = @"80001";//同步成功
    NSString *str2 = @"811";//开锁请求回执
    NSString *str3 = @"851";//名称密码修改回执
    NSString *curTime = [BlueHelp getCurDateByBCDEncode];
    NSString *str4 = [NSString stringWithFormat:@"8613%@aabbccddeeff",curTime];//开锁记录查询
    NSString *str5 = @"871aabbccddeeffname      ";//已配对设备查询上传
    NSString *str6 = @"881";//解除配对关系回执
    NSString *str7 = @"401";//上报锁具状态
  
    NSString *str8 = @"80001";//同步成功
    //lyh debug
    int temp = 1000;
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
    //lyh 数据域长度按字节取避免汉子出现问题
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
        //开锁方式 1RFID2触摸3APP
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
        NSString *appName = [dataDomainStr substringWithRange:NSMakeRange(15, 10)];
        resModel.appName = [appName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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

#pragma mark -------备用---数据转换-------------
//传入data：<12> 返回18
+ (unsigned)parseIntFromData:(NSData *)data{
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    return intData;
}
//传入12 返回3132
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        //      %x(%X)      十六进制整数0f(0F)   e.g.   0x1234
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

////传入12 返回3132
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
//传入12  返回<3132>
+ (NSData*)dataWithString:(NSString *)string{
    const char *bytes = [string UTF8String];
//    NSInteger len = string.length;
//    NSInteger len1 = sizeof(bytes);
    NSInteger len2 = strlen(bytes);
    NSData *data = [NSData dataWithBytes:bytes length:len2];
    return data;
}

/*  蓝牙mac地址
 app向蓝牙发送指令(这是我们设备的一个指令,由于现在iOS不能直接获取蓝牙mac地址了,我们设备的厂家就写了一个指令来获取,这个指令是自定义的,不适用于其他设备,方法通用)
 */
+(void)cbGetMacID:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    //测试先这样 68:96:7B:ED:4D:29
//    NSLog(@"MAC地址");
//    Byte b[] = {0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0};
//    NSData *data = [NSData dataWithBytes:&b length:8];
//    [CNBlueCommunication writePeripheral:peripheral characteristic:characteristic value:data];
}


@end
