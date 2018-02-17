//
//  SetDetailCell.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/6.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "SetDetailCell.h"

@implementation SetDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _nameLab.textColor = TEXT_LIST_COLOR;
    [_mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    _textF.delegate = self;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (_nameBlock) {
        _nameBlock(textField.text);
    }
}

- (void)switchAction:(id)sender{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (_swichBlock) {
        _swichBlock(isButtonOn);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
