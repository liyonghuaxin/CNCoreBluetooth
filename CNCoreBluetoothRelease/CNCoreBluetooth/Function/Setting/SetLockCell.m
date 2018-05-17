//
//  SetLockCell.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "SetLockCell.h"

@implementation SetLockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _nameLab.textColor = TEXT_LIST_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
