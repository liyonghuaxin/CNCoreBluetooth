//
//  RespondModel.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ENAutoSynchro,//自动同步
    ENLock,//开锁
    ENChangeNameAndPwd,//广播名称及配对密码修改
    ENLookLockLog,//开锁记录查询
    ENLookHasPair,//已配对设备查询
    ENUnpair,//解除配对
    ENLockStateReport//锁具状态上报
} ResponseEnum;

typedef enum : NSUInteger {
    ENSlideMethod,
    ENTouchMethod,
    ENPwdMethod,
} ENLockMethod;

@interface RespondModel : NSObject
//指令码
@property (nonatomic, assign) ResponseEnum type;
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
