//
//  SetViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "SetViewController.h"
#import "SetLockCell.h"
#import "CNBlueManager.h"
#import "SetDetailVC.h"
#import "PresentTransformAnimation.h"
#import "SwipeUpInteractiveTransition.h"
#import "CNDataBase.h"
#import "SVProgressHUD.h"
#import "SetDetailViewController.h"
#import "UIView+KGViewExtend.h"
#import "ChangePwdAlert.h"

@interface SetViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerTransitioningDelegate>{
    
    ChangePwdAlert *alert;
    NSMutableArray *_dataArray;
    
    PresentTransformAnimation *_presentAnimation;
    SwipeUpInteractiveTransition *_transitionController;
}

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.headView.hidden = NO;
    self.headImageV.image = [UIImage imageNamed:@"LOCK-SETTINGS"];
    [_myTableView registerNib:[UINib nibWithNibName:@"SetLockCell" bundle:nil] forCellReuseIdentifier:@"SetLockCell"];
    _myTableView.tableFooterView = [[UIView alloc] init];
    //保证_dataArray的实时性
    _dataArray = [CNBlueManager sharedBlueManager].connectedPeripheralArray;
    //_dataArray = [NSMutableArray arrayWithArray:[CNBlueManager sharedBlueManager].connectedPeripheralArray];
    _presentAnimation = [PresentTransformAnimation new];
    _transitionController = [SwipeUpInteractiveTransition new];
    

    _changAdminPwdBtn.titleLabel.font = [UIFont systemFontOfSize:19+FontSizeAdjust];
    _changAdminPwdBtn.layer.cornerRadius = _setLanguageBtn.height/2.0;
    _setLanguageBtn.titleLabel.font = [UIFont systemFontOfSize:19+FontSizeAdjust];
    _setLanguageBtn.layer.cornerRadius = _setLanguageBtn.height/2.0;
    //lyh debug 50*3
    float footViewheight = SCREENHEIGHT - 64-iPhoneXTopPara-49-iPhoneXBottomPara-50-50*3;
    if (footViewheight<150) {
        footViewheight = 150;
    }
    _footView.frame = CGRectMake(0, 0, SCREENWIDTH, footViewheight);
    _myTableView.tableFooterView = _footView;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setBackBtnHiden:YES];
    //lyh debug
    //[_myTableView reloadData];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //lyh debug
    return 3;
    return _dataArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SetDetailViewController *detail = [[SetDetailViewController alloc] init];
    [self.navigationController pushViewController:detail animated:YES];
    return;
    if (_dataArray.count) {
        CBPeripheral *peri = (CBPeripheral *)_dataArray[indexPath.row];
        if (peri.state != CBPeripheralStateConnected) {
            [SVProgressHUD showErrorWithStatus:@"已断开连接"];
            return;
        }
        SetDetailVC *setDetail = [[SetDetailVC alloc] init];
        setDetail.periID = peri.identifier.UUIDString;
        setDetail.tabbarBlock = ^{
            self.tabBarController.tabBar.hidden = NO;
        };
        self.tabBarController.tabBar.hidden = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:setDetail];
        setDetail.navigationController.navigationBar.hidden = YES;
        nav.transitioningDelegate = self;
        nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [_transitionController wireToViewController:nav];
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        [SVProgressHUD showErrorWithStatus:@"已断开连接"];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SetLockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SetLockCell" forIndexPath:indexPath];
    //CBPeripheral *peri = (CBPeripheral *)_dataArray[indexPath.row];
    //cell.nameLab.text =peri.name;
    return cell;
}

#pragma mark  UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return _presentAnimation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [PresentTransformAnimation makeWithTransitionType:PresentTransformAnimationTypeDismissed isHorizontal:NO];
}
-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return _transitionController.interacting ? _transitionController : nil;
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

- (IBAction)setlanguage:(id)sender {
}
- (IBAction)changeAdminPed:(id)sender {
    //更改管理员密码
    alert = [[NSBundle mainBundle] loadNibNamed:@"ChangePwdAlert" owner:self options:nil][0];
    alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
}
@end
