//
//  HomeViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "HomeViewController.h"
#import "ScanAlertView.h"
#import "CNBlueManager.h"
#import "CNLockCell.h"
#import "CNDataBase.h"
#import "SVProgressHUD.h"
#import "CNBlueCommunication.h"
#import "EnterPwdAlert.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,LockCellActionDelegate>{
    
    NSDate *beginDate;
    CNBlueManager *blueManager;
    NSTimer *reportTimer;
}

@property (nonatomic,strong) NSMutableArray *dataArray;
//在列表中已显示的锁具id
@property (nonatomic,strong) NSMutableArray *lockIDArray;
@property (nonatomic,strong) ScanAlertView *alert;
@property (nonatomic,strong) NSTimer *myTimer;

@end

@implementation HomeViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (blueManager.unConnectedLockIDArray.count) {
        [blueManager connectAllPairedLock];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataArray = [NSMutableArray array];
    _lockIDArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList:) name:NotificationReload object:nil];
    
    //读取已连过的设备
    [CommonData sharedCommonData].listPeriArr = _dataArray;
    NSArray *periArr = [[CNDataBase sharedDataBase] searchAllPariedPeris];
    for (CNPeripheralModel *model in periArr) {
        [_lockIDArray addObject:model.periID];
        [_dataArray addObject:model];
    }

    blueManager = [CNBlueManager sharedBlueManager];
    self.headView.hidden = NO;
    self.headImageV.image = [UIImage imageNamed:@"PAIRED-LOCKS"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn addTarget:self action:@selector(scanPeri) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBtn:rightBtn];
    [rightBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];

    [_myTableView registerNib:[UINib nibWithNibName:@"CNLockCell" bundle:nil] forCellReuseIdentifier:@"CNLockCell"];
    _myTableView.tableFooterView = [[UIView alloc] init];
    
    __weak typeof(self) weakSelf = self;

    //搜索外设框
    _alert = [[NSBundle mainBundle] loadNibNamed:@"ScanAlertView" owner:self options:nil][0];
    _alert.hidden = YES;
    _alert.alertBlock = ^{
        if ([weakSelf.myTimer isValid]) {
            [weakSelf.myTimer invalidate];
        }
        weakSelf.myTimer = nil;
        [[CNBlueManager sharedBlueManager] cus_stopScan];
    };
    _alert.returnPasswordStringBlock = ^(NSString *pwd, CBPeripheral *peri) {
        /*三种情况进入此回调
         1、新配对
         2、被管理员踢了，需重新输入密码
         3、之前数据库密码失效
         */
        //情况2、3两种情况舍弃本读数据库密码
        CNPeripheralModel *periModel = [[CNDataBase sharedDataBase] searchPeripheralInfo:peri.identifier.UUIDString];
        if (periModel) {
            periModel.periPwd = pwd;
            [[CNDataBase sharedDataBase] updatePeripheralInfo:periModel];
        }
        
        //delete
        NSIndexSet *indexSet = [[CommonData sharedCommonData].deviceInfoArr indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CBPeripheral *lock = [obj objectForKey:@"device"];
            return [lock.identifier.UUIDString isEqualToString:peri.identifier.UUIDString];
        }];
        [[CommonData sharedCommonData].deviceInfoArr removeObjectsAtIndexes:indexSet];
        //insert
        NSDictionary *dic = @{@"device":peri,@"pwd":pwd};
        [[CommonData sharedCommonData].deviceInfoArr addObject:dic];
        
        //新匹配 或者 被踢后重新连接设备
        [[CNBlueManager sharedBlueManager] cus_connectPeripheral:peri];
    };
    _alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:_alert];

    //外设连接状态发生变化
    blueManager.periConnectedState = ^(CBPeripheral *peripheral, BOOL isConnect, BOOL isOpenTimer, BOOL isNeedReRnterPwd) {
        if (isNeedReRnterPwd) {
            //密码失效重新输入密码
            [weakSelf.alert setShowType:AlertEnterPwd WithPeripheral:peripheral];
        }else if (isOpenTimer) {
            //循环自动同步
            [weakSelf addTimer];
        }else{
            if (isConnect) {
                //更新列表
                CNPeripheralModel *model =  [[CNDataBase sharedDataBase] searchPeripheralInfo:peripheral.identifier.UUIDString];
                model.isConnect = isConnect;
                model.peripheral = peripheral;
                if (![weakSelf.lockIDArray containsObject:peripheral.identifier.UUIDString]) {
                    [weakSelf.dataArray addObject:model];
                    [weakSelf.lockIDArray addObject:peripheral.identifier.UUIDString];
                }else{
                    //dataArray初始化比较早，这里重新更新数据
                    int i = 0;
                    for (CNPeripheralModel *oldModel in weakSelf.dataArray) {
                        if ([oldModel.periID isEqualToString:model.periID]) {
                            [weakSelf.dataArray replaceObjectAtIndex:i withObject:model];
                            break;
                        }
                        i++;
                    }
                }
                [weakSelf.myTableView reloadData];
            }
            for (CNPeripheralModel *model in weakSelf.dataArray) {
                if ([model.periID isEqualToString:peripheral.identifier.UUIDString]) {
                    model.isConnect = isConnect;
                    model.periname = [peripheral.name stringByReplacingOccurrencesOfString:@" " withString:@""];
                    //未连接设备重新连接上
                    if(model.peripheral == nil){
                        model.peripheral = peripheral;
                    }
                    break;
                }
            }
            [weakSelf.myTableView reloadData];
        }
    };
    
    [CNBlueCommunication monitorLockState:^(RespondModel *model) {
        [self updateLockState:model.lockIdentifier state:model.lockState];
    }];
}

- (void)reloadList:(NSNotification *)notification{
    CNPeripheralModel *pModel = [notification object];
    int i = 0;
    for (CNPeripheralModel *model in _dataArray) {
        if ([pModel.periID isEqualToString:model.periID]) {
            pModel.peripheral = model.peripheral;
            break;
        }
        i++;
    }
    if (pModel.actionType == ENUpdate) {
        //[_dataArray replaceObjectAtIndex:i withObject:pModel];
    }else{
        [_dataArray removeObjectAtIndex:i];
        [self.lockIDArray removeObject:pModel.periID];
        [blueManager cus_cancelConnectPeripheral:pModel.peripheral];
    }
    [_myTableView reloadData];
}

#pragma mark Private 锁具状态更新

- (void)updateLockState:(NSString *)lockIdentifier state:(NSString *)state{
    int i = 0;
    for (CNPeripheralModel *periModel in _dataArray) {
        if ([periModel.periID isEqualToString:lockIdentifier]) {
            periModel.lockState = state;
            break;
        }
        i++;
    }
    [_myTableView reloadData];
}

#pragma mark Private 定时器

- (void)addTimer
{
    if (@available(iOS 10.0, *)) {
        reportTimer = [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self reportToLock];
        }];
    } else {
        reportTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(reportToLock) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:reportTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)removeTimer
{
    [reportTimer invalidate];
    reportTimer = nil;
}
#pragma mark Private API
//自动同步，自动循环上报，直到收到锁具回复，时间待定
- (void)reportToLock{
    if ([CommonData sharedCommonData].reportIDArr.count) {
        NSLog(@"==已连接但未自动登录成功=== %@",[CommonData sharedCommonData].reportIDArr);
    }
    for (NSString *idStr in [CommonData sharedCommonData].reportIDArr) {
        for (CBPeripheral *peri in blueManager.connectedPeripheralArray) {
            if ([peri.identifier.UUIDString isEqualToString:idStr]) {
                [CNBlueCommunication cbSendInstruction:ENAutoLogin toPeripheral:peri otherParameter:nil finish:nil];
            }
        }
    }
}

- (NSInteger)getIndexOfPeripheral:(CBPeripheral *)peripheral{
    int i = 0;
    for (CNPeripheralModel *model in _dataArray) {
        if ([model.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            break;
        }
        i++;
    }
    return i;
}

//开始/停止扫描
- (void)scanPeri{
    if (@available(iOS 10.0, *)) {
        if (blueManager.mgr.state != CBManagerStatePoweredOn) {
//            [CNPromptView showStatusWithString:@"请打开蓝牙"];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Turn On Bluetooth to Allow \"QuickSafes\" to Connect to Accessories" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:@"APP-Prefs:root=Bluetooth"];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //UITextField *userName = alertController.textFields.firstObject;
            }];
            [alertController addAction:setAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
    } else {
        // Fallback on earlier versions
    }
    
    
//    dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 6.0 * NSEC_PER_SEC);
//    NSLog(@"=======%@",dateString);
//    dispatch_after(timer, dispatch_get_main_queue(), ^(void){
//        [self stopScanPeri];
//    });
    
//    if (@available(iOS 10.0, *)) {
//        [NSTimer scheduledTimerWithTimeInterval:6 repeats:NO block:^(NSTimer * _Nonnull timer) {
//            [self stopScanPeri];
//        }];
//    } else {
//
//        NSTimer *timer = [NSTimer timerWithTimeInterval:6 target:self selector:@selector(stopScanPeri) userInfo:nil repeats:NO];
//        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//    }
    
    //6秒内未搜到外设，停止搜索
    _myTimer = [NSTimer timerWithTimeInterval:6 target:self selector:@selector(stopScanPeri) userInfo:nil repeats:NO];
    /*
     UIScrollView 拖动时也不影响的话，有两种解决方法
     1、[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
     [[NSRunLoop mainRunLoop] addTimer:timer forMode: UITrackingRunLoopMode];
     2、[[NSRunLoop mainRunLoop] addTimer:timer forMode: NSRunLoopCommonModes];
     */
    [[NSRunLoop mainRunLoop] addTimer:_myTimer forMode:NSDefaultRunLoopMode];
    beginDate = [NSDate date];
    [_alert beginScan];
    //开始搜索外设
    [blueManager cus_beginScanPeriPheralFinish:^(CBPeripheral *per) {
        if (per) {
            CNPeripheralModel *model = [[CNPeripheralModel alloc] init];
            model.periname = [per.name stringByReplacingOccurrencesOfString:@" " withString:@""];
            model.periID = per.identifier.UUIDString;
            model.peripheral = per;
            [_alert updateDeviceInfo:model];
        }
    }];
}

- (void)stopScanPeri{
    NSDate *curDate = [NSDate date];
    NSTimeInterval secondsBetweenDates = [curDate timeIntervalSinceDate:beginDate];
    if (secondsBetweenDates>6) {
        //搜索出蓝牙设备，到6秒后不终止，知道点击扫描列表下面的取消
        if (_alert.showType == AlertSearch) {
            [_alert stopScanAnimation];
            [blueManager cus_stopScan];
        }
    }
}
#pragma mark tableviewDelegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 136;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CNLockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CNLockCell" forIndexPath:indexPath];
    cell.delegate = self;
    CNPeripheralModel *model = (CNPeripheralModel *)_dataArray[indexPath.row];
    cell.model = model;
    if ([model.periname isEqualToString:@"Quick Safe"]) {
        cell.lockNameLab.text = [NSString stringWithFormat:@"Quick Safe %ld",indexPath.row+1];
    }else{
        if (model.periname) {
            cell.lockNameLab.text = model.periname;
        }else{
            cell.lockNameLab.text = @"Unknown Device";
        }
    }
    return cell;
}

#pragma mark LockCellActionDelegate
- (void)slideSuccess:(CBPeripheral *)peri{
    if(peri.state != CBPeripheralStateConnected){
        //lyh 若已断开，重新连接。 这里要怎么提示吗？
        [blueManager cus_connectPeripheral:peri];
    }else{
        CNPeripheralModel *model = [[CNDataBase sharedDataBase] searchPeripheralInfo:peri.identifier.UUIDString];
        if (model.openMethod == OpenLockSlide) {
            [CNBlueCommunication cbSendInstruction:ENOpenLock toPeripheral:peri otherParameter:nil finish:nil];
        }else if (model.openMethod == OpenLockPwd) {
            //弹出输入密码框
            EnterPwdAlert *enterAlert = [[NSBundle mainBundle] loadNibNamed:@"EnterPwdAlert" owner:self options:nil][0];
            enterAlert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
            enterAlert.returnPasswordStringBlock = ^(NSString *pwd) {
                if ([pwd isEqualToString:model.periPwd]) {
                    [CNBlueCommunication cbSendInstruction:ENOpenLock toPeripheral:peri otherParameter:nil finish:nil];
                }else{
                    //密码输错提示
                    [CNPromptView showStatusWithString:@"Incorrect Password"];
                }
            };
            [enterAlert showWithName:model.periname];
        }else{
            //触摸开锁
            [self thumbPrint:peri];
        }
    }
}

- (void)thumbPrint:(CBPeripheral *)peri{
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    //这个设置的使用密码的字体，当text=@""时，按钮将被隐藏
    context.localizedFallbackTitle=@"";
    //这个设置的取消按钮的字体
    if (@available(iOS 10.0, *)) {
        //context.localizedCancelTitle=@"取消";
    } else {
        // Fallback on earlier versions
    }
    //错误对象
    NSError* error = nil;
    NSString* result = @"需要验证您的touch ID";
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) {
                //验证成功，主线程处理UI
                //NSLog(@"验证成功");
                [CNBlueCommunication cbSendInstruction:ENOpenLock toPeripheral:peri otherParameter:nil finish:nil];
            }
            else
            {
                //NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        //NSLog(@"Authentication was cancelled by the system");
                        //切换到其他APP，系统取消验证Touch ID
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        //NSLog(@"Authentication was cancelled by the user");
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        //NSLog(@"User selected to enter custom password");
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择其他验证方式，切换主线程处理
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
            }
        }];
    }
    else
    {
        //不支持指纹识别，LOG出错误详情
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                [CNPromptView showStatusWithString:@"TouchID is not enrolled"];
                //NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                [CNPromptView showStatusWithString:@"A passcode has not been set"];
                //NSLog(@"A passcode has not been set");
                break;
            }
            default:
            {
                [CNPromptView showStatusWithString:@"TouchID not available"];
                //NSLog(@"TouchID not available");
                break;
            }
        }
        //NSLog(@"%@",error.localizedDescription);
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
