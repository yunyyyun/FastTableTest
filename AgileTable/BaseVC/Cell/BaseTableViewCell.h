//
//  BaseTableViewCell.h
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "BaseSelectCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CellSwipStatus) {
    CellSwipStatusNone = 0,
    CellSwipStatusAction,
};

@interface BaseTableViewCell : BaseSelectCell

//  >=0 has separator; <0 no separator
// @property (nonatomic, assign) IBInspectable int topOriginXSeparatorLine;        // 上分割线左
@property (nonatomic, assign) IBInspectable int bottomLineLeft;     // 下分割线左
@property (nonatomic, assign) IBInspectable int bottomLineRight;    // 下分割线右
@property (nonatomic, strong) UIColor *separatorLineColor;
@property (nonatomic, assign) CGFloat rightPanSpace; // 左滑action的宽度
@property (nonatomic, assign) CellSwipStatus swipStatus;

//@property (nonatomic, strong) NSNumber *tempTopOriginXSeparatorLine;
@property (nonatomic, strong) NSNumber *tempBottomLineLeft;
@property (nonatomic, strong) NSNumber *tempBottomLineRight;

// 由setDataModel:viewController:tableView:方法中设置的内容
@property (nonatomic, weak, readonly) UIViewController *viewController;
@property (nonatomic, weak, readonly) UITableView *tableView;

/*!设置数据, data 要实现xxxPresentable(xxx 为内名字)
 */
- (void)setDataModel:(id)data
      viewController:(UIViewController *)viewController
           tableView:(UITableView *)tableView;
//table点击了cell
- (void)didSelectCell;
/*!根据数据计算cell的高度, data 要实现xxxPresentable(xxx 为内名字)
 */
+ (CGFloat)heightWithData:(id)data width:(CGFloat)width;

/*! data是否有效 是否实现xxxPresentable(xxx 为内名字)
 */
+ (BOOL)isAvalublePresentabletDataModel:(id)data;

// 左滑效果重置
- (void)resetContentView;
- (void)updatePanProgress:(CGFloat)progress;//子类继承，左滑到rightPanSpace距离的进度，0~1

@end

NS_ASSUME_NONNULL_END
