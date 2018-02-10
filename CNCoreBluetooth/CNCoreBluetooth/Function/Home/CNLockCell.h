//
//  CNLockCell.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPeripheralModel.h"

@protocol LockCellActionDelegate <NSObject>

- (void)slideSuccess:(CBPeripheral *)peri;

@end

@interface CNLockCell : UITableViewCell

@property (nonatomic,strong)CNPeripheralModel *model;

@property (nonatomic,weak) id<LockCellActionDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lockNameLab;
@property (weak, nonatomic) IBOutlet UIImageView *lockLeft;
@property (weak, nonatomic) IBOutlet UIImageView *lockRight;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIImageView *fingerprintImagev;
@property (weak, nonatomic) IBOutlet UILabel *pwdLab;

@end
