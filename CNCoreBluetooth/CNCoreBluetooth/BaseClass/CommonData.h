//
//  CommonData.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/3.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

extern float iPhoneXTopPara;
extern float iPhoneXBottomPara;
extern float edgeDistancePage;
extern float scalePage;

typedef enum : NSUInteger {
    OpenLockSlide,
    OpenLockThumb,
    OpenLockPwd,
} OpenLockMethod;

@interface CommonData : NSObject

+(instancetype)sharedCommonData;

+ (BOOL)deviceIsIpad;

//存储 新设备 和 重新输入密码的设备信息（字典）
@property (nonatomic, strong)NSMutableArray *deviceInfoArr;
//本手机mac地址
@property (nonatomic, copy)NSString *macAddress;
//存放 home set列表数据
@property (nonatomic,strong) NSMutableArray *listPeriArr;
//存放需要自动同步锁具ID
@property (nonatomic,strong) NSMutableArray *reportIDArr;
//存放不知道密码，或不想输入密码而未连接的锁（认为是在范围内，可连接的锁）
//打开app走的远了、或者未及时输入密码，被别人占用都会出问题
@property (nonatomic,strong) NSMutableArray *canConnectLockIDArr;

@end
