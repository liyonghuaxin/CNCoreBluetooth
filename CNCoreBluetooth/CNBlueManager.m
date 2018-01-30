//
//  CNBlueMannager.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNBlueManager.h"

@interface CNBlueManager(){
    scanFinishBlock _scanFinished;
}
@property (nonatomic,strong) CBCentralManager *mgr;
/** 设备特征值*/
@property (nonatomic, strong) CBCharacteristic *uartRXCharacteristic;

@end

@implementation CNBlueManager

+(CNBlueManager *)sharedBlueManager{
    //lyh
    static dispatch_once_t onceToken;
    static CNBlueManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[CNBlueManager alloc] init];
        //lyh queue
        //dispatch_queue_t centralQueue = dispatch_queue_create("no.nordicsemi.ios.nrftoolbox", DISPATCH_QUEUE_SERIAL);
        manager.mgr = [[CBCentralManager alloc] initWithDelegate:manager queue:nil];
        manager.peripheralArray = [NSMutableArray array];
        manager.connectedPeripheralArray = [NSMutableArray array];
    });
    return manager;
}

#pragma mark private API

-(void)cus_beginScanPeriPheralFinish:(scanFinishBlock)finish{
    _scanFinished = finish;
    [self.mgr scanForPeripheralsWithServices:nil options:nil];
}

- (void)cus_stopScan{
    [self.mgr stopScan];
}

-(void)cus_connectPeripheral:(CBPeripheral *)peri{
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

- (void)senddata:(NSString *)str toPeripheral:(CBPeripheral *)peri{
    if (self.uartRXCharacteristic){
        //lyh type?
//        CBCharacteristicWriteType type = CBCharacteristicWriteWithoutResponse;
//        if ((self.uartRXCharacteristic.properties & CBCharacteristicPropertyWrite) > 0){
//            type = CBCharacteristicWriteWithResponse;
//        }
        NSData *rdata = [str dataUsingEncoding:NSUTF8StringEncoding];
        [peri writeValue:rdata forCharacteristic:self.uartRXCharacteristic  type:CBCharacteristicWriteWithResponse];
    }

}
#pragma mark   CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    /*
     CBManagerStateUnknown = 0,
     CBManagerStateResetting,
     CBManagerStateUnsupported,不支持
     CBManagerStateUnauthorized,
     CBManagerStatePoweredOff, 未开启
     CBManagerStatePoweredOn,
     */
    NSLog(@"state: %zd",central.state);
//    if (central.state == CBManagerStatePoweredOn) {
//        // 检索已经连接/配对设备加入外围设备数组
//    }
}
/**
 发现外围设备
 peripheral：外围设备
 advertisementData——：相关数据
 RSSI：信号强度
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    /*advertisementData数据：
     kCBAdvDataIsConnectable = 1;
     kCBAdvDataLocalName = 666;
     kCBAdvDataServiceUUIDs = (
        1000
     );
     */
    
//    过滤操作
//    if ([peripheral.name hasPrefix:@"OBand"]) {
//
//    }
    
    //3、记录扫描到的外围设备
    NSLog(@"=======发现外围设备=======");
    if (![self.peripheralArray containsObject:peripheral]) {
        [self.peripheralArray addObject:peripheral];
        //更新新发现的外设列表
        if (_scanFinished) {
            _scanFinished(peripheral);
        }
    }
    
}

//6、扫描服务 可传服务uuid代表指定服务，传nil代表所有服务
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"-✅✅✅✅✅✅✅✅-----和设备%@连接成功-------",peripheral.name);
    NSLog(@"设备%@报告： didConnect ->  discoverServices:nil",peripheral.name);
    peripheral.delegate = self;
    [peripheral readRSSI];
    if (![self.connectedPeripheralArray containsObject:peripheral]) {
        [self.connectedPeripheralArray addObject:peripheral];
        NSLog(@"扫描到的外围设备 peripheral == %@",peripheral);
    }
    if (_periConnectedState) {
        _periConnectedState(peripheral,YES);
    }
    if ([peripheral.name containsString:@"iPhone"]) {
        [peripheral discoverServices:nil];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    NSLog(@"rssi ======  %@",[RSSI stringValue]);
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@失去连接",peripheral.name]];
    [self.connectedPeripheralArray removeObject:peripheral];
    if (_periConnectedState) {
        _periConnectedState(peripheral,NO);
    }
    //[self.mgr connectPeripheral:peripheral options:nil];
    NSLog(@"-❌❌❌❌❌❌❌❌-----失去和设备%@的连接-------",peripheral.name);
}
#pragma mark CBPeripheralDelegate
//7、获取指定的服务，然后根据此服务来查找特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"--------设备%@报告---didDiscoverServices---",peripheral.name);
    NSLog(@"Services == %@",peripheral.services);
    for (CBService *service in peripheral.services) {
        if([service.UUID.UUIDString isEqualToString:@"1000"]){
            NSLog(@"discoverCharacteristics:nil forService:%@的服务",service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
//
//8、发现服务特征，根据此特征进行数据处理
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"--------设备%@报告--------",peripheral.name);
    NSLog(@"service.UUID 为 %@ 的 characteristic = %@",service.UUID,service.characteristics);
    for (CBCharacteristic *characteristic in service.characteristics) {
        if([characteristic.UUID.UUIDString isEqualToString:@"1002"]){
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if([characteristic.UUID.UUIDString isEqualToString:@"1003"]){
            self.uartRXCharacteristic = characteristic;
        }
    }
}
//接受来自Peripheral的消息
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"read==%@",characteristic.value);
    int num = [self parseIntFromData:characteristic.value];
    NSString *str = [NSString stringWithFormat:@"%d",num];
    if(str && ![str isKindOfClass:[NSNull class]]){
  
    }
}
//订阅后的回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"notification=read===%@",characteristic.value);
    //执下面方法，didUpdateValueForCharacteristic会接受消息
    //[peripheral readValueForCharacteristic:characteristic];
}

#pragma mark  数据转换
- (unsigned)parseIntFromData:(NSData *)data{
    
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    return intData;
}

@end
