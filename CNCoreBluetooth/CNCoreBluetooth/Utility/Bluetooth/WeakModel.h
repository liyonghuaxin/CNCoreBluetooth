//
//  WeakModel.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/3/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface WeakModel : NSObject

@property (strong, nonatomic) NSDate *sendDate;
@property (strong, nonatomic) CBPeripheral *peri;
@property (copy, nonatomic) NSString *lockID;
@property (copy, nonatomic) NSTimer *timer;
- (void)beginWeak;
- (void)cancelWeak;

@end
