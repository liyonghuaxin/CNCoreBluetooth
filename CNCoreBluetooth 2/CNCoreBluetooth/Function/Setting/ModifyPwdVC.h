//
//  modifyPwdVC.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "BaseViewController.h"

@interface ModifyPwdVC : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
- (IBAction)updatePwd:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *updatePwdBtn;
@property (strong, nonatomic) IBOutlet UIView *footView;

@end
