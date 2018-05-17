//
//  SetDetailCell2.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/6.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPeripheralModel.h"

@interface SetLockMethod : UITableViewCell
@property (nonatomic, copy) void (^openBlock)(OpenLockMethod openMethod);
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *imageV1;
@property (weak, nonatomic) IBOutlet UIImageView *imageV11;
@property (weak, nonatomic) IBOutlet UIImageView *imageV2;
@property (weak, nonatomic) IBOutlet UIImageView *imageV22;
@property (weak, nonatomic) IBOutlet UIImageView *imageV3;
@property (weak, nonatomic) IBOutlet UIImageView *imageV33;
- (IBAction)selectAction:(id)sender;
- (void)selectMethod:(OpenLockMethod)openMethod;
@end
