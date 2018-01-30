//
//  HomeViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "HomeViewController.h"
#import "CNAlertView.h"

#import "CNBlueManager.h"
#import "LockCell.h"

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>{
    CNAlertView *alert;
}

@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _dataArray = [NSMutableArray array];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开始扫描" style:UIBarButtonItemStylePlain target:self action:@selector(scanPeri:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"scanPeripheral"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(scanPeri)];
    [_myTableView registerNib:[UINib nibWithNibName:@"LockCell" bundle:nil] forCellReuseIdentifier:@"LockCell"];
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
//    alert = [[NSBundle mainBundle] loadNibNamed:@"CNAlertView" owner:self options:nil][0];
//    alert.hidden = YES;
//    __weak typeof(self) weakSelf = self;
//    alert.alertBlock = ^{
//        [weakSelf stopScanPeri];
//    };
//    alert.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
//    [[UIApplication sharedApplication].keyWindow addSubview:alert];
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
- (void)scanPeri{
    
}
//开始/停止扫描
- (void)scanPeri:(id)sender{
    //alert.hidden = NO;
    //[alert startAnimation];
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    if ([item.title  isEqualToString:@"开始扫描"]) {
        __weak typeof(self) weakself = self;
        [[CNBlueManager sharedBlueManager] cus_beginScanPeriPheralFinish:^(CBPeripheral *per) {
            if (per) {
                CNPeripheralModel *model = [[CNPeripheralModel alloc] init];
                model.peripheral = per;
                [weakself.dataArray addObject:model];
                [weakself.myTableView reloadData];
            }
        }];
        [item setTitle:@"停止扫描"];
    }else{
        [item setTitle:@"开始扫描"];
        [self stopScanPeri];
    }
}

- (void)stopScanPeri{
    //[alert stopAnimation];
    [[CNBlueManager sharedBlueManager] cus_stopScan];
}

#pragma mark tableviewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 127;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LockCell" forIndexPath:indexPath];
    CNPeripheralModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
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
