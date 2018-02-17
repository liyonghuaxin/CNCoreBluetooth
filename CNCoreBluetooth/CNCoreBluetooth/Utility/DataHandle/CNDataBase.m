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
    [_db open];
    // 初始化数据表
    NSString *periSql = @"Create table if not exists peripheral (id INTEGER primary key autoincrement  not null , peri_id VARCHAR(255), peri_name VARCHAR(255), peri_pwd VARCHAR(255), peri_isPwd INTEGER, peri_isTouchUnlock INTEGER)";
    [_db executeUpdate:periSql];
    [_db close];
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
            [db executeUpdate:@"INSERT INTO peripheral (peri_id, peri_name, peri_pwd, peri_isPwd, peri_isTouchUnlock) VALUES (?, ?, ?, ?, ?)",model.periID, model.periname, model.periPwd, @(model.isPwd), @(model.isTouchUnlock)];
        }
    }];
}

-(void)updatePeripheralInfo:(CNPeripheralModel *)model{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSUInteger totalCount = [db intForQuery:@"SELECT COUNT (peri_id) FROM peripheral WHERE peri_id = ?",model.periID];
        if (totalCount > 0) {
            //更新
            [db executeUpdate:@"UPDATE peripheral SET peri_id = ?, peri_name = ?, peri_pwd = ?, peri_pwd = ?, peri_isPwd = ?, peri_isTouchUnlock = ? WHERE peri_id = ?",model.periID, model.periname, model.periPwd, model.periPwd, @(model.isPwd), @(model.isTouchUnlock), model.periID];

        }else{
            //插入
            [db executeUpdate:@"INSERT INTO peripheral (peri_id, peri_name, peri_pwd, peri_isPwd, peri_isTouchUnlock) VALUES (?, ?, ?, ?, ?)",model.periID, model.periname, model.periPwd, @(model.isPwd), @(model.isTouchUnlock)];
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
        model.isPwd = [rs boolForColumn:@"peri_isPwd"];
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
        [array addObject:string];
    }
    [_db close];
    return array;
}

@end
