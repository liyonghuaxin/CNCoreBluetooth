//
//  EnterPwdAlert.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/17.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "EnterPwdAlert.h"

@implementation EnterPwdAlert

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [super awakeFromNib];

    _enterView.layer.borderColor = UIColorFromRGBH(0xc1c1c1).CGColor;
    _enterView.layer.borderWidth = 1.0;
    _enterView.backgroundColor = [UIColor whiteColor];
    
    _pwdBgView.layer.cornerRadius = 8.0;
    _pwdBgView.layer.masksToBounds = YES;
    
    _pwd1.secureTextEntry = YES;
    _pwd2.secureTextEntry = YES;
    _pwd3.secureTextEntry = YES;
    _pwd4.secureTextEntry = YES;
    _pwd5.secureTextEntry = YES;
    _pwd6.secureTextEntry = YES;
    
    [self.assistTF addTarget:self action:@selector(txchange:) forControlEvents:UIControlEventEditingChanged];
    
}

-(void)showWithName:(NSString *)name{
    self.hidden = NO;
    if (name) {
        _lockNameLab.text = name;
    }else{
        _lockNameLab.text = @"Unknown Device";
    }
    _pwd1.text = @"";
    _pwd2.text = @"";
    _pwd3.text = @"";
    _pwd4.text = @"";
    _pwd5.text = @"";
    _pwd6.text = @"";
    _assistTF.text = @"";
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.assistTF becomeFirstResponder];
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
        self.hidden = YES;
        [tx resignFirstResponder];//隐藏键盘
        if (self.returnPasswordStringBlock != nil) {
            self.returnPasswordStringBlock(password);
        }
    }
}

- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

@end
