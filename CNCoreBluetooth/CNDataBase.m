//
//  CNDataBase.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNDataBase.h"
#import <FMDB.h>

@interface CNDataBase(){
    
    FMDatabase  *_db;
    
}

@end

@implementation CNDataBase

+(instancetype)sharedDataBase{
    static CNDataBase *_DBCtl;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_DBCtl == nil) {
    
            _DBCtl = [[CNDataBase alloc] init];
            
            [_DBCtl initDataBase];
            
        }
    });
    return _DBCtl;
    
}

- (void)initDataBase{
    // 获得Documents目录路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"model.sqlite"];
    //  /Users/apple/Library/Developer/CoreSimulator/Devices/E72F73B1-945C-4839-A8F2-D394471A4451/data/Containers/Data/Application/62DED23E-0A55-45F6-9BFB-BE77D305A509/Documents/model.sqlite
    // 实例化FMDataBase对象
    _db = [FMDatabase databaseWithPath:filePath];
    [_db open];
    if (![self isTableOK:@"peripheral"]) {
        // 初始化数据表
        NSString *periSql = @"CREATE TABLE 'peripheral' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'peri_id' VARCHAR(255),'peri_name' VARCHAR(255),'peri_ispwd' VARCHAR(50),'peri_touchUnlock' VARCHAR(50))";
        [_db executeUpdate:periSql];
    }
    [_db close];
}

- (BOOL) isTableOK:(NSString *)tableName
{
    FMResultSet *rs = [_db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

@end
