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

typedef void(^scanFinishBlock)(CBPeripheral *per, NSString *lockName);
typedef void(^periConnectedStateBlock)(CBPeripheral *peripheral, BOOL isConnect, BOOL isOpenTimer, BOOL isNeedReRnterPwd);

@interface CNBlueManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

+ (CNBlueManager *)sharedBlueManager;
/**
 开始扫描❤️广播包
 */
- (void)cus_beginScanPeriPheralFinish:(scanFinishBlock)finish;
- (void)cus_stopScan;

- (void)cus_connectPeripheral:(CBPeripheral *)peri;
- (void)cus_cancelConnectPeripheral:(CBPeripheral *)peri;
- (void)disconnectAllPeri;
- (void)connectAllPairedLock;
/**
 app发送指令
 */
//- (void)cus_sendInstruction:(InstructionEnum)instruction;

/**
 向peripheral发送数据
 */
//- (void)senddata:(NSString *)str toPeripheral:(CBPeripheral *)peri;
@property (nonatomic,strong) CBCentralManager *mgr;
//监听 蓝牙锁连接状态
@property (nonatomic,copy)periConnectedStateBlock periConnectedState;
//存放已扫到的外设
//包括数据库存放的被retrieve的外设（可能不在周围，但之前配对过）和 刚被扫描出来的外设
@property (nonatomic,strong) NSMutableArray *peripheralArray;
//存放正连接的外设
@property (nonatomic,strong) NSMutableArray *connectedPeripheralArray;
//存放已连接的外设ID
@property (nonatomic,strong) NSMutableArray *connectedLockIDArray;
//存放已配对但未连接的外设ID
@property (nonatomic,strong) NSMutableArray *unConnectedLockIDArray;
@property (nonatomic,strong) NSMutableDictionary *lockInfoDic;

@end
