//
//  CNNavController.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNNavController : UINavigationController

-(void)setRightBtn:(UIButton *)btn;
-(void)setLeftBtn:(UIButton *)btn;
- (void)setBackBtnHiden:(BOOL)isHiden;
- (void)rotate;

@end
