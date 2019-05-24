//
//  ViewController0.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//
#import "UITableView+Refresh.h"
#import "ViewController0.h"
#import "CoinCell.h"

#import "YYFPSLabel.h"

@interface ViewController0 ()

@property(nonatomic, strong) CurrencyDataList* listData;
@property (nonatomic, strong) YYFPSLabel *fpsLabel;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController0

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // [self.tableView registerNibClass:@"CoinCell"];
    [self.tableView registerNib:[UINib nibWithNibName: @"CoinCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier: @"CoinCell"];
    [self.tableView registerNib:[UINib nibWithNibName: @"TitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier: @"TitleCell"];
    
    
    self.title = @"市值（BaseVC）";
    
    if (fpsEnabled)
        [self testFPSLabel];
    
    @weakify(self);
    [self.tableView addRefreshTriggerBlock:^{
        @strongify(self);
        [self requestData];
    }];
    [self.tableView trigerRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self timerRequest];
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 5 target:self selector:@selector(timerRequest) userInfo:nil repeats:true];
    [self.timer fire];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void) requestData{
    [CurrencyDataList getDatasSuccess:^(CurrencyDataList * _Nonnull data) {
        self.listData = data;
        [self updateUI];
        
        [self.tableView endRefresh];
    } failure:^(int code, NSString * _Nonnull error) {
        
        [self.tableView endRefresh];
    }];
}

- (void)updateUI
{
    NSArray *cellArray = [self getCellArray];
    if (!cellArray) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cellArray = cellArray;
        [self.tableView reloadData];
    });
}

- (NSArray *)getCellArray
{
    NSMutableArray *cellArray = [NSMutableArray array];
    
    NSMutableArray<CellDataModel *> *section1 = [NSMutableArray array];
    [cellArray addObject:section1];
    [self.listData.list enumerateObjectsUsingBlock:^(CurrencyData *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CellDataModel *coinCelldata = [[CellDataModel alloc] initWithCellClassName:@"CoinCell" data: obj];
        coinCelldata.bottomLineRight = 0;
        [section1 addObject:coinCelldata];
    }];
    
    // [cellArray addObject:@[[CellDataModel clearCellHeight:8]]];
    CellDataModel *titleCellData = [[CellDataModel alloc] initWithCellClassName: @"TitleCell" data: @"到底了哦！" bottomLineLeft: @(0) bottomLineRight: @(0) height: @(44)];
    [cellArray addObject: @[titleCellData]];
    
    return cellArray;
}

#pragma mark - FPS demo

- (void)testFPSLabel {
    _fpsLabel = [YYFPSLabel new];
    _fpsLabel.frame = CGRectMake(200, 200, 50, 30);
    [_fpsLabel sizeToFit];
    [self.view addSubview:_fpsLabel];
    
    // 如果直接用 self 或者 weakSelf，都不能解决循环引用问题
    
    // 移除也不能使 label里的 timer invalidate
    //        [_fpsLabel removeFromSuperview];
}

#pragma mark - Timer

- (void)timerRequest
{
    [self timerRefresh];
}

- (void)timerRefresh
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) return;
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    [datas addObjectsFromArray: [self visibleCurrencys]];
    NSLog(@"timerRefreshtimerRefresh %ld", datas.count);
    if (datas.count > 0) {
        [CurrencyDataList refresh:(NSArray<CurrencyData *> *) datas success:^(NSArray * _Nonnull responseList) {
            [self.tableView reloadData];
        } failure:^(int code, NSString * _Nonnull error) {
            
        }];
    } else {
        // [self requestData:1 toast:true];
    }
}

- (NSArray *) visibleCurrencys{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (UITableViewCell *c in [self.tableView visibleCells]){
        if ([c isKindOfClass: [CoinCell class]]){
            CoinCell *cc = (CoinCell *)c;
            CurrencyData *currency = cc.currency;
            [arr addObject: currency];
        }
    }
    
    return [arr copy];
}

@end
