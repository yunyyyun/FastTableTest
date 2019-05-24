//
//  CellDataModel.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "CellDataModel.h"
#define defaultBottomLineLeft 14
#define defaultBottomLineRight 14

@implementation CellDataModel

// 默认下划线
- (instancetype)initWithCellClassName:(NSString *)cellClassName data:(id)data
{
    return [self initWithCellClassName: cellClassName
                                  data: data
                        bottomLineLeft: @(defaultBottomLineLeft)
                       bottomLineRight: @(defaultBottomLineRight)
                                height: nil];
}

// 默认下划线
- (instancetype)initWithCellClassName:(NSString *)cellClassName data:(id)data height:(NSNumber *)height
{
    self = [super init];
    if (self) {
        return [self initWithCellClassName: cellClassName
                                      data: data
                            bottomLineLeft: @(defaultBottomLineLeft)
                           bottomLineRight: @(defaultBottomLineRight)
                                    height: height];
    }
    
    return self;
}

// 制定下划线，高度
- (instancetype)initWithCellClassName: (NSString *)cellClassName
                                 data: (id)data
                       bottomLineLeft: (NSNumber *)left
                      bottomLineRight: (NSNumber *)right
                               height: (NSNumber *)height{
    self = [super init];
    if (self) {
        self.cellClassName = cellClassName;
        self.data = data;
        self.height = height;
        self.bottomLineLeft = left;
        self.bottomLineRight = right;
    }
    
    return self;
}

- (instancetype)initWithCell:(BaseTableViewCell *)tableViewCell data:(id)data
{
    self = [super init];
    if (self) {
        self.tableViewCell = tableViewCell;
        self.data = data;
    }
    
    return self;
}

+ (instancetype)clearCellHeight:(CGFloat)height;
{
    // 注意！ ClearTableViewCell 定义在 BaseViewController
    CellDataModel *data = [[self alloc] initWithCellClassName:@"ClearTableViewCell" data: nil bottomLineLeft: nil bottomLineRight: nil height: @(height)];
    return data;
}

@end

