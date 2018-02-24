//
//  CNPeripheralModel.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/30.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CNPeripheralModel : NSObject

@property (nonatomic,strong)CBPeripheral *peripheral;
@property (nonatomic,assign)NSInteger periIndex;
@property (nonatomic,assign)BOOL sliderOn;
@property (nonatomic,copy)NSString *periID;
@property (nonatomic,copy)NSString *periname;
@property (nonatomic,copy)NSString *periPwd;
@property (nonatomic,assign)BOOL isPwd;
@property (nonatomic,assign)BOOL isTouchUnlock;

@end
