//
//  WeakModel.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/3/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WeakModel.h"
#import "CNBlueCommunication.h"

@implementation WeakModel

-(void)beginWeak{
    if (@available(iOS 10.0, *)) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self weakToLock];
        }];
    } else {
        _timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(weakToLock) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)weakToLock{
    //自动登录
    [CNBlueCommunication cbSendInstruction:ENAutoLogin toPeripheral:_peri otherParameter:nil finish:^(RespondModel *model) {
        [self cancelWeak];
        if ([model.state intValue] == 0) {
            [CNPromptView showStatusWithString:@"Lock Paired"];
        }
    }];
}

- (void)cancelTime{
    [_timer invalidate];
    _timer = nil;
}

@end
