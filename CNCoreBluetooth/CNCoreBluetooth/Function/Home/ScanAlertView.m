//
//  ScanAlertView.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ScanAlertView.h"

@interface ScanAlertView()<UITableViewDelegate,UITableViewDataSource>{
    BOOL canDismiss;
    NSMutableArray *dataArray;
}
@end

@implementation ScanAlertView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    dataArray = [NSMutableArray array];
    
    _containerView.layer.cornerRadius = 8.0;
    _containerView.layer.masksToBounds = YES;
    _pwdBgView.layer.cornerRadius = 8.0;
    _pwdBgView.layer.masksToBounds = YES;
    
    _enterView.layer.borderColor = UIColorFromRGBH(0xc1c1c1).CGColor;
    _enterView.layer.borderWidth = 1.0;
    _enterView.backgroundColor = [UIColor whiteColor];
    
    _pwdBgView.hidden = YES;
    _containerView.hidden = NO;
    canDismiss = YES;
    
    [self.assistTF addTarget:self action:@selector(txchange:) forControlEvents:UIControlEventEditingChanged];

}

- (void)txchange:(UITextField *)tx{
    NSString *password = tx.text;
    for (int i = 0; i < 6; i++){
        UITextField *pwdtx = [_pwdBgView viewWithTag:i+1];
        pwdtx.text = @"";
        if (i < password.length)
        {
            NSString *pwd = [password substringWithRange:NSMakeRange(i, 1)];
            pwdtx.text = pwd;
        }
    }
    // 输入密码完毕
    if (password.length == 6){
        _showType = AlertSearch;
        self.hidden = YES;
        [tx resignFirstResponder];//隐藏键盘
        if (self.returnPasswordStringBlock != nil) {
            self.returnPasswordStringBlock(password);
        }
    }
}

-(void)setShowType:(AlertType)showType WithTitle:(NSString *)title{
    if (title.length) {
        _lockNameLab.text = title;
    }else{
        _lockNameLab.text = @"Unknown Device";
    }
    [self setShowType:showType];
}

-(void)setShowType:(AlertType)showType{
    _showType = showType;
    if (showType == AlertEnterPwd) {
        _pwd1.text = @"";
        _pwd2.text = @"";
        _pwd3.text = @"";
        _pwd4.text = @"";
        _pwd5.text = @"";
        _pwd6.text = @"";
        _assistTF.text = @"";
        [self.assistTF becomeFirstResponder];
        _pwdBgView.hidden = NO;
        canDismiss = NO;
        _containerView.hidden = YES;
        _listBgView.hidden = YES;
    }else if (showType == AlertLockList){
        canDismiss = NO;
        _containerView.hidden = YES;
        _pwdBgView.hidden = YES;
        _listBgView.hidden = NO;
        [self stopScan];
    }else{
        canDismiss = YES;
        _containerView.hidden = NO;
        _pwdBgView.hidden = YES;
        _listBgView.hidden = YES;
    }
}

-(void)beginScan{
    [self setShowType:AlertSearch];
    isAnimation = YES;
    self.hidden = NO;
    [self beginAnimation];
}

-(void)stopScan{
    isAnimation = NO;
    angle = 0;
    if (canDismiss) {
        self.hidden = YES;
    }
}

-(void)beginAnimation{
    //递归实现旋转动画
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI / 70.0f));
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageV.transform = endAngle;
    } completion:^(BOOL finished) {
        angle += 2;
        if (isAnimation) {
            [self beginAnimation];
        }
    }];
}

- (IBAction)cancelScan:(id)sender {
    canDismiss = YES;
    if (_showType == AlertSearch) {
        [self stopScan];
        if (_alertBlock) {
            _alertBlock();
        }
    }else{
        self.hidden = YES;
        if (self.canResignFirstResponder) {
            [self.assistTF resignFirstResponder];
        }
        if (isAnimation == YES) {
            isAnimation = NO;
        }
    }
}

-(void)updateDeviceInfo:(CNPeripheralModel *)lockModel{
    if (_showType != AlertLockList) {
        [dataArray removeAllObjects];
        [self setShowType:AlertLockList];
    }
    [dataArray addObject:lockModel];
    [_myTableView reloadData];
}

#pragma mark taleview delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CNPeripheralModel *periModel = (CNPeripheralModel *)dataArray[indexPath.row];
    [self setShowType:AlertEnterPwd WithTitle:periModel.periname];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
    }
    CNPeripheralModel *periModel = (CNPeripheralModel *)dataArray[indexPath.row];
    cell.textLabel.text = periModel.periname;
    return cell;
}

@end
