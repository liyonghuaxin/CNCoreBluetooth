//
//  ViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SVProgressHUD.h"

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>

/**中央管理者*/
@property (nonatomic,strong) CBCentralManager *mgr;
//外围设备数组
@property (nonatomic,strong) NSMutableArray *peripheralArray;

@property (nonatomic,strong) NSMutableArray *connectedPeripheralArray;
@property (nonatomic, strong) CBCharacteristic *uartRXCharacteristic;
@end

@implementation ViewController

- (NSMutableArray *)peripheralArray{
    if (_peripheralArray == nil) {
        _peripheralArray = [NSMutableArray array];
    }
    return _peripheralArray;
}

-(NSMutableArray *)connectedPeripheralArray{
    if (_connectedPeripheralArray == nil) {
        _connectedPeripheralArray = [NSMutableArray array];
    }
    return _connectedPeripheralArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
     1、建立中央管理者
     queue=nil 代表在主队列
     */
    self.view.backgroundColor = [UIColor whiteColor];
    self.mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}
#pragma mark Private API
- (void)senddata:(NSString *)str toPeripheral:(CBPeripheral *)peri{
    [peri setNotifyValue:YES forCharacteristic:self.uartRXCharacteristic];
    NSData *rdata = [str dataUsingEncoding:NSUTF8StringEncoding];
    [peri writeValue:rdata forCharacteristic:self.uartRXCharacteristic  type:CBCharacteristicWriteWithResponse];
}

//自定义方法  用户操作连接某个设备
-(void)connectPeripheral:(CBPeripheral *)peripheral{
    //4、连接外围设备
    NSLog(@"正在连接设备 ： %@",peripheral.name);
    [self.mgr connectPeripheral:peripheral options:nil];
    //5、设置代理
    peripheral.delegate = self;
}
#pragma mark   CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    /*
     CBManagerStateUnknown = 0,
     CBManagerStateResetting,
     CBManagerStateUnsupported,
     CBManagerStateUnauthorized,
     CBManagerStatePoweredOff,
     CBManagerStatePoweredOn,
     */
    NSLog(@"state: %zd",central.state);
}
/**
 发现外围设备
 peripheral：外围设备
 advertisementData——：相关数据
 RSSI：信号强度
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    /*
     <CBPeripheral: 0x155604f0, identifier = 90B86384-8B9E-45AB-83C7-077CC721CD9B, name = (null), state = disconnected>
     */
    //3、记录扫描到的外围设备
    NSLog(@"=======发现外围设备");
    if (![self.peripheralArray containsObject:peripheral]) {
        [self.peripheralArray addObject:peripheral];
        NSLog(@"扫描到的外围设备 peripheral == %@",peripheral);
    }
    
    //app呈现一个列表,供用户选择连接某个设备
    if (![self.connectedPeripheralArray containsObject:peripheral]) {
        //lyh  判断的必要性？
        if (peripheral.state == CBPeripheralStateDisconnected) {
            //lyh debug
            if (![peripheral.name containsString:@"Charge"]) {
                [self connectPeripheral:peripheral];
            }
        }
    }

    [_myTableView reloadData];
}

//6、扫描服务 可传服务uuid代表指定服务，传nil代表所有服务
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"连接到：%@",peripheral.name]];
    NSLog(@"设备%@报告： didConnect ->  discoverServices:nil",peripheral.name);
    [peripheral readRSSI];
    if (![self.connectedPeripheralArray containsObject:peripheral]) {
        [self.connectedPeripheralArray addObject:peripheral];
        NSLog(@"扫描到的外围设备 peripheral == %@",peripheral);
    }
    [_myTableView2 reloadData];
    [peripheral discoverServices:nil];
}
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    NSLog(@"rssi ======  %@",[RSSI stringValue]);
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@失去连接",peripheral.name]];
    [self.connectedPeripheralArray removeObject:peripheral];
    [_myTableView2 reloadData];
    [self.mgr connectPeripheral:peripheral options:nil];
    NSLog(@"-⚠️⚠️⚠️⚠️⚠️⚠️-----失去和设备%@的连接-------",peripheral.name);
}
#pragma mark CBPeripheralDelegate
//7、获取指定的服务，然后根据此服务来查找特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    /*
     TTC——BLE的所有服务，测试传输数据我们找1000
     <CBService: 0x145796f0, isPrimary = YES, UUID = Continuity>,
     <CBService: 0x14579790, isPrimary = YES, UUID = Battery>,
     <CBService: 0x14579ad0, isPrimary = YES, UUID = Current Time>,
     <CBService: 0x145798c0, isPrimary = YES, UUID = Device Information>,
     <CBService: 0x145797b0, isPrimary = YES, UUID = 1000>
     )
     */
    NSLog(@"--------设备%@报告---didDiscoverServices---",peripheral.name);
    NSLog(@"Services == %@",peripheral.services);

    for (CBService *service in peripheral.services) {
        if([service.UUID.UUIDString isEqualToString:@"1000"]){
            NSLog(@"discoverCharacteristics:nil forService:%@的服务",service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
        //NSLog(@"%@的SubServices == %@",service.UUID,peripheral.services);
        //[peripheral discoverCharacteristics:nil forService:service];
        //NSLog(@"discoverCharacteristics:nil forService:%@",service.UUID);
    }
}
//
//8、发现服务特征，根据此特征进行数据处理
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"--------设备%@报告----didDiscoverCharacteristics----",peripheral.name);
    NSLog(@"service.UUID = %@",service.UUID);
    NSLog(@"characteristic = %@",service.characteristics);
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral readValueForCharacteristic:characteristic];
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        if([characteristic.UUID.UUIDString isEqualToString:@"1003"]){
            self.uartRXCharacteristic = characteristic;
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"read==%@",characteristic.value);
    int num = [self parseIntFromData:characteristic.value];
    NSString *str = [NSString stringWithFormat:@"%d",num];
    if(str && ![str isKindOfClass:[NSNull class]]){
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"收到锁具信息" message:[NSString stringWithFormat:@"%@",str] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"notification=read===%@",characteristic.value);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark tableviewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //提示框添加文本输入框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请属于指令"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        //响应事件
        for(UITextField *text in alert.textFields){
            CBPeripheral *peri  = (CBPeripheral *)self.connectedPeripheralArray[indexPath.row];
            [self senddata:[NSString stringWithFormat:@"%@",text.text] toPeripheral:peri];
        }
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        //响应事件
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"指令";
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.myTableView) {
        return self.peripheralArray.count;
    }else{
        return self.connectedPeripheralArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.myTableView) {
        static NSString *cellID1 = @"cellID1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:cellID1];
        }
        CBPeripheral *peri = self.peripheralArray[indexPath.row];
        cell.textLabel.text = peri.name;
        cell.detailTextLabel.text = [peri.RSSI stringValue];
        return cell;
    }else{
        static NSString *cellID2 = @"cellID2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:cellID2];
        }
        CBPeripheral *peri = self.connectedPeripheralArray[indexPath.row];
        cell.textLabel.text = peri.name;
        cell.detailTextLabel.text = [peri.RSSI stringValue];
        return cell;
    }
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

- (IBAction)beginScan:(id)sender {
    /*
     2、扫描周边设备
     services 服务uuid的数组，传nil默认扫描全部服务
     */
    //lyh debug
    for (CBPeripheral *per in self.connectedPeripheralArray) {
        [self.mgr cancelPeripheralConnection:per];
    }
    [_myTableView2 reloadData];
    [self.mgr scanForPeripheralsWithServices:nil options:nil];

}

- (IBAction)stopScan:(id)sender {
    [self.mgr stopScan];
}
@end
