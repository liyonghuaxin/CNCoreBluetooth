//
//  DeleteUnpairAlert.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "DeleteUnpairAlert.h"

@implementation DeleteUnpairAlert

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    _bgView.layer.cornerRadius = 8.0;
    _bgView.layer.masksToBounds = YES;
}

- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)unpair:(id)sender {
    if (_unpairedBlock) {
        _unpairedBlock();
    }
    [self removeFromSuperview];
}
@end
