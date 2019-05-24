//
//  BaseViewController.h
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "CellDataModel.h"

NS_ASSUME_NONNULL_BEGIN

// 详情类的页面使用，布局由cellArray决定，CellData中的cellClassName为cellName和Identifier
@interface BaseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<NSArray<CellDataModel *> *> *cellArray;
@property (strong, nonatomic) UITableView *tableView;

- (void)setCellArray:(NSArray<NSArray<CellDataModel *> *> *)cellArray reload:(BOOL)reload;

// - (CellDataModel *)webViewCellModelForHtml:(NSString *)html;//添加webview cell model
- (CGFloat)heightForCellDataModel:(CellDataModel *)data;

@end


NS_ASSUME_NONNULL_END
