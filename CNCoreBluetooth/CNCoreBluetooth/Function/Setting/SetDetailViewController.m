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

static NSString *setDetailCell = @"SetDetailCell";

static NSString *setLockMethod = @"SetLockMethod";

@interface SetDetailViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UIView *bgView;
    NSArray *dataArray;
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
    if (indexPath.row == 1) {
        ModifyPwdVC *pwd = [[ModifyPwdVC alloc] init];
        [self.navigationController pushViewController:pwd animated:YES];
    }else if (indexPath.row == 2){
        OpenhistoryVC *history = [[OpenhistoryVC alloc] init];
        [self.navigationController pushViewController:history animated:YES];
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
        detailCell2.nameLab.text = dataArray[1];
        return detailCell2;
    }
    SetDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:setDetailCell forIndexPath:indexPath];
    detailCell.imageV.hidden = YES;
    detailCell.mySwitch.hidden = YES;
    detailCell.textF.hidden = YES;
    switch (indexPath.row) {
        case 0:{
            detailCell.textF.hidden = NO;
            break;
        }
        case 1:{
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

@end
