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

@interface CommonData : NSObject

+(instancetype)sharedCommonData;

+ (BOOL)deviceIsIpad;

//扫描新设备，用户手动输入的新密码
@property (nonatomic, copy)NSString *pairedPwd;
//本手机mac地址
@property (nonatomic, copy)NSString *macAddress;
//存放 home set列表数据
@property (nonatomic,strong) NSMutableArray *listPeriArr;
//存放需要自动同步锁具ID
@property (nonatomic,strong) NSMutableArray *reportIDArr;

@end
