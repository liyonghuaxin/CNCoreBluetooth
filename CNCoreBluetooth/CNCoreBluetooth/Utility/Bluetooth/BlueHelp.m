//
//  BlueHelp.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/9.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "BlueHelp.h"

@implementation BlueHelp
+(NSString *)getCurDateByBCDEncode{
    //data：2018-02-01 06:29:25 +0000
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY-MM-dd-hh-mm-ss"];
    //dateString：18-02-01-02-29   已转为中国时间了
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSArray *time_strs = [dateString componentsSeparatedByString:@"-"];
    
    int y,m,d,hh,mm,ss;
    y = [self getDecimalNumber:time_strs[0]];
    m = [self getDecimalNumber:time_strs[1]];
    d = [self getDecimalNumber:time_strs[2]];
    hh = [self getDecimalNumber:time_strs[3]];
    mm = [self getDecimalNumber:time_strs[4]];
    ss = [self getDecimalNumber:time_strs[5]];

    Byte byte[] = {y,m,d,hh,mm,ss};
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}
//将数字改为 两个bcd编码  反编回 一个字节（对应ascii）
+ (int)getDecimalNumber:(NSString *)str{
    //return [str intValue];// 18 按照0x12处理
    int num1 =  [str intValue]/10*16;
    int num2 =  [str intValue]%10;
    return num1+num2;
}

+(NSString *)getDateWith:(NSString *)str{
    NSMutableString *string = [[NSMutableString alloc] init];
    const char *date = [str UTF8String];
    for (int i = 0; i < strlen(date); i++) {
        int number = date[i];
        int a = number/16;
        int b = number%16;
        [string appendFormat:@"%d%d",a,b];
    }
    return string;
}

+ (NSData *)getCurDateBytes{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY-MM-dd-hh-mm-ss"];
    //dateString：18-02-01-02-29   已转为中国时间了
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSArray *time_strs = [dateString componentsSeparatedByString:@"-"];
    NSMutableString *string = [[NSMutableString alloc] init];
    for (NSString *str in time_strs) {
        [string appendString:str];
    }
    const char *pointer = [string UTF8String];
    for (int i = 0; i<strlen(pointer); i++) {
        
    }
    return nil;
    
}

@end
