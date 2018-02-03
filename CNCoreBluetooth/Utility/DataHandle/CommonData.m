//
//  CommonData.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/3.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CommonData.h"

@implementation CommonData

+(instancetype)sharedCommonData{
    static CommonData *data;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[CommonData alloc] init];
    });
    return data;
}

@end
