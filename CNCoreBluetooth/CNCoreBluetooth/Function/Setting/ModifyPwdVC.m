//
//  modifyPwdVC.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ModifyPwdVC.h"
#import "modifyPwdCell.h"
#import "UIView+KGViewExtend.h"
#import "CNBlueManager.h"
#import "CNDataBase.h"
#import "CNBlueCommunication.h"

@interface ModifyPwdVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSArray *dataArray;
    UIView *bgView;
    NSString *curPwd;
    NSString *pwd1;
    NSString *pwd2;

}

@end

@implementation ModifyPwdVC

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
    self.headView.hidden = NO;
    UILabel *label = [[UILabel alloc] init];
    [self.headView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.headImageV);
    }];
    label.font = TEXT_HEAD_FONT;
    label.textColor = TEXT_HEAD_COLOR;
    label.text = @"QUICK SAFE";
    
    dataArray = @[@"Current password",@"",@"New Password",@"Re-Enter Password",];
    
    [_myTableView registerNib:[UINib nibWithNibName:@"modifyPwdCell" bundle:nil] forCellReuseIdentifier:@"modifyPwdCell"];
    _myTableView.tableFooterView = [[UIView alloc] init];
    _myTableView.scrollEnabled = NO;
    
    bgView = [[UIView alloc] init];
    [self.view addSubview:bgView];
    bgView.hidden = YES;
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_myTableView);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [_myTableView addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWillHide) name:UIKeyboardWillHideNotification object:nil];

    _updatePwdBtn.titleLabel.font = [UIFont systemFontOfSize:19+FontSizeAdjust];
    _updatePwdBtn.layer.cornerRadius = _updatePwdBtn.height/2.0;
    //lyh debug 50*4
    float footViewheight = SCREENHEIGHT - 64-iPhoneXTopPara-49-iPhoneXBottomPara-50-50*4;
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
    float footViewheight = 90;
    if (SCREENHEIGHT <= 568) {
        footViewheight = 70;
    }
    _footView.frame = CGRectMake(0, 0, SCREENWIDTH, footViewheight);
    _myTableView.tableFooterView = _footView;
}

- (void)keyWillHide{
    float footViewheight = SCREENHEIGHT - 64-iPhoneXTopPara-49-iPhoneXBottomPara-50-50*4;
    if (footViewheight<90) {
        footViewheight = 90;
    }
    _footView.frame = CGRectMake(0, 0, SCREENWIDTH, footViewheight);
    _myTableView.tableFooterView = _footView;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.layer.borderWidth=0.5f;
    textField.layer.cornerRadius = 5.0;
    textField.layer.borderColor=[UIColor blackColor].CGColor;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *newtxt = [NSMutableString stringWithString:textField.text];
    [newtxt replaceCharactersInRange:range withString:string];
    if (newtxt.length > 6) return NO;
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        curPwd = textField.text;
    }else if(textField.tag == 2){
        pwd1 = textField.text;
    }else{
        pwd2 = textField.text;
    }
    textField.layer.borderWidth=0.5f;
    textField.layer.cornerRadius = 5.0;
    textField.layer.borderColor=UIColorFromRGBH(0xcdcdcd).CGColor;}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    modifyPwdCell *cell = [tableView dequeueReusableCellWithIdentifier:@"modifyPwdCell" forIndexPath:indexPath];
    cell.nameLab.text = dataArray[indexPath.row];
    switch (indexPath.row) {
        case 0:{
            cell.conTF.text = @"";
            cell.conTF.delegate = self;
            cell.conTF.tag = 1;
            break;
        }
        case 1:{
            cell.conTF.hidden = YES;
            break;
        }
        case 2:{
            cell.conTF.text = @"";
            cell.conTF.delegate = self;
            cell.conTF.tag = 2;
            break;
        }
        case 3:{
            cell.conTF.text = @"";
            cell.conTF.delegate = self;
            cell.conTF.tag = 3;
            break;
        }
        default:
            break;
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

- (IBAction)updatePwd:(id)sender {
    //先判断当前密码
    if (curPwd.length == 6 && [curPwd isEqualToString:_periModel.periPwd]) {
        if (pwd1.length == 6 && [pwd1 isEqualToString:pwd2]) {
//            if (_pwdBlock) {
//                _pwdBlock(pwd1);
//            }
            [self updateSetInfo];
        }else{
            //两次密码不一致 或 密码位数错误
            //lyh debug
            [CNPromptView showStatusWithString:@"error"];
        }
    }else{
        //原始密码错误
        //lyh debug
        [CNPromptView showStatusWithString:@"原始密码错误"];
    }
    
}

//保存锁具名称和密码
- (void)updateSetInfo{
    //实际这里只修改名字了，密码修改不在这个页面
    for (CBPeripheral *peri in [CNBlueManager sharedBlueManager].connectedPeripheralArray) {
        if ([peri.identifier.UUIDString isEqualToString:_periModel.periID]) {
            [CNBlueCommunication cbSendInstruction:ENChangeNameAndPwd toPeripheral:peri otherParameter:nil finish:^(RespondModel *model) {
                if ([model.state intValue] == 1) {
                    _periModel.periPwd = pwd1;
                    //更新本地数据
                    [[CNDataBase sharedDataBase] updatePeripheralInfo:_periModel];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    //lyh debug
                    [CNPromptView showStatusWithString:@"error"];
                }
            }];
            break;
        }
    }
}
@end
