//
//  BaseViewController.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.tableView];
        self.tableView.bounds = self.view.bounds;
    }
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self _registerNibClass];
}

//  注册默认的 ClearTableViewCell
- (void)_registerNibClass
{
    NSString *className = @"ClearTableViewCell";
    [self.tableView registerClass:NSClassFromString(className) forCellReuseIdentifier:className];
}

- (void)setCellArray:(NSArray<NSArray<CellDataModel *> *> *)cellArray
{
    _cellArray = cellArray;
    [self.tableView reloadData];
}

- (void)setCellArray:(NSArray<NSArray<CellDataModel *> *> *)cellArray reload:(BOOL)reload
{
    _cellArray = cellArray;
    if (reload)
        [self.tableView reloadData];
}

#pragma UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cellArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellDataModel *data = self.cellArray[indexPath.section][indexPath.row];
    
    return [self heightForCellDataModel:data];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellDataModel *data = self.cellArray[indexPath.section][indexPath.row];
    
    BaseTableViewCell *cell = data.tableViewCell != nil ? data.tableViewCell : [tableView dequeueReusableCellWithIdentifier:data.cellClassName forIndexPath:indexPath];
    cell.tempBottomLineLeft = data.bottomLineLeft;
    cell.tempBottomLineRight = data.bottomLineRight;
    if (data.isAlphaSelect)
        cell.isAlphaSelect = [data.isAlphaSelect boolValue];
    [cell setDataModel:data.data viewController:self tableView:tableView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    BaseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[BaseTableViewCell class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell didSelectCell];
        });
    }
}

- (CGFloat)heightForCellDataModel:(CellDataModel *)data
{
    if (data.height) {
        return data.height.floatValue;
    }
    
    Class cellClass = NSClassFromString(data.cellClassName);
    if (!cellClass && data.tableViewCell)
        cellClass = [data.tableViewCell class];
    if ([cellClass isSubclassOfClass:[BaseTableViewCell class]]) {
        return [cellClass heightWithData:data.data width:CGRectGetWidth(self.view.bounds)];
    }
    
    // EDLog(@"DetailViewController cellClass:%@错误",data.cellClassName);
    return 0;
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

#pragma mark - ClearTableViewCell

@interface ClearTableViewCell : BaseTableViewCell

@end
@implementation ClearTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setDataModel:(id )data viewController:(UIViewController *)viewController tableView:(UITableView *)tableView
{
    [self setupUI];
}

@end


