//
//  ViewController1.m
//  AgileTable
//
//  Created by mengyun on 2019/5/23.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "ViewController1.h"

#import "CoinCellNode.h"
#import "YYFPSLabel.h"

@interface ViewController1 ()<ASTableDataSource, ASTableDelegate>

@property(nonatomic, strong) CurrencyDataList* listData;
@property (nonatomic, strong) YYFPSLabel *fpsLabel;
@property(strong,nonatomic)ASTableNode* tableNode;

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableNode = [[ASTableNode alloc]initWithStyle:UITableViewStylePlain];
    // 2
    self.tableNode.dataSource = self;
    self.tableNode.delegate = self;
    // 3
    self.tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 4
    // self.tableNode.view.leadingScreensForBatching = 1.0;
    // 5
    [self.view addSubnode:self.tableNode];
    
    [self requestData];
    
    self.title = @"市值（Texture）";
    [self testFPSLabel];
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
    
    self.tableNode.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
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
    
    // 你自己的代码
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
