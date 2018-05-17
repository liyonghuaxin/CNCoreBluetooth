//
//  openHistoryCell.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "BaseCell.h"

@interface OpenHistoryCell : BaseCell
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *macAddress;
@property (weak, nonatomic) IBOutlet UILabel *openMethod;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;

@end
