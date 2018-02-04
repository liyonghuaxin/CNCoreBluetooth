//
//  CNAlertView.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNAlertView.h"

@implementation CNAlertView

-(void)awakeFromNib{
    [super awakeFromNib];
    _containerView.layer.cornerRadius = 4.0;
    _containerView.layer.masksToBounds = YES;
}

-(void)startAnimation{
    isAnimation = YES;
    [self beginAnimation];
}

-(void)stopAnimation{
    isAnimation = NO;
}

-(void)beginAnimation{
    //递归实现旋转动画
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI / 70.0f));
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageV.transform = endAngle;
    } completion:^(BOOL finished) {
        angle += 2;
        if (isAnimation) {
            [self beginAnimation];
        }
    }];
}

- (IBAction)cancelScan:(id)sender {
    self.hidden = YES;
    if (_alertBlock) {
        _alertBlock();
    }
}

@end
