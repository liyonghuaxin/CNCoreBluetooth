//
//  CNNavController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "CNNavController.h"
#import <Masonry.h>

@interface CNNavController (){
    UIView *bgBiew;
    UIButton *leftBtn;
    UIButton *rightBtn;
    UIButton *backBtn;
}

@end

@implementation CNNavController
-(void)rotate{
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, edgeDistancePage, 0, 0);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.translucent = NO;
    
    if ([CommonData deviceIsIpad]) {
        
    }else{
        bgBiew = [[UIView alloc] init];
        [self.navigationBar addSubview:bgBiew];
        bgBiew.frame = CGRectMake(0, 0, SCREENWIDTH, 48);
        UIView *maskLineView = [[UIView alloc] init];
        maskLineView.frame = CGRectMake(0, 44, SCREENWIDTH, 1);
        maskLineView.backgroundColor = [UIColor whiteColor];
        [bgBiew addSubview:maskLineView];
        
        UIImageView *imageBg = [[UIImageView alloc] init];
        [bgBiew addSubview:imageBg];
        //imageBg.contentMode = UIViewContentModeBottom;
        imageBg.image = [UIImage imageNamed:@"navBg"];
        [imageBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(bgBiew);
        }];
        //-----------title view
        UIView *titleView = [[UIView alloc] init];
        [bgBiew addSubview:titleView];
        [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            // make.size.mas_equalTo(CGSizeMake(SCREENWIDTH*300/750.0, 44));
            make.size.mas_equalTo(CGSizeMake(150, 44));
            make.centerX.equalTo(bgBiew).with.offset(0);
            //因为 bgView 高48
            make.centerY.equalTo(bgBiew).with.offset(-2);
        }];
        //70 16 215
        //imageV1:34 27 imageV2:105 28
        UIImageView *imageV1 = [[UIImageView alloc] init];
        imageV1.image = [UIImage imageNamed:@"navImage"];
        imageV1.contentMode = UIViewContentModeCenter;
        [titleView addSubview:imageV1];
        [imageV1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.height.equalTo(titleView);
            make.width.mas_equalTo(titleView).multipliedBy(70.0/300);
        }];
        
        UIImageView *imageV2 = [[UIImageView alloc] init];
        imageV2.image = [UIImage imageNamed:@"navTitle"];
        imageV2.contentMode = UIViewContentModeCenter;
        [titleView addSubview:imageV2];
        [imageV2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageV1);
            make.right.height.equalTo(titleView);
            make.width.mas_equalTo(titleView).multipliedBy(215.0/300);
        }];
        
        //返回按钮
        backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bgBiew addSubview:backBtn];
        [backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, edgeDistancePage, 0, 0);
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(bgBiew);
            make.width.mas_equalTo(100);
            //因为 bgView 高48
            make.bottom.equalTo(bgBiew).with.offset(-4);
        }];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        backBtn.hidden = YES;
    }
}
 
- (void)backAction{
    [self popViewControllerAnimated:YES];
}

-(void)setBackBtnHiden:(BOOL)isHiden{
    backBtn.hidden = isHiden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLeftBtn:(UIButton *)btn{
    if (btn) {
        leftBtn = btn;
        [bgBiew addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(bgBiew);
            make.width.mas_equalTo(80);
            //因为 bgView 高48
            make.bottom.equalTo(bgBiew).with.offset(-4);
        }];
    }else{
        if (leftBtn) {
            [leftBtn removeFromSuperview];
        }
    }
}

-(void)setRightBtn:(UIButton *)btn{
    if (btn) {
        rightBtn = btn;
        [bgBiew addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(bgBiew);
            make.width.mas_equalTo(100);
            //因为 bgView 高48
            make.bottom.equalTo(bgBiew).with.offset(-4);
        }];
    }else{
        if (rightBtn) {
            [rightBtn removeFromSuperview];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
