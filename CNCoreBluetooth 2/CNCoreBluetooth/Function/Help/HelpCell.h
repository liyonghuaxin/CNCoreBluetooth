//
//  HelpCell.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "BaseCell.h"

@interface HelpCell : BaseCell

@property (nonatomic, assign) BOOL isLook;
@property (weak, nonatomic) IBOutlet UILabel *questionLab;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
