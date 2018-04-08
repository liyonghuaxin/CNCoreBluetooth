//
//  CNDataBase.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNDataBase.h"
#import <FMDB.h>
#import "RespondModel.h"
#import "BlueHelp.h"

@interface CNDataBase(){
    
    FMDatabase  *_db;
    
}

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

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
    // 实例化FMDataBase对象
    NSLog(@"%@",filePath);
    _db = [FMDatabase databaseWithPath:filePath];
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];

    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        // 初始化数据表
        NSString *periSql = @"Create table if not exists peripheral (id INTEGER primary key autoincrement  not null , peri_id VARCHAR(255), peri_name VARCHAR(255), peri_pwd VARCHAR(255), peri_lockState VARCHAR(255), peri_isAdmin INTEGER, peri_openMethod INTEGER, peri_isTouchUnlock INTEGER)";
        [db executeUpdate:periSql];
        
        // 初始化数据表
        NSString *openLog = @"create table if not exists lockLog (id INTEGER primary key autoincrement  not null , log_lockId VARCHAR(255), log_method VARCHAR(255), log_date VARCHAR(255), log_deviceAddress VARCHAR(255))";
        [db executeUpdate:openLog];
        
        // 初始化数据表
        NSString *lockSetting = @"create table if not exists lockSetting (id INTEGER primary key autoincrement  not null , log_lockId VARCHAR(255), query_date VARCHAR(255))";
        [db executeUpdate:lockSetting];
    }];
    
}

- (BOOL)isExistTable:(NSString *)tableName{
    FMResultSet *rs = [_db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next]){
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        if(0 == count){
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

-(void)addPeripheralInfo:(CNPeripheralModel *)model{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSUInteger totalCount = [db intForQuery:@"SELECT COUNT (peri_id) FROM peripheral WHERE peri_id = ?",model.periID];
        if (totalCount==0) {
            //插入
            [db executeUpdate:@"INSERT INTO peripheral (peri_id, peri_name, peri_pwd, peri_lockState, peri_isAdmin, peri_openMethod, peri_isTouchUnlock) VALUES (?, ?, ?, ?, ?, ?, ?)",model.periID, model.periname, model.periPwd, model.lockState, @(model.isAdmin), @(model.openMethod), @(model.isTouchUnlock)];
        }
    }];
}

-(void)updatePeripheralInfo:(CNPeripheralModel *)model{
    //lyh 属性存在才更新/插入
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSUInteger totalCount = [db intForQuery:@"SELECT COUNT (peri_id) FROM peripheral WHERE peri_id = ?",model.periID];
        if (totalCount > 0) {
            //更新
            [db executeUpdate:@"UPDATE peripheral SET peri_id = ?, peri_name = ?, peri_pwd = ?, peri_lockState = ?, peri_isAdmin = ?, peri_openMethod = ?, peri_isTouchUnlock = ? WHERE peri_id = ?",model.periID, model.periname, model.periPwd, model.lockState, @(model.isAdmin), @(model.openMethod), @(model.isTouchUnlock), model.periID];
        }else{
            //插入
            [db executeUpdate:@"INSERT INTO peripheral (peri_id, peri_name, peri_pwd, peri_lockState, peri_isAdmin, peri_openMethod, peri_isTouchUnlock) VALUES (?, ?, ?, ?, ?, ?, ?)",model.periID, model.periname, model.periPwd, model.lockState, @(model.isAdmin), @(model.openMethod), @(model.isTouchUnlock)];
        }
    }];
}

- (CNPeripheralModel *)searchPeripheralInfo:(NSString *)lockID{
    CNPeripheralModel *model;
    [_db open];
    FMResultSet *rs = [_db executeQuery:@"Select * FROM peripheral WHERE peri_id = ?",lockID];
    if ([rs next]) {
        model = [[CNPeripheralModel alloc] init];
        model.periID = [rs stringForColumn:@"peri_id"];
        model.periname = [rs stringForColumn:@"peri_name"];
        model.periPwd = [rs stringForColumn:@"peri_pwd"];
        model.lockState = [rs stringForColumn:@"peri_lockState"];
        model.isAdmin = [rs boolForColumn:@"peri_isAdmin"];
        model.openMethod = [[rs stringForColumn:@"peri_openMethod"] intValue];
        model.isTouchUnlock = [rs boolForColumn:@"peri_isTouchUnlock"];
    }
    [_db close];
    return model;
}

-(NSArray *)searchAllPariedPeriID{
    [_db open];
    FMResultSet *rs = [_db executeQuery:@"Select peri_id FROM peripheral"];
    NSMutableArray *array = [NSMutableArray array];
    while ([rs next]) {
        NSString *string = [rs stringForColumn:@"peri_id"];
        if (string) {
            [array addObject:string];
        }
    }
    [_db close];
    return array;
}

-(NSArray *)searchAllPariedPeris{
    [_db open];
    FMResultSet *rs = [_db executeQuery:@"Select * FROM peripheral"];
    NSMutableArray *array = [NSMutableArray array];
    while ([rs next]) {
        CNPeripheralModel *model = [[CNPeripheralModel alloc] init];
        model.periID = [rs stringForColumn:@"peri_id"];
        model.periname = [rs stringForColumn:@"peri_name"];
        model.periPwd = [rs stringForColumn:@"peri_pwd"];
        model.lockState = [rs stringForColumn:@"peri_lockState"];
        model.isAdmin = [rs boolForColumn:@"peri_isAdmin"];
        model.openMethod = [[rs stringForColumn:@"peri_openMethod"] intValue];
        model.isTouchUnlock = [rs boolForColumn:@"peri_isTouchUnlock"];
        [array addObject:model];
    }
    [_db close];
    return array;
}

-(void)deletePairedWithIdentifier:(NSString *)identifier{
    [_db open];
    NSString *sqlStr = [NSString stringWithFormat:@"delete from peripheral where peri_id = '%@';",identifier];
    [_db executeUpdate:sqlStr];
    [_db close];
}

#pragma mark 开锁日志
- (void)addLog:(RespondModel *)model{
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSInteger count = [db intForQuery:@"select count(*) from lockLog"];
        if (count > 99) {
            NSString *deleteSql = [NSString stringWithFormat:@"delete from lockLog where id in(select id from lockLog order by log_date desc limit 99,%ld)", count-99];
            [db executeUpdate:deleteSql];
        }
        [db executeUpdate:@"INSERT INTO lockLog (log_lockId, log_method, log_date, log_deviceAddress) VALUES (?, ?, ?, ?)",model.lockIdentifier, @(model.lockMethod), model.date, model.IDAddress];
    }];    
}

- (NSArray *)queryOpenLockLog:(NSString *)lockID{
    [_db open];
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:@"Select * FROM lockLog where log_lockId = ?  Order By log_date DESC ",lockID];
    while ([rs next]) {
        RespondModel *model = [[RespondModel alloc] init];
        model.lockMacAddress = [rs stringForColumn:@"log_lockId"];
        model.lockMethod = [[rs stringForColumn:@"log_method"] intValue];
        model.date = [rs stringForColumn:@"log_date"];
        model.IDAddress = [rs stringForColumn:@"log_deviceAddress"];
        [array addObject:model];
    }
    return array;
}

#pragma mark 开锁日志
- (void)updateLockLogQueryTime:(NSString *)lockID{
    /*
     NSString *lockSetting = @"create table if not exists lockSetting (id INTEGER primary key autoincrement  not null , log_lockId VARCHAR(255), query_date VARCHAR(255))";

     */
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY-MM-dd-HH-mm-ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    dateString = [dateString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    //lyh 属性存在才更新/插入
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSUInteger totalCount = [db intForQuery:@"SELECT COUNT (log_lockId) FROM lockSetting WHERE log_lockId = ?",lockID];
        if (totalCount > 0) {
            //更新
            [db executeUpdate:@"UPDATE lockSetting SET query_date = ? WHERE log_lockId = ?",dateString, lockID];
        }else{
            //插入
            [db executeUpdate:@"INSERT INTO lockSetting (log_lockId, query_date) VALUES (?, ?)",lockID ,dateString];
        }
    }];
}

-(NSString *)getLastOpenLockDate:(NSString *)lockID{
    [_db open];
    FMResultSet *rs = [_db executeQuery:@"Select * FROM lockSetting where log_lockId = ?", lockID];
    NSString *str;
    while ([rs next]) {
        str = [rs stringForColumn:@"query_date"];
    }
    [_db close];
    return str;
}



@end
