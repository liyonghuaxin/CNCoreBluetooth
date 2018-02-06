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

@property (nonatomic, copy)NSString *macAddress;

@end
