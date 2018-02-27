//
//  BlueHelp.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/9.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlueHelp : NSObject

// 由于时间是按bcd编码，的先将时间每两个数字转为一个字节对应的int值，然后找到这个int值对应ascii字符，然后整个包的编码方式就一样了，
+ (NSString *)getCurDateByBCDEncode;
+ (NSString *)getDateWith:(NSString *)str;
+ (NSData *)getCurDateBytes;
+ (NSString *)getCurDeviceName;
@end
