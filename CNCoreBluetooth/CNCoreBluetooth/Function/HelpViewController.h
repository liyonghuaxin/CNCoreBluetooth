//
//  HelpViewController.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SetModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL isSelect;

@end

@interface HelpViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end
