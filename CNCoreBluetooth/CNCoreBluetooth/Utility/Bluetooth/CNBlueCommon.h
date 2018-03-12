//
//  CNBlueCommon.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#ifndef CNBlueCommon_h
#define CNBlueCommon_h

typedef enum : NSUInteger {
    ENAutoLogin,//自动登录
    ENOpenLock,//开锁
    ENChangeNameAndPwd,//广播名称及配对密码修改
    ENLookLockLog,//开锁日志查询
    ENLookHasPair,//登录设备查询
    ENUnpair,//自动登录解除
    ENLockStateReport//锁具状态上报
} InstructionEnum;

typedef enum : NSUInteger {
    ENRFIDMethod = 1,
    ENTouchMethod,
    ENAPPMethod,
} ENLockMethod;

#endif /* CNBlueCommon_h */
