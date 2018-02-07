//
//  modifyPwdVC.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ModifyPwdVC.h"
#import "modifyPwdCell.h"

@interface ModifyPwdVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *dataArray;
    UIView *bgView;
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
            break;
        }
        case 1:{
            cell.conTF.hidden = YES;
            break;
        }
        case 2:{
            
            break;
        }
        case 3:{
            
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

@end
