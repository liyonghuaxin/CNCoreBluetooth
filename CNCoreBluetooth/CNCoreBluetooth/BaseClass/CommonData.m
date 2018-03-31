//
//  CommonData.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/3.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CommonData.h"

float iPhoneXTopPara = 0.0;
float iPhoneXBottomPara = 0.0;
float edgeDistancePage = 0.0;
float scalePage = 1.0;
Boolean isopen = false;

@implementation CommonData

+(instancetype)sharedCommonData{
    static CommonData *data;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[CommonData alloc] init];
        data.listPeriArr = [NSMutableArray array];
        data.reportIDArr = [NSMutableArray array];
        data.deviceInfoArr = [NSMutableArray array];
        data.canConnectLockIDArr = [NSMutableArray array];
    });
    return data;
}

+ (BOOL)deviceIsIpad
{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        return NO;
    }
    else if([deviceType isEqualToString:@"iPod touch"]) {
        //iPod Touch
        return NO;
    }
    else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        return YES;
    }
    return NO;
}

@end
