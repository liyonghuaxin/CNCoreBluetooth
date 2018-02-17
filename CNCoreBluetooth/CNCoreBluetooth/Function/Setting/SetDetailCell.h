//
//  SetDetailCell.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/6.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetDetailCell : UITableViewCell<UITextFieldDelegate>
@property (nonatomic, copy) void (^swichBlock)(BOOL isTouch);
@property (nonatomic, copy) void (^nameBlock)(NSString *name);

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UITextField *textF;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;

@end
