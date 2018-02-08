//
//  ChangePwdAlert.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePwdAlert : UIView
@property (weak, nonatomic) IBOutlet UIImageView *containerView;
- (IBAction)cancel:(id)sender;
- (IBAction)update:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *rePwdTF;
@property (weak, nonatomic) IBOutlet UITextField *xinPwd;

@end
