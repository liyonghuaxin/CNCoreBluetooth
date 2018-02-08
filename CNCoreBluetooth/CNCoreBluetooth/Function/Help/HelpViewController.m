//
//  HelpViewController.m
//  CNCoreBluetooth
//
//  Created by apple on 2018/1/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpCell.h"
#import "HelpConCell.h"
#import "NSString+Utils.h"

@implementation SetModel

@end

@interface HelpViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *dataArray;
}

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initDataArray];
    self.headView.hidden = NO;
    self.headImageV.image = [UIImage imageNamed:@"HELP"];
    
    _myTableView.tableFooterView = [[UIView alloc] init];
    [_myTableView registerNib:[UINib nibWithNibName:@"HelpCell" bundle:nil] forCellReuseIdentifier:@"HelpCell"];
    [_myTableView registerNib:[UINib nibWithNibName:@"HelpConCell" bundle:nil] forCellReuseIdentifier:@"HelpConCell"];

    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    return dataArray.count*2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row%2 == 0) {
        SetModel *setModel = (SetModel *)dataArray[indexPath.row/2];
        
        HelpCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.isLook = !setModel.isSelect;
        
        setModel.isSelect = !setModel.isSelect;
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        [tableView reloadRowsAtIndexPaths:@[indexP] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SetModel *setModel = (SetModel *)dataArray[indexPath.row/2];
    if (indexPath.row%2 == 0) {
        return 50;
    }else{
        if (!setModel.isSelect) {
            return 0;
        }else{
            CGRect rect = [setModel.content stringHeightWithConstraintWidth:SCREENWIDTH- scalePage*60 fontsize:15];
            return rect.size.height+20+6;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SetModel *model = dataArray[indexPath.row/2];
    if (indexPath.row%2 == 0) {
        HelpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HelpCell" forIndexPath:indexPath];
        cell.questionLab.text = model.title;
        return cell;
    }else{
        HelpConCell *conCell = [tableView dequeueReusableCellWithIdentifier:@"HelpConCell" forIndexPath:indexPath];
        if (model.isSelect == YES) {
            conCell.contentView.hidden = NO;
        }else{
            conCell.contentView.hidden = YES;
        }
        conCell.contentLab.text = model.content;
        return conCell;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDataArray{
    
    dataArray = [NSMutableArray array];
    
    SetModel *model1 = [[SetModel alloc] init];
    model1.isSelect = NO;
    model1.title = @"Nam pellentesque neque at laoreet?";
    model1.content = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu.";

    SetModel *model2 = [[SetModel alloc] init];
    model2.isSelect = NO;
    model2.title = @"Nam pellentesque neque at laoreet?";
    model2.content = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";

    
    SetModel *model3 = [[SetModel alloc] init];
    model3.isSelect = NO;
    model3.title = @"Nam pellentesque neque at laoreet?";
    model3.content = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
    
    SetModel *model4 = [[SetModel alloc] init];
    model4.isSelect = NO;
    model4.title = @"Nam pellentesque neque at laoreet?";
    model4.content = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit";
    
    SetModel *model5 = [[SetModel alloc] init];
    model5.isSelect = NO;
    model5.title = @"Nam pellentesque neque at laoreet?";
    model5.content = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu";
    
    SetModel *model6 = [[SetModel alloc] init];
    model6.isSelect = NO;
    model6.title = @"Nam pellentesque neque at laoreet?";
    model6.content = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.";
    
    [dataArray addObjectsFromArray:@[model1, model2, model3, model4, model5, model6]];
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
