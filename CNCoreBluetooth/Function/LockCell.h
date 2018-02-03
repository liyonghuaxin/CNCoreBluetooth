//
//  lockCell.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/30.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPeripheralModel.h"

@protocol LockCellActionDelegate <NSObject>

- (void)slideSuccess:(CBPeripheral *)peri;

@end

@interface LockCell : UITableViewCell

@property (nonatomic,copy) void(^actionBlock)(BOOL isConnect);

@property (nonatomic,strong)CNPeripheralModel *model;
@property (nonatomic,weak) id<LockCellActionDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *idLable;
@property (weak, nonatomic) IBOutlet UILabel *rssiLab;
@property (weak, nonatomic) IBOutlet UISlider *slider;

- (IBAction)connect:(id)sender;

@end
