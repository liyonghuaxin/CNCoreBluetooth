//
//  ScanAlertView.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPeripheralModel.h"

typedef enum : NSUInteger {
    AlertSearch,
    AlertEnterPwd,
    AlertLockList,
} AlertType;

@interface ScanAlertView : UIView{
    CGFloat angle;
    BOOL isAnimation;
}

- (void)beginScan;
- (void)stopScanAnimation;

@property (nonatomic,assign) AlertType showType;
-(void)setShowType:(AlertType)showType WithPeripheral:(CBPeripheral *)peri withLockName:(NSString *)name;
- (void)updateDeviceInfo:(CNPeripheralModel *)lockModel;
@property (nonatomic,copy) void (^alertBlock)(void);
@property (nonatomic,copy) void (^returnPasswordStringBlock)(NSString *pwd, CBPeripheral *peri);
@property (weak, nonatomic) IBOutlet UIView *listBgView;

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
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
