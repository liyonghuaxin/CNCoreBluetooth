//
//  saveSettingAlert.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "SaveSettingAlert.h"

@implementation SaveSettingAlert

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [super awakeFromNib];
    _containerView.layer.cornerRadius = 8.0;
    _containerView.layer.masksToBounds = YES;
    [self.pwdTF becomeFirstResponder];

}
- (IBAction)save:(id)sender {
    //lyh debug 管理员密码
    if (_saveBlock) {
        _saveBlock();
    }
    [self removeFromSuperview];
}

- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}
@end
