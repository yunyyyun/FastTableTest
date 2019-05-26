//
//  ViewController_Texture.m
//  AgileTable
//
//  Created by mengyun on 2019/5/23.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "ViewController_Texture.h"
#import "CoinCellNode.h"

#import "CoinDetailViewController.h"

@interface ViewController_Texture ()<ASTableDataSource, ASTableDelegate>

@property(nonatomic, strong) CurrencyDataList* listData;
@property(strong,nonatomic) ASTableNode* tableNode;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController_Texture

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableNode = [[ASTableNode alloc]initWithStyle:UITableViewStylePlain];
    self.tableNode.dataSource = self;
    self.tableNode.delegate = self;
    self.tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    // self.tableNode.view.leadingScreensForBatching = 1.0;
    [self.view addSubnode:self.tableNode];
    
    [self requestData];
    
    self.title = @"市值（Texture）";
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
    } failure:^(int code, NSString * _Nonnull error) {
        
    }];
}

- (void)updateUI
{
    [self.tableNode reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableNode.frame = self.view.bounds;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    // 1
    return self.listData.list.count;
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 2
    CurrencyData* data = _listData.list[indexPath.row];
    
    // 3
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode *() {
        CoinCellNode *cellNode = [[CoinCellNode alloc] initWithCurrencyData: data];
        // cellNode.b
        return cellNode;
    };
    
    return ASCellNodeBlock;
}
- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode{
    // 4
    return 1;
}

- (BOOL)shouldBatchFetchForTableNode:(ASTableNode *)tableNode {
    return YES;
}
//2
- (void)tableNode:(ASTableNode *)tableNode willBeginBatchFetchWithContext:(ASBatchContext *)context
{
    [context beginBatchFetching];
    // [self loadPageWithContext:context];
}
// 3
- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableNode deselectRowAtIndexPath:indexPath animated:YES];

    CoinDetailViewController *detailVC = [[CoinDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController: detailVC animated: true];
}

//- (void)loadPageWithContext:(ASBatchContext *)context
//{
//    NSString* radioId = [[AccountAdditionalModel currentAccount] radioId];
//    // 2
//    [self loadAlbums:radioId pageNum:pageNum+1 pageSize:pageSize].thenOn(dispatch_get_main_queue(),^(NSArray<AlbumModel>* array){
//
//        if(array!=nil){
//            // 3
//            pageNum = pageNum+1;
//            [_models addObjectsFromArray: array];
//            // 4
//            [self insertNewRowsInTableNode:array];
//        }
//        // 5
//        if (context) {
//            [context completeBatchFetching:YES];
//        }
//
//    }).catch(^(NSError* error){
//        [self showHint:error.localizedDescription];
//        // 6
//        if (context) {
//            [context completeBatchFetching:YES];
//        }
//    });
//
//}
//
//// 7
//- (void)insertNewRowsInTableNode:(NSArray<AlbumModel>*)array
//{
//    NSInteger section = 0;
//    NSMutableArray *indexPaths = [NSMutableArray array];
//
//    for (NSUInteger row = _models.count-array.count; row < _models.count; row++) {
//        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
//        [indexPaths addObject:path];
//    }
//    [_tableNode insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//}

-(void)dealloc{
    self.tableNode.delegate = nil;
    self.tableNode.dataSource = nil;
}

#pragma mark - Timer

- (void)timerRequest
{
    [self timerRefresh];
}

- (void)timerRefresh
{
    // [self.tableNode reloadData];
    [self requestData];
//    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) return;
//    NSMutableArray *datas = [[NSMutableArray alloc] init];
//    [datas addObjectsFromArray: [self visibleCurrencys]];
//    NSLog(@"timerRefreshtimerRefresh %ld", datas.count);
//    if (datas.count > 0) {
//        [CurrencyDataList refresh:(NSArray<CurrencyData *> *) datas success:^(NSArray * _Nonnull responseList) {
//            [self.tableNode reloadData];
//        } failure:^(int code, NSString * _Nonnull error) {
//
//        }];
//    } else {
//        // [self requestData:1 toast:true];
//    }
}

//- (NSArray *) visibleCurrencys{
//    NSMutableArray *arr = [[NSMutableArray alloc] init];
//
//    for (UITableViewCell *c in [self.tableView visibleCells]){
//        if ([c isKindOfClass: [CoinCell class]]){
//            CoinCell *cc = (CoinCell *)c;
//            CurrencyData *currency = cc.currency;
//            [arr addObject: currency];
//        }
//    }
//
//    return [arr copy];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
