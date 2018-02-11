//
//  CNLockCell.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNLockCell.h"
#import "CNBlueCommunication.h"
#import "CNBlueManager.h"

@implementation CNLockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _lockNameLab.textColor = TEXT_LIST_COLOR;
    _lockNameLab.font = [UIFont systemFontOfSize:23+FontSizeAdjust];
    _pwdLab.textColor = TEXT_LIST_COLOR;
    _pwdLab.font = [UIFont systemFontOfSize:14+FontSizeAdjust];

    
    _slider.minimumTrackTintColor = THEME_BLACK_COLOR;
    _slider.maximumTrackTintColor = THEME_BLACK_COLOR;
    _slider.continuous = YES;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpOutside];
    _slider.minimumTrackTintColor = THEME_RED_COLOR;
    _slider.maximumTrackTintColor = THEME_BLACK_COLOR;
    //给滑动按钮设置图片
    [_slider setThumbImage:[UIImage imageNamed:@"ellipse"] forState:UIControlStateNormal];
    //给滑道左侧设置图片
    //[_slider setMinimumTrackImage:[UIImage imageNamed:@"navImage"] forState:UIControlStateNormal];
    //给滑道右侧设置图片
    //[_slider setMaximumTrackImage:[UIImage imageNamed:@"navImage"] forState:UIControlStateNormal];
}
-(void)setModel:(CNPeripheralModel *)model{
    _model = model;
    if (model.isPwd) {
        _pwdLab.hidden = NO;
    }else{
        _pwdLab.hidden = YES;
    }
    if (model.isTouchUnlock) {
        _fingerprintImagev.hidden = NO;
    }else{
        _fingerprintImagev.hidden = YES;
    }
}

- (void)sliderValueChanged:(id)sender{
    UISlider *slider = (UISlider *)sender;
    if (slider.value > 0.7) {
        slider.value = 1;
        _lockRight.image = [UIImage imageNamed:@"unlockRight"];
        _lockLeft.image = [UIImage imageNamed:@"unlockLeft"];
        //滑动开锁
        if ([self.delegate respondsToSelector:@selector(slideSuccess:)]) {
            [self.delegate slideSuccess:_model.peripheral];
        }
        //3秒后滑块自动返回
        dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
        dispatch_after(timer, dispatch_get_main_queue(), ^(void){
            slider.value = 0;
            _lockRight.image = [UIImage imageNamed:@"lockRight"];
            _lockLeft.image = [UIImage imageNamed:@"lockLeft"];
        });

        [CNPromptView showStatusWithString:@"Lock is Open"];
    }else{
        slider.value = 0;
        _lockRight.image = [UIImage imageNamed:@"lockRight"];
        _lockLeft.image = [UIImage imageNamed:@"lockLeft"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
