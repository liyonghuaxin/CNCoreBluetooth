//
//  SetDetailViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/6.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "SetDetailViewController.h"
#import "SetDetailCell.h"
#import "SetLockMethod.h"
#import "ModifyPwdVC.h"
#import "OpenhistoryVC.h"
#import "UIView+KGViewExtend.h"
#import "DeleteUnpairAlert.h"
#import "SaveSettingAlert.h"
#import "CNPeripheralModel.h"
#import "CNDataBase.h"
#import "CNBlueCommunication.h"
#import "CNBlueManager.h"
#import "EnterPwdAlert.h"
#import "UserControlVC.h"

static NSString *setDetailCell = @"SetDetailCell";

static NSString *setLockMethod = @"SetLockMethod";

@interface SetDetailViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UIView *bgView;
    NSArray *dataArray;
    DeleteUnpairAlert *alert;
    SaveSettingAlert *saveAlert;
    BOOL isShowIncorrectPwd;
    CNPeripheralModel *tempModel;
}

@end

@implementation SetDetailViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self setBackBtnHiden:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setBackBtnHiden:NO];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tempModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:_lockModel.periID];
    _lockModel.isAdmin = tempModel.isAdmin;
    if (_lockModel.isAdmin) {
        dataArray = @[@"Name",@"Password",@"Open History",@"User Control",@"Unlock Mode",@"Enable TouchSafe Sensor",@"Unpair Device"];
    }else{
        dataArray = @[@"Name",@"Unlock Mode",@"Enable TouchSafe Sensor",@"Unpair Device"];
    }
    
    [_myTableView registerNib:[UINib nibWithNibName:@"SetDetailCell" bundle:nil] forCellReuseIdentifier:setDetailCell];
    [_myTableView registerNib:[UINib nibWithNibName:@"SetLockMethod" bundle:nil] forCellReuseIdentifier:setLockMethod];
    _myTableView.tableFooterView = [[UIView alloc] init];
    
    bgView = [[UIView alloc] init];
    [self.view addSubview:bgView];
    bgView.hidden = YES;
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_myTableView);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [bgView addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWillHide) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyDidHide) name:UIKeyboardDidHideNotification object:nil];

    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:19+FontSizeAdjust];
    _saveBtn.layer.cornerRadius = _saveBtn.height/2.0;
    //lyh debug 50*6
    float footViewheight = SCREENHEIGHT - 64-iPhoneXTopPara-49-iPhoneXBottomPara-50-50*dataArray.count;
    if (footViewheight<90) {
        footViewheight = 90;
    }
    _footView.frame = CGRectMake(0, 0, SCREENWIDTH, footViewheight);
    _myTableView.tableFooterView = _footView;
}

- (void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void)keyWillShow{
    bgView.hidden = NO;
}


- (void)keyWillHide{
    bgView.hidden = YES;
}

- (void)keyDidHide{
//    if (isShowIncorrectPwd) {
//        [CNPromptView showStatusWithString:@"Incorrect Password"];
//        isShowIncorrectPwd = NO;
//    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    tempModel.periname = textField.text;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakself = self;
    if (_lockModel.isAdmin) {
        if (indexPath.row == 1) {
            ModifyPwdVC *pwd = [[ModifyPwdVC alloc] init];
            pwd.periModel = tempModel;
            pwd.pwdBlock = ^(NSString *str) {
                //periModel.periPwd = str;
                //[self updateNameAndPwd:NO];
            };
            [self.navigationController pushViewController:pwd animated:YES];
        }else if (indexPath.row == 2){
            OpenhistoryVC *history = [[OpenhistoryVC alloc] init];
            history.lockID = _lockModel.periID;
            [self.navigationController pushViewController:history animated:YES];
        }else if (indexPath.row == 3){
            UserControlVC *user = [[UserControlVC alloc] init];
            user.model = _lockModel;
            [self.navigationController pushViewController:user animated:YES];
        }else if (indexPath.row == 6){
            alert = [[NSBundle mainBundle] loadNibNamed:@"DeleteUnpairAlert" owner:self options:nil][0];
            alert.unpairedBlock = ^{
                [weakself unPaired];
            };
            alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:alert];
        }
    }else{
        if (indexPath.row == 3){
            alert = [[NSBundle mainBundle] loadNibNamed:@"DeleteUnpairAlert" owner:self options:nil][0];
            alert.unpairedBlock = ^{
                [weakself unPaired];
            };
            alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:alert];
        }
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_lockModel.isAdmin) {
        if (indexPath.row == 4) {
            return 100;
        }
    }else{
        if (indexPath.row == 1) {
            return 100;
        }
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int temp = 3;
    if (_lockModel.isAdmin) {
        temp = 0;
    }
    if (indexPath.row == 4-temp) {
        SetLockMethod *detailCell2 = [tableView dequeueReusableCellWithIdentifier:setLockMethod forIndexPath:indexPath];
        detailCell2.pwdBlock = ^(BOOL isPwd) {
            tempModel.isPwd = isPwd;
        };
        detailCell2.nameLab.text = dataArray[4-temp];
        [detailCell2 selectPwd:_lockModel.isPwd];
        return detailCell2;
    }
    SetDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:setDetailCell forIndexPath:indexPath];
    detailCell.imageV.hidden = YES;
    detailCell.mySwitch.hidden = YES;
    detailCell.textF.hidden = YES;
    detailCell.swichBlock = ^(BOOL isTouch) {
        tempModel.isTouchUnlock = isTouch;
    };
    detailCell.nameBlock = ^(NSString *name) {
        tempModel.periname = name;
    };
    if (_lockModel.isAdmin) {
        switch (indexPath.row) {
            case 0:{
                detailCell.textF.text = _lockModel.periname;
                detailCell.textF.hidden = NO;
                break;
            }
            case 1:{
                detailCell.textF.hidden = NO;
                detailCell.textF.secureTextEntry = YES;
                detailCell.textF.text = _lockModel.periPwd;
                detailCell.imageV.hidden = NO;
                detailCell.imageV.image = [UIImage imageNamed:@"chevron"];
                break;
            }
            case 2:{
                
                detailCell.imageV.hidden = NO;
                detailCell.imageV.image = [UIImage imageNamed:@"chevron"];
                break;
            }
            case 3:{
                detailCell.imageV.hidden = NO;
                detailCell.imageV.image = [UIImage imageNamed:@"chevron"];
                break;
            }
            case 5:{
                if (_lockModel.isTouchUnlock) {
                    detailCell.mySwitch.on = YES;
                }else{
                    detailCell.mySwitch.on = NO;
                }
                detailCell.mySwitch.hidden = NO;
                break;
            }
            case 6:{
                detailCell.imageV.hidden = NO;
                detailCell.imageV.image = [UIImage imageNamed:@"delete"];
                break;
            }
                
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:{
                detailCell.textF.enabled = NO;
                detailCell.textF.text = _lockModel.periname;
                detailCell.textF.hidden = NO;
                break;
            }
            case 2:{
                if (_lockModel.isTouchUnlock) {
                    detailCell.mySwitch.on = YES;
                }else{
                    detailCell.mySwitch.on = NO;
                }
                detailCell.mySwitch.hidden = NO;
                break;
            }
            case 3:{
                detailCell.imageV.hidden = NO;
                detailCell.imageV.image = [UIImage imageNamed:@"delete"];
                break;
            }
                
            default:
                break;
        }
    }
   
    detailCell.nameLab.text = dataArray[indexPath.row];
    return detailCell;
    
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

- (IBAction)save:(id)sender {
    //弹出输入密码框
    EnterPwdAlert *enterAlert = [[NSBundle mainBundle] loadNibNamed:@"EnterPwdAlert" owner:self options:nil][0];
    enterAlert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    __weak typeof(self) weakself = self;
    enterAlert.returnPasswordStringBlock = ^(NSString *pwd) {
        if ([pwd isEqualToString:_lockModel.periPwd]) {
            [weakself updateSetInfo];
        }else{
            //密码输错提示
            //isShowIncorrectPwd = YES;
            [CNPromptView showStatusWithString:@"Incorrect Password"];
        }
    };
    [enterAlert showWithName:_lockModel.periname];
    
//    saveAlert = [[NSBundle mainBundle] loadNibNamed:@"SaveSettingAlert" owner:self options:nil][0];
//    __weak typeof(self) weakself = self;
//    saveAlert.saveBlock = ^{
//        [weakself updateNameAndPwd:YES];
//    };
//    saveAlert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
//    [[UIApplication sharedApplication].keyWindow addSubview:saveAlert];
}
//保存锁具名称和密码
- (void)updateSetInfo{
    CNPeripheralModel *originalModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:_lockModel.periID];
    if (![originalModel.periname isEqualToString:tempModel.periname]) {
        for (CBPeripheral *peri in [CNBlueManager sharedBlueManager].connectedPeripheralArray) {
            if ([peri.identifier.UUIDString isEqualToString:_lockModel.periID]) {
                [CNBlueCommunication cbSendInstruction:ENChangeNameAndPwd toPeripheral:peri otherParameter:nil finish:^(RespondModel *model) {
                    if ([model.state intValue] == 1) {
                        //更新数据
                        _lockModel.periname = tempModel.periname;
                        _lockModel.isTouchUnlock = tempModel.isTouchUnlock;
                        _lockModel.isPwd = tempModel.isPwd;
                        _lockModel.actionType = ENUpdate;
                        //不传_lockModel也可以
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReload object:_lockModel];
                        [[CNDataBase sharedDataBase] updatePeripheralInfo:tempModel];
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        //lyh debug
                        [CNPromptView showStatusWithString:@"error"];
                    }
                }];
                break;
            }
        }
    }else{
        //更新数据
        _lockModel.isTouchUnlock = tempModel.isTouchUnlock;
        _lockModel.isPwd = tempModel.isPwd;
        _lockModel.actionType = ENUpdate;
        //不传_lockModel也可以
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReload object:_lockModel];
        [[CNDataBase sharedDataBase] updatePeripheralInfo:_lockModel];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)unPaired{
    //弹出输入密码框
    EnterPwdAlert *enterAlert = [[NSBundle mainBundle] loadNibNamed:@"EnterPwdAlert" owner:self options:nil][0];
    enterAlert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    enterAlert.returnPasswordStringBlock = ^(NSString *pwd) {
        if ([pwd isEqualToString:_lockModel.periPwd]) {
            //解除配对（不是管理员踢人操作）
            for (CBPeripheral *peri in [CNBlueManager sharedBlueManager].connectedPeripheralArray) {
                if ([peri.identifier.UUIDString isEqualToString:_lockModel.periID]) {
                    [[CNDataBase sharedDataBase] deletePairedWithIdentifier:peri.identifier.UUIDString];
                    _lockModel.actionType = ENDelete;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReload object:_lockModel];
                    [self.navigationController popViewControllerAnimated:YES];
                    break;
                }
            }
        }else{
            //密码输错提示
            //isShowIncorrectPwd = YES;
            [CNPromptView showStatusWithString:@"Incorrect Password"];
        }
    };
    [enterAlert showWithName:_lockModel.periname];
}

@end
