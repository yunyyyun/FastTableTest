//
//  KlineHorizontalView.h
//  KLine
//
//  Created by Violet on 2017/10/7.
//  Copyright © 2017年 Violet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KlinePrams.h"

#define KlineHorizontalViewShowAllFocuse true

typedef NS_ENUM(NSUInteger, KLineViewType) {
    KLineViewTypeNormal = 0,                // 默认是预览图
    KLineViewTypeFullHorizontalScreen,      // 横屏k
    
};

@class HXKlineCompDayData;
@protocol KlineHorizontalViewDelegate <NSObject>

@optional

//请求K线历史数据
- (BOOL)requestKlineHistoryData;

- (void)dataChangeByUser;

//用户点击K线时调用,参数是K线数据 以及当日涨跌幅
- (void)updateKLineData:(HXKlineCompDayData *)data yData:(HXKlineCompDayData *)yData pointX:(NSInteger)pointX;

- (void)refreshKlineSetting;

@end


@interface KlineHorizontalView : UIView 

@property (nonatomic, strong) NSString *pairInfo;
@property (nonatomic, assign) KLineViewType kLineType;
@property (nonatomic, assign) KlineIdxConfig idxConfig;
//@property (nonatomic, assign) KlinePriceIdxType priceIdxType;               // 主图指标
//@property (nonatomic, assign) KlineIdxType mainIdxType;                     // 幅图一指标
//@property (nonatomic, assign) KlineIdxType idxType;                         // 幅图二指标
@property (nonatomic, assign) PERIOD_TYPE period;                           // 时间1m 5m 1h 1d
@property (nonatomic, weak) id<KlineHorizontalViewDelegate> delegate;
@property (nonatomic, copy) void (^tapSwitchMainChartTypeBlock) (void); // 上方主图中指标单击切换回调
@property (nonatomic, copy) void (^tapSwitchChartTypeBlock) (void); // 下方副图中指标单击切换回调
@property (nonatomic, copy) void (^updateFocusBlock)(double open, double high, double low, double close, double change, double volume, NSString *time); // 十字线

//配色
@property (nonatomic, strong) UIColor *textColor;           // 文字颜色
@property (strong, nonatomic) UIColor *themeBlueColor;      // 主题色
@property (strong, nonatomic) UIColor *thinLineColor;       //
@property (strong, nonatomic) UIColor *flatLineColor;       //
@property (nonatomic, strong) UIColor *infoBlackColor;
@property (nonatomic, strong) UIColor *boundColor;          // 框和线的颜色
@property (nonatomic, strong) UIColor *boundColorVer;       // 框和线的颜色
@property (nonatomic, strong) UIColor *riseColor;           // 涨的颜色
@property (nonatomic, strong) UIColor *fallColor;           // 跌的颜色
@property (nonatomic, strong) UIColor *stableColor;         // 平的颜色
//k线缩到最小显示线时线的颜色
@property (nonatomic, strong) UIColor *klineMinColor;
@property (nonatomic, strong) UIColor *maxMinPriceColor;    // k线里面最高最低点价格

// k线图移动多少条蜡烛
- (void)dataShowMove:(NSInteger)aInterger;
//设置k线数据
- (void)updateStocks:(NSArray<HXKlineCompDayData *> *)newDataArray;

- (void)hideCrossLine;
- (void)reDraw;

@end
