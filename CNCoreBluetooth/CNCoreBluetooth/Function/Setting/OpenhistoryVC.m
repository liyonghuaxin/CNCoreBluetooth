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
    UILabel *label = [[UILabel alloc] init];
    [self.headView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.headImageV);
    }];
    label.font = TEXT_HEAD_FONT;
    label.textColor = TEXT_HEAD_COLOR;
    label.text = @"OPEN HISTORY";
    
    [_myTableView registerNib:[UINib nibWithNibName:@"OpenHistoryCell" bundle:nil] forCellReuseIdentifier:@"OpenHistoryCell"];
    _myTableView.tableFooterView = [[UIView alloc] init];
    
    for (CBPeripheral *peri in [CNBlueManager sharedBlueManager].connectedPeripheralArray) {
        if ([peri.identifier.UUIDString isEqualToString:_lockID]) {
            [CNBlueCommunication cbSendInstruction:ENLookLockLog toPeripheral:peri finish:^(RespondModel *model) {
                [dataArray addObject:model];
                [self.myTableView reloadData];
            }];
            break;
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OpenHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpenHistoryCell" forIndexPath:indexPath];
    if (indexPath.row%2 == 0) {
        cell.imageV.image = [UIImage imageNamed:@"lockRedLog"];
        cell.conLab.text = @"You Locked Quick Safe 1";
    }else{
        cell.imageV.image = [UIImage imageNamed:@"lockGreenLog"];
        cell.conLab.text = @"You Unlocked Quick Safe 1";
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
