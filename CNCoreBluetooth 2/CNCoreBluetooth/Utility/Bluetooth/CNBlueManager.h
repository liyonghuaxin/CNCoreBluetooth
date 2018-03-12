//
//  CNBlueMannager.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CNBlueCommon.h"

typedef void(^scanFinishBlock)(CBPeripheral *per);
typedef void(^periConnectedStateBlock)(CBPeripheral *peripherial,BOOL isConnect);

@interface CNBlueManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

+ (CNBlueManager *)sharedBlueManager;
/**
 开始扫描❤️广播包
 */
- (void)cus_beginScanPeriPheralFinish:(scanFinishBlock)finish;
- (void)cus_stopScan;

- (void)cus_connectPeripheral:(CBPeripheral *)peri;
- (void)cus_cancelConnectPeripheral:(CBPeripheral *)peri;

- (BOOL)checkPeripheralState;
/**
 app发送指令
 */
//- (void)cus_sendInstruction:(InstructionEnum)instruction;

/**
 向peripheral发送数据
 */
- (void)senddata:(NSString *)str toPeripheral:(CBPeripheral *)peri;
//当前设备
@property (nonatomic,strong) CBPeripheral *currentperi;
//监听 蓝牙锁连接状态
@property (nonatomic,copy)periConnectedStateBlock periConnectedState;
//存放已扫到的外设
@property (nonatomic,strong) NSMutableArray *peripheralArray;
//存放正连接的外设
@property (nonatomic,strong) NSMutableArray *connectedPeripheralArray;

@end
