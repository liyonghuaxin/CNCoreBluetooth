//
//  SetDetailCell2.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/6.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "SetLockMethod.h"

@implementation SetLockMethod

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1 && _isPwd) {
        _isPwd = NO;
        _imageV1.image = [UIImage imageNamed:@"ellipseRed"];
        _imageV11.image = [UIImage imageNamed:@"ellipseWhite"];
        _imageV2.image = [UIImage imageNamed:@"ellipseGray"];
        _imageV22.image = [UIImage imageNamed:@""];
    }else{
        if (_isPwd == NO) {
            _isPwd = YES;
            _imageV1.image = [UIImage imageNamed:@"ellipseGray"];
            _imageV11.image = [UIImage imageNamed:@""];
            _imageV2.image = [UIImage imageNamed:@"ellipseRed"];
            _imageV22.image = [UIImage imageNamed:@"ellipseWhite"];
        }
    }
}
@end
