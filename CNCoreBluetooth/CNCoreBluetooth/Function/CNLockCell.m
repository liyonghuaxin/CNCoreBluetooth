//
//  CNLockCell.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNLockCell.h"

@implementation CNLockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _slider.minimumTrackTintColor = THEME_BLACK_COLOR;
    _slider.maximumTrackTintColor = THEME_BLACK_COLOR;
    _slider.continuous = YES;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(sliderValueChanged2:) forControlEvents:UIControlEventTouchUpOutside];

    //给滑动按钮设置图片
    [_slider setThumbImage:[UIImage imageNamed:@"ellipse"] forState:UIControlStateNormal];
    //给滑道左侧设置图片
    //[_slider setMinimumTrackImage:[UIImage imageNamed:@"navImage"] forState:UIControlStateNormal];
    //给滑道右侧设置图片
    //[_slider setMaximumTrackImage:[UIImage imageNamed:@"navImage"] forState:UIControlStateNormal];
}
-(void)setModel:(CNPeripheralModel *)model{
    _model = model;
    _pwdLab.hidden = YES;
    _fingerprintImagev.hidden = YES;
}
- (void)sliderValueChanged2:(id)sender{
    UISlider *slider = (UISlider *)sender;
    if (slider.value > 0.92) {
        slider.value = 1;
        [CNPromptView showStatusWithString:@"Lock is Open"];
    }else{
        slider.value = 0;
    }
}
- (void)sliderValueChanged:(id)sender{
    UISlider *slider = (UISlider *)sender;
    if (slider.value > 0.92) {
        slider.value = 1;
        [CNPromptView showStatusWithString:@"Lock is Open"];
    }else{
        slider.value = 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
