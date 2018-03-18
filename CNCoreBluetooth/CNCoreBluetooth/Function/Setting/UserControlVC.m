//
//  UserControlVC.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/3/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "UserControlVC.h"
#import "UserControlCell.h"
#import "CNBlueCommunication.h"
#import "CNBlueCommunication.h"
#import "DeleteUnpairAlert.h"

@interface UserControlVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *dataArray;
}

@end

@implementation UserControlVC
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
    self.headLable.text = @"USER CONTROL";
    
    [_myTableView registerNib:[UINib nibWithNibName:@"UserControlCell" bundle:nil] forCellReuseIdentifier:@"UserControlCell"];
    _myTableView.tableFooterView = [[UIView alloc] init];
    
    __weak typeof(self) weakself = self;
    if (_model.peripheral) {
        [CNBlueCommunication cbSendInstruction:ENLookHasPair toPeripheral:_model.peripheral otherParameter:nil finish:^(RespondModel *model) {
            if ([model.state intValue] == 1) {
                [dataArray addObject:model];
            }
            [weakself.myTableView reloadData];
        }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DeleteUnpairAlert *alert = [[NSBundle mainBundle] loadNibNamed:@"DeleteUnpairAlert" owner:self options:nil][0];
    alert.unpairedBlock = ^{
        RespondModel *model = dataArray[indexPath.row];
        [CNBlueCommunication cbSendInstruction:ENUnpair toPeripheral:_model.peripheral otherParameter:model.lockMacAddress finish:^(RespondModel *model) {
            if ([model.state intValue] == 1) {
                //解除配对成功
                //delete
                NSIndexSet *indexSet = [dataArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    RespondModel *myModel = obj;
                    return [myModel.lockMacAddress isEqualToString:model.lockIdentifier];
                }];
                [dataArray removeObjectsAtIndexes:indexSet];
                [_myTableView reloadData];
            }
        }];
    };
    alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserControlCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserControlCell" forIndexPath:indexPath];
    RespondModel *model = dataArray[indexPath.row];
    cell.nameLab.text = [self adjustLockName:model.appName];
    cell.conLab.text = [self adjustLockMacAddress:model.lockMacAddress];
    return cell;
}

- (NSString *)adjustLockName:(NSString *)name{
   return [name stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString *)adjustLockMacAddress:(NSString *)address{
    NSMutableString *str = [[NSMutableString alloc] init];
    if (address.length == 12) {
        for (int i = 0; i<8; i = i+2) {
            if (i == 0) {
                [str appendString:[address substringWithRange:NSMakeRange(i, 2)]];
                
            }else{
                [str appendFormat:@"-%@",[address substringWithRange:NSMakeRange(i, 2)]];
            }
        }
        [str appendString:@"-**_**"];
    }
    return str;
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
