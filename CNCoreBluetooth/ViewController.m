//
//  ViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

/**中央管理者*/
@property (nonatomic,strong) CBCentralManager *mgr;
//外围设备数组
@property (nonatomic,strong) NSMutableArray *peripheralArray;
@end

@implementation ViewController

- (NSMutableArray *)peripheralArray{
    if (_peripheralArray == nil) {
        _peripheralArray = [NSMutableArray array];
    }
    return _peripheralArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
     1、建立中央管理者
     queue=nil 代表在主队列
     */
    self.mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    /*
     2、扫描周边设备
     services 服务uuid的数组，传nil默认扫描全部服务
     */
    [self.mgr scanForPeripheralsWithServices:nil options:nil];

}

#pragma mark   CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"state: %zd",central.state);
}
/**
 发现外围设备
 peripheral：外围设备
 advertisementData——：相关数据
 RSSI：信号强度
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    //3、记录扫描到的外围设备
    if (![self.peripheralArray containsObject:peripheral]) {
        [self.peripheralArray addObject:peripheral];
    }
    //app呈现一个列表,供用户选择连接某个设备
    //、、、

}

//自定义方法  用户操作连接某个设备
-(void)connectPeripheral:(CBPeripheral *)peripheral{
    //4、连接外围设备
    [self.mgr connectPeripheral:peripheral options:nil];
    //5、设置代理
    peripheral.delegate = self;

}

#pragma mark CBPeripheralDelegate
//6、扫描服务 可传服务uuid代表指定服务，传nil代表所有服务
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [peripheral discoverServices:nil];
}
//7、获取指定的服务，然后根据此服务来查找特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        //假如服务UUID 是“123”
        if([service.UUID.UUIDString isEqualToString:@"123"]){
            //扫描特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
    
}
//
//8、发现服务特征，根据此特征进行数据处理
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for (CBCharacteristic *characteristic in service.characteristics) {
        //假如入特征UUID 是“456”
        if([characteristic.UUID.UUIDString isEqualToString:@"456"]){
            //读写操作
            //[peripheral readValueForCharacteristic:characteristic];
            //peripheral writeValue:<#(nonnull NSData *)#> forCharacteristic:<#(nonnull CBCharacteristic *)#> type:<#(CBCharacteristicWriteType)#>
        }
    }
}

#pragma mark 断开连接
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mgr stopScan];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
