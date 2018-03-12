//
//  saveSettingAlert.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaveSettingAlert : UIView
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
