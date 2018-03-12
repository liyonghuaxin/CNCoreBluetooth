//
//  CNPromptView.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNPromptView.h"

@interface CNPromptView()

@property (nonatomic, strong, readonly) NSTimer *fadeOutTimer;

@end

@implementation CNPromptView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+(void)showStatusWithString:(NSString *)message{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *showView = [[UIView alloc] init];
    showView.backgroundColor = [UIColor blackColor];
    showView.frame = CGRectMake(1, 1, 1, 1);
    showView.alpha = 1.0f;
    showView.layer.cornerRadius = 5.0f;
    showView.layer.masksToBounds = YES;
    [window addSubview:showView];
    
    UILabel *label = [[UILabel alloc] init];
    UIFont *font = [UIFont systemFontOfSize:15];
    CGRect labelRect = [message boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    label.frame = CGRectMake(10, 3, ceil(CGRectGetWidth(labelRect)), CGRectGetHeight(labelRect));
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [showView addSubview:label];
    
    showView.frame = CGRectMake((SCREENWIDTH - CGRectGetWidth(labelRect) - 20)/2, SCREENHEIGHT-(CGRectGetHeight(labelRect)+10)-49-iPhoneXBottomPara-edgeDistancePage, CGRectGetWidth(labelRect)+20, CGRectGetHeight(labelRect)+10);
    [UIView animateWithDuration:2 animations:^{
        showView.alpha = 0;
    } completion:^(BOOL finished) {
        [showView removeFromSuperview];
    }];
    
}

@end
