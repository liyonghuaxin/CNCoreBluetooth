//
//  CNAlertView.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanAlertView : UIView{
    CGFloat angle;
    BOOL isAnimation;
}

@property (nonatomic,strong) void (^alertBlock)(void);
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
- (IBAction)cancelScan:(id)sender;
- (void)startAnimation;
- (void)stopAnimation;
@end
