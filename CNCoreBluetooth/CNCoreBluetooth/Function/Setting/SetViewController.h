//
//  SetViewController.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SetViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
- (IBAction)setlanguage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *setLanguageBtn;
@property (weak, nonatomic) IBOutlet UIButton *changAdminPwdBtn;
- (IBAction)changeAdminPed:(id)sender;

@end
