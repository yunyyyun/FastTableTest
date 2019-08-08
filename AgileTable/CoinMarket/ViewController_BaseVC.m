//
//  ViewController_BaseVC.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//
#import "UITableView+Refresh.h"
#import "ViewController_BaseVC.h"
#import "CoinCell.h"

@interface ViewController_BaseVC ()

// @property(nonatomic, strong) CurrencyDataList* listData;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) int page;

@end

@implementation ViewController_BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // [self.tableView registerNibClass:@"CoinCell"];
    [self.tableView registerNib:[UINib nibWithNibName: @"CoinCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier: @"CoinCell"];
    [self.tableView registerNib:[UINib nibWithNibName: @"TitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier: @"TitleCell"];
    
    
    self.title = @"市值（BaseVC）";
    
//    if (fpsEnabled)
//        [self testFPSLabel];
    
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
//    [CurrencyDataList getDatasSuccess:^(CurrencyDataList * _Nonnull data) {
//        self.listData = data;
//        [self updateUI];
//
//        [self.tableView endRefresh];
//    } failure:^(int code, NSString * _Nonnull error) {
//
//        [self.tableView endRefresh];
//    }];
    
    NSString *sort = @"";
    @weakify(self);
    int page = self.page;
    self.task = [DMCurrency getCurrenciesWithPage: page Sort: sort sucess:^(NSArray *currencies) {
        @strongify(self);
        BOOL isMore = currencies.count>=commonPageSize;
        if (self.datas.count<1) self.datas = [NSMutableArray array];
        self.page = page;
        [self.datas addObjectsFromArray: currencies];
        
        [self updateUI];
        // self.tableView.isMore = currencies.count>=commonPageSize;
        [self.tableView endRefresh];
        // [self.tableView endLoadMore];
        
    } failure:^(int code, NSString *error) {
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
    [self.datas enumerateObjectsUsingBlock:^(CurrencyData *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.height intValue]<10)
            obj.height = @cellDefaultHeight;
        CellDataModel *coinCelldata = [[CellDataModel alloc] initWithCellClassName:@"CoinCell" data: obj];
        coinCelldata.bottomLineRight = @-1;
        coinCelldata.bottomLineLeft = @-1;
        [section1 addObject:coinCelldata];
    }];
    
    // [cellArray addObject:@[[CellDataModel clearCellHeight:8]]];
    CellDataModel *titleCellData = [[CellDataModel alloc] initWithCellClassName: @"TitleCell" data: @"到底了哦！" bottomLineLeft: @(0) bottomLineRight: @(0) height: @(44)];
    [cellArray addObject: @[titleCellData]];
    
    return cellArray;
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
