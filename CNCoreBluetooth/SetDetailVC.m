//
//  SetDetailVC.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "SetDetailVC.h"

@interface SetDetailVC ()

@end

@implementation SetDetailVC

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_tabbarBlock) {
        _tabbarBlock();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_slideBtn setImage:[UIImage imageNamed:@"btn_radio"] forState:UIControlStateNormal];
    [_slideBtn setImage:[UIImage imageNamed:@"btn_radio2"] forState:UIControlStateSelected];
    
    [_pawBtn setImage:[UIImage imageNamed:@"btn_radio"] forState:UIControlStateNormal];
    [_pawBtn setImage:[UIImage imageNamed:@"btn_radio2"] forState:UIControlStateSelected];
    
    [_touchBtn setImage:[UIImage imageNamed:@"btn_check1"] forState:UIControlStateNormal];
    [_touchBtn setImage:[UIImage imageNamed:@"btn_check2"] forState:UIControlStateSelected];
    
    _slideBtn.selected = YES;
    _pawBtn.selected = NO;
    _touchBtn.selected = NO;
    _saveBtn.layer.cornerRadius = 8;

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

- (IBAction)slideAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        _pawBtn.selected = YES;
        btn.selected = NO;
    }else{
        _pawBtn.selected = NO;
        btn.selected = YES;
    }
}

- (IBAction)pawAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        _slideBtn.selected = YES;
        btn.selected = NO;
    }else{
        _slideBtn.selected = NO;
        btn.selected = YES;
    }
}

- (IBAction)touchAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
}
- (IBAction)deleteAction:(id)sender {

}

- (IBAction)saveAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end