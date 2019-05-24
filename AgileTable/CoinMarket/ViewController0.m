//
//  ViewController0.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "ViewController0.h"
#import "CoinCell.h"

#import "YYFPSLabel.h"

@interface ViewController0 ()

@property(nonatomic, strong) CurrencyDataList* listData;
@property (nonatomic, strong) YYFPSLabel *fpsLabel;

@end

@implementation ViewController0

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // [self.tableView registerNibClass:@"CoinCell"];
    [self.tableView registerNib:[UINib nibWithNibName: @"CoinCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier: @"CoinCell"];
    [self.tableView registerNib:[UINib nibWithNibName: @"TitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier: @"TitleCell"];
    [self requestData];
    
    self.title = @"市值（BaseVC）";
    [self testFPSLabel];
}

- (void) requestData{
    [CurrencyDataList getDatasSuccess:^(CurrencyDataList * _Nonnull data) {
        self.listData = data;
        [self updateUI];
    } failure:^(int code, NSString * _Nonnull error) {
        
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
    
//    CellDataModel *titleCellData = [[CellDataModel alloc] initWithCellClassName: @"TitleCell" data: @"市值" bottomLineLeft: @(0) bottomLineRight: @(0) height: @(44)];
//    [cellArray addObject: @[titleCellData]];
    
    NSMutableArray<CellDataModel *> *section1 = [NSMutableArray array];
    [cellArray addObject:section1];
//    int count =7;
//    for (int i=0; i<count; ++i) {
//        CellDataModel *coinCelldata = [[CellDataModel alloc] initWithCellClassName:@"CoinCell" data: @[@"热门板块", @"根据3日涨幅统计"]];
//        if (i==count-1){
//            coinCelldata.bottomLineLeft = @-1;
//        }
//        [section1 addObject:coinCelldata];
//    }
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


@end
