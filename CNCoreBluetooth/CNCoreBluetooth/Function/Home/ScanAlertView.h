//
//  ScanAlertView.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AlertSearch,
    AlertEnterPwd,
} AlertType;

@interface ScanAlertView : UIView{
    CGFloat angle;
    BOOL isAnimation;
}

- (void)beginScan;
- (void)stopScan;

@property (nonatomic,assign) AlertType showType;
-(void)setShowType:(AlertType)showType WithTitle:(NSString *)title;
@property (nonatomic,copy) void (^alertBlock)(void);
@property (nonatomic,copy) void (^returnPasswordStringBlock)(NSString *pwd);

@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lockNameLab;
@property (weak, nonatomic) IBOutlet UITextField *pwd1;
@property (weak, nonatomic) IBOutlet UITextField *pwd2;
@property (weak, nonatomic) IBOutlet UITextField *pwd3;
@property (weak, nonatomic) IBOutlet UITextField *pwd4;
@property (weak, nonatomic) IBOutlet UITextField *pwd5;
@property (weak, nonatomic) IBOutlet UITextField *pwd6;
@property (weak, nonatomic) IBOutlet UIView *pwdBgView;
@property (weak, nonatomic) IBOutlet UIView *enterView;
@property (weak, nonatomic) IBOutlet UITextField *assistTF;
- (IBAction)cancelScan:(id)sender;

@end
