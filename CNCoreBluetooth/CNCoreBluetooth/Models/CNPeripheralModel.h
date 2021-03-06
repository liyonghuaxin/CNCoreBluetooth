//
//  CNPeripheralModel.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/30.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum : NSUInteger {
    ENDefault,
    ENUpdate,
    ENDelete,
} ENActionType;

@interface CNPeripheralModel : NSObject

@property (nonatomic,strong)CBPeripheral *peripheral;
@property (nonatomic,assign)NSInteger periIndex;
@property (nonatomic,assign)BOOL sliderOn;
@property (nonatomic,copy)NSString *periID;
@property (nonatomic,copy)NSString *periname;
@property (nonatomic,copy)NSString *periPwd;
@property (nonatomic,assign)BOOL isAdmin;
@property (nonatomic,assign)OpenLockMethod openMethod;
@property (nonatomic,assign)BOOL isTouchUnlock;
@property (nonatomic,copy)NSString *lockState;
@property (nonatomic,assign)BOOL isConnect;
@property (nonatomic,assign) ENActionType actionType;

@end
