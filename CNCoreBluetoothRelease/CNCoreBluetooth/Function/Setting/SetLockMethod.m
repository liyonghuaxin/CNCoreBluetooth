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
    _nameLab.textColor = TEXT_LIST_COLOR;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)selectMethod:(OpenLockMethod)openMethod{
    if (openMethod == OpenLockSlide) {
        _imageV1.image = [UIImage imageNamed:@"ellipseRed"];
        _imageV11.image = [UIImage imageNamed:@"ellipseWhite"];
        _imageV2.image = [UIImage imageNamed:@"ellipseGray"];
        _imageV22.image = nil;
        _imageV3.image = [UIImage imageNamed:@"ellipseGray"];
        _imageV33.image = nil;
    }else if (openMethod == OpenLockThumb){
        _imageV2.image = [UIImage imageNamed:@"ellipseRed"];
        _imageV22.image = [UIImage imageNamed:@"ellipseWhite"];
        _imageV1.image = [UIImage imageNamed:@"ellipseGray"];
        _imageV11.image = nil;
        _imageV3.image = [UIImage imageNamed:@"ellipseGray"];
        _imageV33.image = nil;
    }else{
        _imageV3.image = [UIImage imageNamed:@"ellipseRed"];
        _imageV33.image = [UIImage imageNamed:@"ellipseWhite"];
        _imageV1.image = [UIImage imageNamed:@"ellipseGray"];
        _imageV11.image = nil;
        _imageV2.image = [UIImage imageNamed:@"ellipseGray"];
        _imageV22.image = nil;
    }
    if (_openBlock) {
        _openBlock(openMethod);
    }
}

- (IBAction)selectAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1) {
        [self selectMethod:OpenLockSlide];
    }else if (btn.tag == 2 ){
        [self selectMethod:OpenLockThumb];
    }else{
        [self selectMethod:OpenLockPwd];
    }
}
@end
