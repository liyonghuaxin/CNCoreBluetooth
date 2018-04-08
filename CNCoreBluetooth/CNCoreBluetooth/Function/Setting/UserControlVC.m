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
#import "EnterPwdAlert.h"

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
-(void)rotate{
    if ([CommonData deviceIsIpad]) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        if (SCREENWIDTH>SCREENHEIGHT) {
            leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0, edgeDistancePage*2/3.0+5, 0, 0);
        }else{
            leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0, edgeDistancePage*2/3.0, 0, 0);
        }
        [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([CommonData deviceIsIpad]) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        if (SCREENWIDTH>SCREENHEIGHT) {
            leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0, edgeDistancePage*2/3.0+5, 0, 0);
        }else{
            leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0, edgeDistancePage*2/3.0, 0, 0);
        }
        [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
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
    __weak typeof(self) weakself = self;
    DeleteUnpairAlert *alert = [[NSBundle mainBundle] loadNibNamed:@"DeleteUnpairAlert" owner:self options:nil][0];
    alert.unpairedBlock = ^{
        RespondModel *curModel = dataArray[indexPath.row];

        //弹出输入密码框
        EnterPwdAlert *enterAlert = [[NSBundle mainBundle] loadNibNamed:@"EnterPwdAlert" owner:self options:nil][0];
        enterAlert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        __weak typeof(self) weakself = self;
        enterAlert.returnPasswordStringBlock = ^(NSString *pwd) {
            if ([pwd isEqualToString:_model.periPwd]) {
                [weakself deleteDevice:curModel];
            }else{
                //密码输错提示
                //isShowIncorrectPwd = YES;
                [CNPromptView showStatusWithString:@"Incorrect Password"  withadjustBottomSpace:0];
            }
        };
        [enterAlert showWithName:weakself.model.periname];
    };
    alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
}


- (void)deleteDevice:(RespondModel *)curModel{
    [CNBlueCommunication cbSendInstruction:ENUnpair toPeripheral:_model.peripheral otherParameter:curModel.lockMacAddress finish:^(RespondModel *model) {
        if ([model.state intValue] == 1) {
            //解除配对成功
            //delete
            NSIndexSet *indexSet = [dataArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                RespondModel *myModel = obj;
                return [myModel.lockMacAddress isEqualToString:curModel.lockMacAddress];
            }];
            [dataArray removeObjectsAtIndexes:indexSet];
            [_myTableView reloadData];
        }
    }];
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
    cell.nameLab.text = [self adjustAppName:model.appName];
    cell.conLab.text = [self adjustLockMacAddress:model.lockMacAddress];
    return cell;
}

- (NSString *)adjustAppName:(NSString *)name{
   return [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
