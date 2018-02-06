//
//  HelpCell.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "HelpCell.h"

@implementation HelpCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lineView.backgroundColor = LINE_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        CGAffineTransform angle;
        if (_isSelected) {
            angle = CGAffineTransformMakeRotation(0);
            _isSelected = NO;
            _lineView.hidden = NO;
        }else{
            angle = CGAffineTransformMakeRotation(M_PI /2);
            _isSelected = YES;
            _lineView.hidden = YES;
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.imageV.transform = angle;
        } completion:^(BOOL finished) {

        }];

    }
    // Configure the view for the selected state
}

@end
