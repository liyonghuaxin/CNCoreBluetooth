//
//  BlueHelp.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/9.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "BlueHelp.h"
#import "NSString+Utils.h"

@implementation BlueHelp
+(NSString *)getCurDateByBCDEncode{
    //data：2018-02-01 06:29:25 +0000
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY-MM-dd-HH-mm-ss"];
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

+(NSString *)getLastDateAboutLog:(NSString *)str{
    if (!str || str.length == 0) {
        //2018-01-01 00:00:00
        str = @"180101000000";
    }
    if (str.length == 12) {
        int y,m,d,hh,mm,ss;
        y = [self getDecimalNumber:[str substringWithRange:NSMakeRange(0, 2)]];
        m = [self getDecimalNumber:[str substringWithRange:NSMakeRange(2, 2)]];
        d = [self getDecimalNumber:[str substringWithRange:NSMakeRange(4, 2)]];
        hh = [self getDecimalNumber:[str substringWithRange:NSMakeRange(6, 2)]];
        mm = [self getDecimalNumber:[str substringWithRange:NSMakeRange(8, 2)]];
        ss = [self getDecimalNumber:[str substringWithRange:NSMakeRange(10, 2)]];
        Byte byte[] = {y,m,d,hh,mm,ss};
        NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return string;
    }else{
        return [self getCurDateByBCDEncode];
    }
}

//将数字改为 两个bcd编码  反编回 一个字节（对应ascii）
+ (int)getDecimalNumber:(NSString *)str{
//    unsigned intData = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:str];
//    [scanner scanHexInt:&intData];
    
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

+(NSString *)getCurDeviceName{
    NSString *deviceName = [UIDevice currentDevice].name;
    NSData *data = [deviceName dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    if (data.length<=20) {
        [resultStr appendString:deviceName];
        for (int i = 0; i<20-data.length; i++) {
            [resultStr appendString:@" "];
        }
        return resultStr;
    }else{
        return [deviceName subStringByByteLength:20 withPara:@" "];
    }
}

+ (NSString *)adjustLockDeviceName:(NSString *)name{
    NSData *data = [name dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    if (data.length<=18) {
        [resultStr appendString:name];
        for (int i = 0; i<18-data.length; i++) {
            [resultStr appendString:@"\0"];
        }
        return resultStr;
    }else{
        return [name subStringByByteLength:18 withPara:@"\0"];
    }
}

+ (NSString *)getFormatAddress:(NSString *)str{
    if (str.length == 12) {
        NSMutableString *string = [[NSMutableString alloc] init];
        for (int i = 0; i<str.length; i=i+2) {
            if (i == 0) {
                [string appendString:[str substringWithRange:NSMakeRange(0, 2)]];
            }else{
                [string appendString:@":"];
                [string appendString:[str substringWithRange:NSMakeRange(i, 2)]];
            }
        }
        return string;
    }else{
        return str;
    }
}

+ (NSDictionary *)getFormatTime:(NSString *)str{
    
    if (str.length == 12) {
        NSMutableString *date = [[NSMutableString alloc] init];
        [date appendString:[str substringWithRange:NSMakeRange(2, 2)]];
        [date appendString:@"/"];
        [date appendString:[str substringWithRange:NSMakeRange(4, 2)]];
        [date appendString:@"/"];
        [date appendString:[str substringWithRange:NSMakeRange(0, 2)]];
        
        NSMutableString *time = [[NSMutableString alloc] init];
        NSString *hour = [str substringWithRange:NSMakeRange(6, 2)];
        NSString *minute = [str substringWithRange:NSMakeRange(8, 2)];
        if ([hour intValue] > 12) {
            [time appendString:[NSString stringWithFormat:@"%d:%@ PM",[hour intValue]-12, minute]];
        }else{
            [time appendString:[NSString stringWithFormat:@"%@:%@ AM",hour, minute]];
        }
        NSDictionary *dic = @{@"time":time, @"date":date};
        return dic;
    }else{
        NSDictionary *dic = @{@"time":@"", @"date":@""};
        return dic;
    }
}

@end
