//
//  ChangePwdAlert.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ChangePwdAlert.h"

@implementation ChangePwdAlert

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
    [self.xinPwd becomeFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)update:(id)sender {
    [self removeFromSuperview];
}
@end
