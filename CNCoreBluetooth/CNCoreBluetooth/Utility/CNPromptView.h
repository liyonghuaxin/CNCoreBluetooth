//
//  CNPromptView.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNPromptView : UIView

+ (void)showStatusWithString:(NSString *)message;
+(void)showStatusWithString:(NSString *)message withadjustBottomSpace:(float)space;
@end
