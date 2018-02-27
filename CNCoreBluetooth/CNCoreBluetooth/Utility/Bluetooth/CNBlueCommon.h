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
    ENLookLockLog,//开锁记录查询
    ENLookHasPair,//已配对设备查询
    ENUnpair,//解除配对
    ENLockStateReport//锁具状态上报
} InstructionEnum;

typedef enum : NSUInteger {
    ENSlideMethod = 1,
    ENTouchMethod,
    ENPwdMethod,
} ENLockMethod;

#endif /* CNBlueCommon_h */
