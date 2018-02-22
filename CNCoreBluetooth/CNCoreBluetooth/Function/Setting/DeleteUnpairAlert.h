//
//  DeleteUnpairAlert.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeleteUnpairAlert : UIView


@property (nonatomic, copy) void(^unpairedBlock)(void);

- (IBAction)cancel:(id)sender;
- (IBAction)unpair:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
