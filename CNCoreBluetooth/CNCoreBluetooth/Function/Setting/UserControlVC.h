//
//  UserControlVC.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/3/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "BaseViewController.h"
#import "CNPeripheralModel.h"

@interface UserControlVC : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) CNPeripheralModel *model;
@end
