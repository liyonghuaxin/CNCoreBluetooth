//
//  EnterPwdAlert.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/17.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterPwdAlert : UIView

- (void)showWithName:(NSString *)name;
@property (nonatomic,copy) void (^returnPasswordStringBlock)(NSString *pwd);

- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lockNameLab;
@property (weak, nonatomic) IBOutlet UITextField *pwd1;
@property (weak, nonatomic) IBOutlet UITextField *pwd4;
@property (weak, nonatomic) IBOutlet UITextField *pwd5;
@property (weak, nonatomic) IBOutlet UITextField *pwd3;
@property (weak, nonatomic) IBOutlet UITextField *pwd2;
@property (weak, nonatomic) IBOutlet UITextField *pwd6;
@property (weak, nonatomic) IBOutlet UITextField *assistTF;
@property (weak, nonatomic) IBOutlet UIView *enterView;
@property (weak, nonatomic) IBOutlet UIView *pwdBgView;

@end
