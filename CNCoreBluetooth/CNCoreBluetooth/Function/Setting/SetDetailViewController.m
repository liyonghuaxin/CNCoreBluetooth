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

static NSString *setDetailCell = @"SetDetailCell";

static NSString *setLockMethod = @"SetLockMethod";

@interface SetDetailViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UIView *bgView;
    NSArray *dataArray;
    DeleteUnpairAlert *alert;
    SaveSettingAlert *saveAlert;
    CNPeripheralModel *periModel;
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    periModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:_lockID];
    
    dataArray = @[@"Name",@"Password",@"Open History",@"Unlock Mode",@"Enable TouchSafe Sensor",@"Unpair Device"];
    
    [_myTableView registerNib:[UINib nibWithNibName:@"SetDetailCell" bundle:nil] forCellReuseIdentifier:setDetailCell];
    [_myTableView registerNib:[UINib nibWithNibName:@"SetLockMethod" bundle:nil] forCellReuseIdentifier:setLockMethod];
    _myTableView.scrollEnabled = NO;
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
    
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:19+FontSizeAdjust];
    _saveBtn.layer.cornerRadius = _saveBtn.height/2.0;
    //lyh debug 50*6
    float footViewheight = SCREENHEIGHT - 64-iPhoneXTopPara-49-iPhoneXBottomPara-50-50*6;
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

-(void)textFieldDidEndEditing:(UITextField *)textField{
    periModel.periname = textField.text;
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
    if (indexPath.row == 1) {
        ModifyPwdVC *pwd = [[ModifyPwdVC alloc] init];
        pwd.periModel = periModel;
        pwd.pwdBlock = ^(NSString *str) {
            periModel.periPwd = str;
            [self updateNameAndPwd:NO];
        };
        [self.navigationController pushViewController:pwd animated:YES];
    }else if (indexPath.row == 2){
        OpenhistoryVC *history = [[OpenhistoryVC alloc] init];
        history.lockID = periModel.periID;
        [self.navigationController pushViewController:history animated:YES];
    }else if (indexPath.row == 5){
        alert = [[NSBundle mainBundle] loadNibNamed:@"DeleteUnpairAlert" owner:self options:nil][0];
        alert.unpairedBlock = ^{
            [weakself unPaired];
        };
        alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:alert];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        return 100;
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        SetLockMethod *detailCell2 = [tableView dequeueReusableCellWithIdentifier:setLockMethod forIndexPath:indexPath];
        detailCell2.pwdBlock = ^(BOOL isPwd) {
            periModel.isPwd = isPwd;
        };
        detailCell2.nameLab.text = dataArray[3];
        [detailCell2 selectPwd:periModel.isPwd];
        return detailCell2;
    }
    SetDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:setDetailCell forIndexPath:indexPath];
    detailCell.imageV.hidden = YES;
    detailCell.mySwitch.hidden = YES;
    detailCell.textF.hidden = YES;
    detailCell.swichBlock = ^(BOOL isTouch) {
        periModel.isTouchUnlock = isTouch;
    };
    detailCell.nameBlock = ^(NSString *name) {
        periModel.periname = name;
    };
    switch (indexPath.row) {
        case 0:{
            detailCell.textF.text = periModel.periname;
            detailCell.textF.hidden = NO;
            break;
        }
        case 1:{
            detailCell.textF.hidden = NO;
            detailCell.textF.secureTextEntry = YES;
            detailCell.textF.text = periModel.periPwd;
            detailCell.imageV.hidden = NO;
            detailCell.imageV.image = [UIImage imageNamed:@"chevron"];
            break;
        }
        case 2:{
            detailCell.imageV.hidden = NO;
            detailCell.imageV.image = [UIImage imageNamed:@"chevron"];
            break;
        }
        case 4:{
            if (periModel.isTouchUnlock) {
                detailCell.mySwitch.on = YES;
            }else{
                detailCell.mySwitch.on = NO;
            }
            detailCell.mySwitch.hidden = NO;
            break;
        }
        case 5:{
            detailCell.imageV.hidden = NO;
            detailCell.imageV.image = [UIImage imageNamed:@"delete"];
            break;
        }
            
        default:
            break;
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
    saveAlert = [[NSBundle mainBundle] loadNibNamed:@"SaveSettingAlert" owner:self options:nil][0];
    __weak typeof(self) weakself = self;
    saveAlert.saveBlock = ^{
        [weakself updateNameAndPwd:YES];
    };
    saveAlert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:saveAlert];
}
//保存锁具名称和密码
- (void)updateNameAndPwd:(BOOL)isBack{
    CNPeripheralModel *originalModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:_lockID];
    
    //更新本地数据
    [[CNDataBase sharedDataBase] updatePeripheralInfo:periModel];

    if (![originalModel.periname isEqualToString:periModel.periname] || ![originalModel.periPwd isEqualToString:periModel.periPwd]) {
        for (CBPeripheral *peri in [CNBlueManager sharedBlueManager].connectedPeripheralArray) {
            if ([peri.identifier.UUIDString isEqualToString:periModel.periID]) {
                [CNBlueCommunication cbSendInstruction:ENChangeNameAndPwd toPeripheral:peri finish:nil];
                break;
            }
        }
    }
    
    if (![originalModel.periname isEqualToString:periModel.periname]){
        //当蓝牙名字修改后相关数据的变动
        int i = 0;
        for (CNPeripheralModel *model in [CommonData sharedCommonData].listPeriArr) {
            if ([model.periID isEqualToString:periModel.periID]) {
                break;
            }
            i++;
        }
        [[CommonData sharedCommonData].listPeriArr replaceObjectAtIndex:i withObject:periModel];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReload object:periModel];
    }
    
    if (isBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)unPaired{
    //解除配对
    for (CBPeripheral *peri in [CNBlueManager sharedBlueManager].connectedPeripheralArray) {
        if ([peri.identifier.UUIDString isEqualToString:periModel.periID]) {
            [CNBlueCommunication cbSendInstruction:ENUnpair toPeripheral:peri finish:nil];
            break;
        }
    }
}

@end
