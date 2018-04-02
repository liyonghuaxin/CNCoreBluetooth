//
//  BaseViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/2/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "BaseViewController.h"
#import "CNNavController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

-(void)rotate{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([CommonData deviceIsIpad]) {
        //-----------title view
        UIView *titleView = [[UIView alloc] init];
        titleView.frame = CGRectMake(0, 0, 100, 50);
        self.navigationItem.titleView = titleView;

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
    }

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    _headView = [[UIView alloc] init];
    _headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headView];
    [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(50);
    }];

    _headLable = [[UILabel alloc] init];
    [self.headView addSubview:_headLable];
    [_headLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headView).with.offset(edgeDistancePage);
        make.right.top.bottom.equalTo(_headView);
    }];
    _headLable.font = TEXT_HEAD_FONT;
    _headLable.textColor = TEXT_HEAD_COLOR;
    
    UIView *lineView = [[UIView alloc] init];
    [_headView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_headView);
        make.height.mas_equalTo(1);
    }];
    lineView.backgroundColor = LINE_COLOR;
    
    _headView.hidden = YES;

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if ([CommonData deviceIsIpad]) {
        scalePage = SCREENWIDTH/375.0;
        edgeDistancePage = 30*scalePage;
        CNNavController *nav = (CNNavController *)self.navigationController;
        [nav rotate];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    if ([CommonData deviceIsIpad]) {
        scalePage = SCREENWIDTH/375.0;
        edgeDistancePage = 30*scalePage;
        [_headLable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headView).with.offset(edgeDistancePage);
            make.right.top.bottom.equalTo(_headView);
        }];
        
        [self rotate];
    }
}

- (void)backAction{
    if ([CommonData deviceIsIpad]) {
    
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setBackBtnHiden:(BOOL)isHiden{
    if ([CommonData deviceIsIpad]) {
        
    }else{
        CNNavController *nav = (CNNavController *)self.navigationController;
        [nav setBackBtnHiden:isHiden];
    }
}

-(void)setRightBtn:(UIButton *)btn{
    if ([CommonData deviceIsIpad]) {
        
    }else{
        if (btn) {
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, edgeDistancePage);
        }
        CNNavController *nav = (CNNavController *)self.navigationController;
        [nav setRightBtn:btn];
    }

}

-(void)setLeftBtn:(UIButton *)btn{
    if ([CommonData deviceIsIpad]) {
        
    }else{
        if (btn) {
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            btn.contentEdgeInsets = UIEdgeInsetsMake(0, edgeDistancePage, 0, 0);
        }
        CNNavController *nav = (CNNavController *)self.navigationController;
        [nav setLeftBtn:btn];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
