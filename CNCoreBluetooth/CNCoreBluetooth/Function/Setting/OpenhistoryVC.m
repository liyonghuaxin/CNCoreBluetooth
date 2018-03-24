//
//  OpenhistoryVC.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "OpenhistoryVC.h"
#import "OpenHistoryCell.h"
#import "CNBlueCommunication.h"
#import "CNBlueManager.h"
#import "CNDataBase.h"
#import "BlueHelp.h"

@interface OpenhistoryVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *dataArray;
}

@end

@implementation OpenhistoryVC

-(void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self setBackBtnHiden:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setBackBtnHiden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArray = [NSMutableArray array];
    
    self.headView.hidden = NO;
    self.headLable.text = @"OPEN HISTORY";
    
    [_myTableView registerNib:[UINib nibWithNibName:@"OpenHistoryCell" bundle:nil] forCellReuseIdentifier:@"OpenHistoryCell"];
    _myTableView.tableFooterView = [[UIView alloc] init];
    
    NSArray *array = [[CNDataBase sharedDataBase] queryOpenLockLog:_lockID];
    [dataArray addObjectsFromArray:array];
    RespondModel *model;
    if (array.count) {
        model = array[0];
    }
    for (CBPeripheral *peri in [CNBlueManager sharedBlueManager].connectedPeripheralArray) {
        if ([peri.identifier.UUIDString isEqualToString:_lockID]) {
            [CNBlueCommunication cbSendInstruction:ENLookLockLog toPeripheral:peri otherParameter:model.date finish:^(RespondModel *model) {
                if ([model.state intValue] == 1) {
                    for (RespondModel *myModel in dataArray) {
                        if ([myModel.date isEqualToString:model.date]) {
                            return ;
                        }
                    }
                    model.lockIdentifier = _lockID;
                    [dataArray insertObject:model atIndex:0];
                    [[CNDataBase sharedDataBase] addLog:model];
                    [self.myTableView reloadData];
                }else{
                    //查询完毕
                    //[model.state intValue] == 0
                }
            }];
            break;
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OpenHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpenHistoryCell" forIndexPath:indexPath];
    RespondModel *model = dataArray[indexPath.row];
    NSDictionary *dic = [BlueHelp getFormatTime:model.date];
    cell.timeLab.text = [dic objectForKey:@"time"];
    cell.dateLab.text = [dic objectForKey:@"date"];
    cell.macAddress.text = [BlueHelp getFormatAddress:model.IDAddress];
    if (model.lockMethod == ENRFIDMethod) {
        cell.openMethod.text = @"RFID";
    }else if (model.lockMethod == ENTouchMethod){
        cell.openMethod.text = @"Touch";
    }else{
        cell.openMethod.text = @"APP";
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
