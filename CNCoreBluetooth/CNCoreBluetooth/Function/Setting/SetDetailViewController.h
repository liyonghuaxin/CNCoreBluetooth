//
//  SetDetailViewController.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/6.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SetDetailViewController : BaseViewController
@property (nonatomic,copy) NSString *lockID;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
- (IBAction)save:(id)sender;

@end
