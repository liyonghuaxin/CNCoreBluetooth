//
//  modifyPwdVC.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ModifyPwdVC.h"
#import "modifyPwdCell.h"

@interface ModifyPwdVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ModifyPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_myTableView registerNib:[UINib nibWithNibName:@"modifyPwdCell" bundle:nil] forCellReuseIdentifier:@"modifyPwdCell"];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    modifyPwdCell *cell = [tableView dequeueReusableCellWithIdentifier:@"modifyPwdCell" forIndexPath:indexPath];
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
