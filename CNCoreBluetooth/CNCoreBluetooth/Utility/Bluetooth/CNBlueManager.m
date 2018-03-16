//
//  CNBlueMannager.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNBlueManager.h"
#import "SVProgressHUD.h"
#import "CNBlueCommunication.h"
#import "CNDataBase.h"

@interface CNBlueManager(){
    scanFinishBlock _scanFinished;
}
/** 设备特征值*/
@property (nonatomic, strong) CBCharacteristic *uartRXCharacteristic;
//上锁和解锁的characteristic
@property (nonatomic, strong) CBCharacteristic* lockUnlockCharacteristic;

@end
/*
 操作细节探讨
 
 1、蓝牙中心管理器扫描广播包，时长可以自己写一个定时器控制，并且可以设定扫描的具体条件
 
 2、当然在正常连接的过程中总会出现点意外，如果两个设备突然断掉了连接，一般我们还是希望它们能够再次连接的，这里就得要看硬件和程序里对于连接断开的处理代码了
 
 */
@implementation CNBlueManager

+(CNBlueManager *)sharedBlueManager{
    //lyh
    static dispatch_once_t onceToken;
    static CNBlueManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[CNBlueManager alloc] init];
        //lyh queue
        //dispatch_queue_t centralQueue = dispatch_queue_create("no.nordicsemi.ios.nrftoolbox", DISPATCH_QUEUE_SERIAL);
        
        //扫描设备时,不扫描到相同设备,这样可以节约电量,提高app性能.如果需求是需要实时获取设备最新信息的,那就需要设置为YES.
        //CBCentralManagerScanOptionAllowDuplicatesKey,key值是NSNumber,默认值为NO表示不会重复扫描已经发现的设备,如需要不断获取最新的信号强度RSSI所以一般设为YES了
        //manager.mgr = [[CBCentralManager alloc] initWithDelegate:manager queue:dispatch_get_main_queue() options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
        //CBCentralManagerOptionShowPowerAlertKey 初始化，如果是否弹框提示打开蓝牙。NO不提示
        manager.mgr = [[CBCentralManager alloc] initWithDelegate:manager queue:dispatch_get_main_queue()];
        manager.peripheralArray = [NSMutableArray array];
        manager.connectedPeripheralArray = [NSMutableArray array];
        manager.connectedLockIDArray = [NSMutableArray array];
        manager.unConnectedLockIDArray = [NSMutableArray array];
    });
    return manager;
}
/*

 //如果只想扫描到特定设备,
 //包含一个符合服务的设备即可被搜索到
 CBUUID *uuid01 = [CBUUID UUIDWithString:SeriveID6666];
 CBUUID *uuid02 = [CBUUID UUIDWithString:SeriveID7777];
 NSArray *serives = [NSArray arrayWithObjects:uuid01, uuid02, nil];
 [_cbManager scanForPeripheralsWithServices:serives options:nil];
 
 //可在没必要描外设时，取消扫描
 
 */

- (BOOL)isConnectedAllPairedPeripheral{
    //查看是否将所有已配对设备连接
    BOOL isAllPaired = YES;
    NSMutableArray *lockIDArr = [NSMutableArray arrayWithArray:[[CNDataBase sharedDataBase] searchAllPariedPeriID]];
    _unConnectedLockIDArray = [NSMutableArray array];
    for (NSString *lockID in lockIDArr) {
        if (![_connectedLockIDArray containsObject:lockID]) {
            isAllPaired = NO;
            [_unConnectedLockIDArray addObject:lockID];
        }
    }
    return isAllPaired;
}

- (void)connectAllPairedLock{
    if (![self isConnectedAllPairedPeripheral]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *periID in _unConnectedLockIDArray) {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:periID];
            [array addObject:uuid];
        }
        NSArray *retrieveArr = [_mgr retrievePeripheralsWithIdentifiers:array];
        for (CBPeripheral *peripheral in retrieveArr) {
            if (![self.peripheralArray containsObject:peripheral]) {
                [self.peripheralArray addObject:peripheral];
            }
            [self cus_connectPeripheral:peripheral];
        }
    }
}

#pragma mark public API   扫描设备、停止扫描、连接设备、取消连接
// 开始扫描❤️广播包
-(void)cus_beginScanPeriPheralFinish:(scanFinishBlock)finish{
    _scanFinished = finish;
    CBUUID *lockService = [CBUUID UUIDWithString:@"FFE0"];
    //过滤  @[lockService]
    [self.mgr scanForPeripheralsWithServices:@[lockService] options:nil];
}

- (void)cus_stopScan{
    [self.mgr stopScan];
}

-(void)cus_connectPeripheral:(CBPeripheral *)peri{
    //lyh  warning
    if (@available(iOS 10.0, *)) {
        if (self.mgr.state != CBManagerStatePoweredOn) {
            [CNPromptView showStatusWithString:@"Turn On Bluetooth"];
            return;
        }
    } else {
        // Fallback on earlier versions
    }
    
    if (peri.state == CBPeripheralStateDisconnected) {
        NSLog(@"🔑🔑🔑🔑🔑🔑🔑正在连接设备 ： %@",peri.name);
        [self.mgr connectPeripheral:peri options:nil];
    }
}

-(void)cus_cancelConnectPeripheral:(CBPeripheral *)peri{
    NSLog(@"取消连接设备 ： %@",peri.name);
    if (peri.state == CBPeripheralStateConnected) {
        [self.mgr cancelPeripheralConnection:peri];
    }
}

//#pragma mark 数据交互
//- (void)senddata:(NSString *)str toPeripheral:(CBPeripheral *)peri{
//    
//    [CNBlueCommunication cbSendStringCon:str toPeripheral:peri withCharacteristic:self.uartRXCharacteristic];
//}

#pragma mark private API
//订阅特征
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    
    if (characteristic.properties & CBCharacteristicPropertyNotify) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        //设置通知后,进入代理方法:
        //- peripheral: didUpdateNotificationStateForCharacteristic: characteristic error:
    }
}
//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

#pragma mark   CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>蓝牙未知状态");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>蓝牙重启");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>不支持蓝牙");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>未授权");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>蓝牙关闭");
            break;
        case CBCentralManagerStatePoweredOn:{
            NSLog(@">>>蓝牙打开");
            //扫描已配对的设备（从后台唤醒会自动走该方法）

            /*
             自动连接方案一：扫描周围设备，根据本地本地配对记录，连接
             自动连接方案二：根据本地记录已配对设备id，retrievePeripheralsWithIdentifiers返回peripheral，逐一连接
             自动连接方案二：前两种结合
             第一种比较稳定，会慢？
             第二种retrievePeripheralsWithIdentifiers方法是否可靠
             */
            
            //自动连接所有已配对的设备
            [self connectAllPairedLock];
            
            break;
        }
        default:
            break;
    }
}
/**
 发现外围设备
 peripheral：外围设备
 advertisementData——：相关数据
 RSSI：信号强度
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    /*
     查看❤️广播包❤️数据，advertisementData数据：
     kCBAdvDataIsConnectable = 1;
     kCBAdvDataLocalName = 666;
     kCBAdvDataServiceUUIDs = (
        1000
     );
     */
    
    //scanForPeripheralsWithServices扫描的时候已经进行过滤操作过滤
    NSLog(@"=======发现外围设备=======%@",peripheral);
    if (![self.peripheralArray containsObject:peripheral]) {
        [self.peripheralArray addObject:peripheral];
    }
    
    //发现从未自动登录过的设备然后回调
    CNPeripheralModel *periModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:peripheral.identifier.UUIDString];
    if (periModel == nil) {
        if (_scanFinished) {
            _scanFinished(peripheral);
            //一次只扫一个
            //[self cus_stopScan];
        }
    }
    
    //改为自动登录后，此处条件不合理（匹配密码输入错误，未真正意义上匹配过，这里将不会回调）
//    if (![_unConnectedLockIDArray containsObject:peripheral.identifier.UUIDString] && ![_connectedLockIDArray containsObject:peripheral.identifier.UUIDString]) {
//        if (_scanFinished) {
//            _scanFinished(peripheral);
//            _curPeri = peripheral;
//            //一次只扫一个
//            [self cus_stopScan];
//        }
//    }
}

//6、扫描服务 可传服务uuid代表指定服务，传nil代表所有服务
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"-✅✅✅✅✅✅✅✅-----和设备%@连接成功-------",peripheral.name);
    NSLog(@"设备%@报告： didConnect ->  discoverServices:nil",peripheral.name);
    peripheral.delegate = self;
    [peripheral readRSSI];
    if (![self.connectedPeripheralArray containsObject:peripheral]) {
        [self.connectedPeripheralArray addObject:peripheral];
        [self.connectedLockIDArray addObject:peripheral.identifier.UUIDString];
        if ([_unConnectedLockIDArray containsObject:peripheral.identifier.UUIDString]) {
            [_unConnectedLockIDArray removeObject:peripheral.identifier.UUIDString];
        }
        NSLog(@"扫描到的外围设备 peripheral == %@",peripheral);
    }
//放到 didDiscoverCharacteristicsForService 中了
//    if (_periConnectedState) {
//        _periConnectedState(peripheral,YES);
//    }
    [peripheral discoverServices:nil];
}
//外设连接失败时调用
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@失去连接",peripheral.name]];
    [self.connectedPeripheralArray removeObject:peripheral];
    [self.connectedLockIDArray removeObject:peripheral.identifier.UUIDString];
    [_unConnectedLockIDArray addObject:peripheral.identifier.UUIDString];
    
    if (_periConnectedState) {
        _periConnectedState(peripheral,NO,NO,NO);
    }
    
    //[self.mgr connectPeripheral:peripheral options:nil];
    NSLog(@"-❌❌❌❌❌❌❌❌-----失去和设备%@的连接-------",peripheral.name);
}

#pragma mark CBPeripheralDelegate

//7、获取指定的服务，然后根据此服务来查找特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"%@发现服务时出错: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"--------设备%@报告---didDiscoverServices---",peripheral.name);
    NSLog(@"Services == %@",peripheral.services);
    //FFE0
    for (CBService *service in peripheral.services) {
        if([service.UUID.UUIDString isEqualToString:@"FFE0"]){
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

//8、发现服务特征，根据此特征进行数据处理
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    /*characteristic.properties),可以看到有很多种,这是一个NS_OPTIONS的枚举,可以是多个值，常见的有read,write,noitfy,indicate.知道这几个基本够用了,前俩是读写权限,后俩都是通知,俩不同的通知方式。第三方的app——LightBlue方便查看属性
     */
    if (error) {
        NSLog(@"扫描特征出错:%@", [error localizedDescription]);
        return;
    }
    NSLog(@"--------设备%@报告--------",peripheral.name);
    NSLog(@"service.UUID 为 %@ 的 characteristic = %@",service.UUID,service.characteristics);
    //lyh debug
    /*
     需确认哪个server下的哪个Characteristic是读数据的（置通知,接收蓝牙实时数据）
     需确认哪个server下的哪个Characteristic是发往外设数据的
     可将两个server和Characteristic分别写为宏
     */
    for (CBCharacteristic *characteristic in service.characteristics) {
        //判断服务：避免不同服务下有相同特征？
        //FFE0    FFE1
        if ([service.UUID.UUIDString isEqualToString:@"FFE0"]) {
            //[[c UUID] isEqual:[CBUUID UUIDWithString:@"0000fff6-0000-1000-8000-00805f9b34fb"]]
            if ([characteristic.UUID.UUIDString isEqualToString:@"FFE1"]) {
                //订阅特征 可收到广播数据
                //设置通知,接收蓝牙实时数据
                [self notifyCharacteristic:peripheral characteristic:characteristic];
            }
            if([characteristic.UUID.UUIDString isEqualToString:@"FFE1"]){
                //数据发送
                self.uartRXCharacteristic = characteristic;
                [CNBlueCommunication initCharacteristic:characteristic];
            }
        }
        //描述相关的方法,代理实际项目中没有涉及到,只做了解
        //[peripheral discoverDescriptorsForCharacteristic:characteristic];
    }

    //app端自动登录成功才认为真正连接上
//    if (_periConnectedState) {
//        _periConnectedState(peripheral,YES);
//    }
    
    //自动登录
    [CNBlueCommunication cbSendInstruction:ENAutoLogin toPeripheral:peripheral otherParameter:nil finish:nil];
    //app端自动登录成功才认为真正连接上
    [CNBlueCommunication monitorPeriConnectedState:^(CBPeripheral *peripheral, BOOL isConnect, BOOL isOpenTimer, BOOL isNeedReRnterPwd) {
        if (isNeedReRnterPwd) {
            //密码失效，重新输密码
            _periConnectedState(peripheral,isConnect,isOpenTimer,isNeedReRnterPwd);
            [self.mgr cancelPeripheralConnection:peripheral];

        }else if (isConnect) {
            //自动登录成功 或者 需要开启定时器继续同步
            if (_periConnectedState) {
                _periConnectedState(peripheral,isConnect,isOpenTimer,isNeedReRnterPwd);
            }
        }else{
            //新添设备配对密码错误
            [self.mgr cancelPeripheralConnection:peripheral];
        }
    }];
    //收到锁具回应后再移除
    [[CommonData sharedCommonData].reportIDArr addObject:peripheral.identifier.UUIDString];
    
}

//---------订阅后的回调----------
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"错误: %@", error.localizedDescription);
    }
    if (characteristic.isNotifying) {
        //lyh
        //蓝牙不断开，失去连接，重新连上可以记录上次接受广播的数据characteristic.value
        //NSLog(@"notification====%@",characteristic.value);
        //[peripheral readValueForCharacteristic:characteristic];
    } else {
        NSLog(@"%@停止通知", characteristic);
    }
}

//---------接受外设数据---------
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error) {
        NSData *originData = characteristic.value;
        NSString *responseString = [[NSString alloc] initWithData:originData encoding:NSUTF8StringEncoding];
        NSLog(@"-------来自%@-------收到数据:%@",peripheral.name,originData);
        [CNBlueCommunication cbReadData:originData fromPeripheral:peripheral withCharacteristic:characteristic];;
    }
    //lyh debug
    [CNBlueCommunication cbReadData:nil fromPeripheral:peripheral withCharacteristic:characteristic];;
}
//写数据是否成功   对应  CBCharacteristicPropertyWrite
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"APP发送数据失败:%@",error.localizedDescription);
    } else {
        //lyh 要写吗
        //[self.cbperipheral readValueForCharacteristic:self.cbchar];
        NSLog(@"APP向设备发送数据成功");
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出Characteristic和他的Descriptors
//    NSLog(@"DiscoverDescriptors === characteristic uuid:%@",characteristic.UUID);
//    for (CBDescriptor *d in characteristic.descriptors) {
//        NSLog(@"Descriptor uuid:%@",d.UUID);
//        [peripheral readValueForDescriptor:d];
//    }
}

//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
//    NSLog(@"didUpdateValueForDescriptor == characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{

    NSLog(@"rssi ======  %@",[RSSI stringValue]);

}

@end
