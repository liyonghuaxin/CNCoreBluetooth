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
}

@end

@implementation CNNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.translucent = NO;
    
    bgBiew = [[UIView alloc] init];
    [self.navigationBar addSubview:bgBiew];
    bgBiew.frame = CGRectMake(0, 0, SCREENWIDTH, 48);
    
    UIView *maskLineView = [[UIView alloc] init];
    maskLineView.frame = CGRectMake(0, 44, SCREENWIDTH, 1);
    maskLineView.backgroundColor = [UIColor whiteColor];
    [self.navigationBar addSubview:maskLineView];
    
    UIImageView *imageBg = [[UIImageView alloc] init];
    [bgBiew addSubview:imageBg];
    imageBg.image = [UIImage imageNamed:@"navBg"];
    [imageBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bgBiew);
    }];
    //-----------title view
    UIView *titleView = [[UIView alloc] init];
    [bgBiew addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SCREENWIDTH*300/750.0, 44));
        make.centerX.equalTo(bgBiew).with.offset(0);
        //因为 bgView 高48
        make.centerY.equalTo(bgBiew).with.offset(-2);
    }];
    //imageV1:34 27 imageV2:105 28
    UIImageView *imageV1 = [[UIImageView alloc] init];
    imageV1.image = [UIImage imageNamed:@"navImage"];
    imageV1.contentMode = UIViewContentModeCenter;
    [titleView addSubview:imageV1];
    [imageV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.equalTo(titleView);
        make.width.mas_equalTo(titleView).multipliedBy(34.0/105);
    }];
    UIImageView *imageV2 = [[UIImageView alloc] init];
    imageV2.image = [UIImage imageNamed:@"navTitle"];
    imageV2.contentMode = UIViewContentModeScaleAspectFit;
    [titleView addSubview:imageV2];
    [imageV2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageV1.mas_right);
        make.top.equalTo(imageV1);
        make.right.height.equalTo(titleView);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setRightBtn:(UIButton *)btn{
    [bgBiew addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(bgBiew);
        make.width.mas_equalTo(80);
        //因为 bgView 高48
        make.bottom.equalTo(bgBiew).with.offset(-4);
    }];
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
