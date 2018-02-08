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
#import "LockCell.h"
#import "CNLockCell.h"
#import "CNDataBase.h"
#import "SVProgressHUD.h"
#import "CNBlueCommunication.h"

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,LockCellActionDelegate>{
    ScanAlertView *alert;
    NSDate *beginDate;
}

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSTimer *myTimer;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataArray = [NSMutableArray array];
    
    self.headView.hidden = NO;
    self.headImageV.image = [UIImage imageNamed:@"PAIRED-LOCKS"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn addTarget:self action:@selector(scanPeri) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBtn:rightBtn];
    [rightBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];

    [_myTableView registerNib:[UINib nibWithNibName:@"LockCell" bundle:nil] forCellReuseIdentifier:@"LockCell"];
    [_myTableView registerNib:[UINib nibWithNibName:@"CNLockCell" bundle:nil] forCellReuseIdentifier:@"CNLockCell"];
    _myTableView.tableFooterView = [[UIView alloc] init];
    
    CNBlueManager *blueManager = [CNBlueManager sharedBlueManager];
    //外设连接状态发生变化
    blueManager.periConnectedState = ^(CBPeripheral *peripherial, BOOL isConnect) {
        if (self.dataArray.count) {
            NSInteger index = [self getIndexOfPeripheral:peripherial];
            CNPeripheralModel *model = self.dataArray[index];
            model.peripheral = peripherial;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    
    //搜索外设框
    alert = [[NSBundle mainBundle] loadNibNamed:@"ScanAlertView" owner:self options:nil][0];
    alert.hidden = YES;
    __weak typeof(self) weakSelf = self;
    alert.alertBlock = ^{
        if ([weakSelf.myTimer isValid]) {
            [weakSelf.myTimer invalidate];
        }
        weakSelf.myTimer = nil;
        [[CNBlueManager sharedBlueManager] cus_stopScan];
    };
    alert.returnPasswordStringBlock = ^(NSString *pwd) {
        //发现新设备，输入密码
        //[CNBlueCommunication cbSendInstruction:(InstructionEnum) toPeripheral:<#(CBPeripheral *)#>]
        if ([CNBlueCommunication cbIsPaire:pwd]) {
            [CNPromptView showStatusWithString:@"Lock Paired"];
        }else{
            [blueManager.peripheralArray removeObject:blueManager.currentperi];
            [CNPromptView showStatusWithString:@"Lock Unpaired"];
        }
    };
    alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
}
#pragma mark Private API
- (NSInteger)getIndexOfPeripheral:(CBPeripheral *)peripheral{
    int i = 0;
    for (CNPeripheralModel *model in _dataArray) {
        if ([model.peripheral.identifier isEqual:peripheral.identifier]) {
            break;
        }
        i++;
    }
    return i;
}

//开始/停止扫描
- (void)scanPeri{
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
    [alert beginScan];
    //开始搜索外设
    __weak typeof(self) weakself = self;
    [[CNBlueManager sharedBlueManager] cus_beginScanPeriPheralFinish:^(CBPeripheral *per) {
        if (per) {
            [self findPeri];
            [alert setShowType:AlertEnterPwd];
            CNPeripheralModel *model = [[CNPeripheralModel alloc] init];
            model.peripheral = per;
            [weakself.dataArray addObject:model];
            [weakself.myTableView reloadData];
        }
    }];
}

- (void)findPeri{
    NSLog(@"%@",[CNBlueManager sharedBlueManager].peripheralArray);
    [alert setShowType:AlertEnterPwd];

}

- (void)stopScanPeri{
    NSDate *curDate = [NSDate date];
    NSTimeInterval secondsBetweenDates = [curDate timeIntervalSinceDate:beginDate];
    if (secondsBetweenDates>6) {
        [alert stopScan];
        [[CNBlueManager sharedBlueManager] cus_stopScan];
    }
}

#pragma mark tableviewDelegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    return 108;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CNLockCell *curCell = [tableView dequeueReusableCellWithIdentifier:@"CNLockCell" forIndexPath:indexPath];
    if (indexPath.row%3 == 0) {
        curCell.pwdLab.hidden = YES;
        curCell.fingerprintImagev.hidden = YES;
    }else if (indexPath.row%3 == 1) {
        curCell.pwdLab.hidden = NO;
        curCell.fingerprintImagev.hidden = YES;
    }else{
        curCell.pwdLab.hidden = YES;
        curCell.fingerprintImagev.hidden = NO;
    }
    //curCell.model = nil;
    return curCell;
    LockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LockCell" forIndexPath:indexPath];
    CNPeripheralModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    cell.delegate = self;
    //lyh debug
    cell.slider.value = 0;
    cell.actionBlock = ^(BOOL isConnect) {
        if (isConnect) {
            [[CNBlueManager sharedBlueManager] cus_connectPeripheral:model.peripheral];
        }else{
            [[CNBlueManager sharedBlueManager] cus_cancelConnectPeripheral:model.peripheral];
        }
    };
    return cell;
}

#pragma mark LockCellActionDelegate
- (void)slideSuccess:(CBPeripheral *)peri{
    CNPeripheralModel *model = [[CNDataBase sharedDataBase] lookupPeripheralInfo:peri.identifier.UUIDString];
    if (model.isPwd) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"密码";
            textField.secureTextEntry = YES;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Cancel Action");
        }];
        UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //UITextField *userName = alertController.textFields.firstObject;
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:loginAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }else{
        [SVProgressHUD showSuccessWithStatus:@"已发送开锁指令"];
        [CNBlueCommunication cbSendInstruction:ENLock toPeripheral:peri];
        //[[CNBlueManager sharedBlueManager] senddata:@"01" toPeripheral:peri];
        
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
