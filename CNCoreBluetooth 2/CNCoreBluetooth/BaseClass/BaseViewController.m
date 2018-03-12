//
//  BaseViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "BaseViewController.h"
#import "CNNavController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    _headView = [[UIView alloc] init];
    [self.view addSubview:_headView];
    [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    _headImageV = [[UIImageView alloc] init];
    [_headView addSubview:_headImageV];
    _headImageV.contentMode = UIViewContentModeLeft;
    [_headImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headView).with.offset(edgeDistancePage);
        make.right.top.bottom.equalTo(_headView);
    }];
    UIView *lineView = [[UIView alloc] init];
    [_headView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_headView);
        make.height.mas_equalTo(1);
    }];
    lineView.backgroundColor = LINE_COLOR;
    
    _headView.hidden = YES;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setBackBtnHiden:(BOOL)isHiden{
    CNNavController *nav = (CNNavController *)self.navigationController;
    [nav setBackBtnHiden:isHiden];
}

-(void)setRightBtn:(UIButton *)btn{
    if (btn) {
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, edgeDistancePage);
    }
    CNNavController *nav = (CNNavController *)self.navigationController;
    [nav setRightBtn:btn];
}

-(void)setLeftBtn:(UIButton *)btn{
    if (btn) {
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, edgeDistancePage, 0, 0);
    }
    CNNavController *nav = (CNNavController *)self.navigationController;
    [nav setLeftBtn:btn];
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
