//
//  RespondModel.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBlueCommon.h"

@interface RespondModel : NSObject
//指令码
@property (nonatomic, assign) InstructionEnum type;
//状态码
@property (nonatomic, copy) NSString *state;
//锁状态
@property (nonatomic, copy) NSString *lockState;
//开锁方式
@property (nonatomic, assign) ENLockMethod *lockMethod;
//时间
@property (nonatomic, copy) NSString *date;
//app端mac地址 或 RFID卡ID卡号
@property (nonatomic, copy) NSString *IDAddress;
//app mac地址
@property (nonatomic, copy) NSString *macAddress;
//app 蓝牙名称
@property (nonatomic, copy) NSString *lockName;

@end
