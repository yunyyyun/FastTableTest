//
//  PriceHistoryView.h
//  GoIco
//
//  Created by Violet on 2018/1/8.
//  Copyright © 2018年 ico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "HistoryPriceData.h"

typedef NS_ENUM(NSUInteger, PriceHistoryViewType) {
    PriceHistoryViewTypeNormal = 0,                 // 默认是价格趋势
    PriceHistoryViewTypeAsset,                      // 资金流入流出走势
    PriceHistoryViewTypeFullHorizontalScreen,       // 横屏
};
@interface PriceHistoryView : UIView

@property (nonatomic, assign) PriceHistoryViewType type;
@property (strong, nonatomic) UIColor *themeBlueColor;      // 主题色
@property (strong, nonatomic) UIColor *themeYellowColor;      // 主题色
@property (strong, nonatomic) UIColor *thinLineColor;       //
@property (strong, nonatomic) UIColor *flatLineColor;       //
// @property (strong, nonatomic) UIColor *trendViewBgColor;
@property (strong, nonatomic) UIColor *crossLineColor;      // 十字线
@property (strong, nonatomic) UIColor *lableColor;          // 坐标等标签字体颜色
@property (strong, nonatomic) UIColor *lableBgColor;
@property (strong, nonatomic) UIColor *volumeColor;         // 量图颜色

@property (strong, nonatomic) NSArray<HistoryPriceData *> *datas;

// 配置着
@property (assign, nonatomic) BOOL scrollable;//是否可以滚动
@property (assign, nonatomic) BOOL showTime;  //是否显示时间
@property (assign, nonatomic) BOOL showPrice; //是否显示价格指标
@property (assign, nonatomic) BOOL showVolume; // 显示量图

@property (assign, nonatomic) NSInteger numberOfPrice;  // 纵轴价格刻度线
@property (assign, nonatomic) NSInteger numberOfTime;   //  横轴时间刻度线

@property (strong, nonatomic) UIFont *font; // 坐标轴字体


///// ##########################
//@property (strong, nonatomic) UIFont *font;

@property (nonatomic, strong) NSString *marketInfo;
//数据
@property (strong, nonatomic) NSString *priceInfo;
@property (strong, nonatomic) NSString *volumeInfo;


@property (nonatomic, assign) BOOL isMarketIndex;  // 市场指数

@property (strong, nonatomic) void(^didSelectAnchor)(CGRect area);// 点击选择区域

@property (nonatomic, copy) void (^updateFocusBlock)(CGPoint point,NSString *price,NSString *time);

@end


