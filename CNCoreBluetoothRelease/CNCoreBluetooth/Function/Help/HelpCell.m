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
    _questionLab.font = [UIFont systemFontOfSize:18+FontSizeAdjust];
    _lineView.backgroundColor = LINE_COLOR;
    if (@available(iOS 8.2, *)) {
        _questionLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    } else {
        // Fallback on earlier versions
    }
}

-(void)setIsLook:(BOOL)isLook{
    _isLook = isLook;
    CGAffineTransform angle;
    if (isLook) {
        angle = CGAffineTransformMakeRotation(M_PI /2);
        _lineView.hidden = YES;
    }else{
        angle = CGAffineTransformMakeRotation(0);
        _lineView.hidden = NO;
    }
    self.imageV.transform = angle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
