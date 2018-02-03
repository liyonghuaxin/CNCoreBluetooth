//
//  SetDetailVC.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetDetailVC : UIViewController


@property (nonatomic,copy) void (^tabbarBlock)(void);
@property (nonatomic,copy) NSString *periID;
@property (weak, nonatomic) IBOutlet UITextField *lockNameTf;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *pawLab;
@property (weak, nonatomic) IBOutlet UILabel *lockModelLab;
@property (weak, nonatomic) IBOutlet UILabel *enableTouchLab;
@property (weak, nonatomic) IBOutlet UILabel *deleteLab;
@property (weak, nonatomic) IBOutlet UIButton *slideBtn;
@property (weak, nonatomic) IBOutlet UIButton *pawBtn;
- (IBAction)slideAction:(id)sender;
- (IBAction)pawAction:(id)sender;
- (IBAction)touchAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *touchBtn;
- (IBAction)deleteAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
- (IBAction)saveAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
- (IBAction)cancelAction:(id)sender;

@end
