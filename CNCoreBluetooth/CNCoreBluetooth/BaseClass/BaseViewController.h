//
//  BaseViewController.h
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UILabel *headLable;

- (void)setRightBtn:(UIButton *)btn;
- (void)setLeftBtn: (UIButton *)btn;
- (void)setBackBtnHiden:(BOOL)isHiden;
- (void)rotate;

@end
