//
//  CellDataModel.h
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewCell.h"

@interface CellDataModel : NSObject

/**
 cell名也是做用Identifier
 */
@property (nonatomic, strong) NSString *cellClassName;
@property (nonatomic, strong) id data;
@property (strong, nonatomic) BaseTableViewCell *tableViewCell;

@property (nonatomic, strong) NSNumber * height; //默认nil，用cellClass返回的高度，当>=0时使用该heightb
//  >=0 has separator; <0 no separator
//@property (nonatomic, strong) NSNumber * topOriginXSeparatorLine;
@property (nonatomic, strong) NSNumber * bottomLineLeft;
@property (nonatomic, strong) NSNumber * bottomLineRight;
@property (nonatomic, strong) NSNumber * isAlphaSelect; //是否选用透明模式

// @property (nonatomic, assign) BOOL *showCustomLineView;

- (instancetype)initWithCellClassName: (NSString *)cellClassName data:(id)data;
- (instancetype)initWithCellClassName: (NSString *)cellClassName
                                 data: (id)data
                       bottomLineLeft: (NSNumber *)left
                      bottomLineRight: (NSNumber *)right
                               height: (NSNumber *)height;
- (instancetype)initWithCell:(BaseTableViewCell *)tableViewCell data:(id)data;

/**
 透明cell
 */
+ (instancetype)clearCellHeight:(CGFloat)height;

@end
