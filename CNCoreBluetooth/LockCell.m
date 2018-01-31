//
//  lockCell.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/30.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "LockCell.h"
#import "CNBlueManager.h"

@implementation LockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _slider.minimumValue = 0.0;
    _slider.maximumValue = 100.0;
    _slider.value = 0.0;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];

    [_connectBtn setTitle:@"连接" forState:UIControlStateNormal];
    [_connectBtn setTitle:@"取消" forState:UIControlStateSelected];
}

-(void)setModel:(CNPeripheralModel *)model{
    _model = model;
    if (model.peripheral.name) {
        self.nameLab.text = model.peripheral.name;
    }else{
        self.nameLab.text = @"未知设备";
    }
    if (model.peripheral.state == CBPeripheralStateConnected) {
        self.nameLab.textColor = [UIColor redColor];
        self.connectBtn.selected = YES;
    }else{
        self.nameLab.textColor = [UIColor blackColor];
        self.connectBtn.selected = NO;
    }
    self.idLable.text = model.peripheral.identifier.UUIDString;
    //self.rssiLab.text = [peri.RSSI stringValue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)sliderValueChanged:(id)sender{
    UISlider *slider = (UISlider *)sender;
    if (slider.value > 90) {
        slider.value = 100;
        //滑动开锁
        [[CNBlueManager sharedBlueManager] senddata:@"01" toPeripheral:_model.peripheral];
    }else{
        slider.value = 0;
    }
}

- (IBAction)connect:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        if (_actionBlock) {
            _actionBlock(NO);
        }
    }else{
        if (_actionBlock) {
            _actionBlock(YES);
        }
    }
}
@end
