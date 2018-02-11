//
//  CNDataBase.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPeripheralModel.h"

@interface CNDataBase : NSObject

+(instancetype)sharedDataBase;
/**
 只插入
 */
- (void)addPeripheralInfo:(CNPeripheralModel *)model;
/**
 插入/更新
 */
- (void)updatePeripheralInfo:(CNPeripheralModel *)model;
/**
 查询
 */
- (CNPeripheralModel *)searchPeripheralInfo:(NSString *)lockID;
/**
 查询所有已连接设备id
 */
- (NSArray *)searchAllPariedPeriID;
@end

