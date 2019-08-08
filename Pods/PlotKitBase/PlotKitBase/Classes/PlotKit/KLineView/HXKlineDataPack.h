//
//  HXKlineDataPack.h
//  TZYJ_IPhone
//
//  Created by 邓莹莹 on 16/11/25.
//
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif
#import "StockInfo.h"
#import "KlinePrams.h"
#import "HXKlineCompDayData.h"

#define KLINE_PILLAR_MAXWIDTH 25.5  //每个柱子的最大宽度
#define KLINE_PILLAR_MINWIDTH 1.5   //每个柱子的最小宽度

@interface HXKlineDataPack : NSObject {
    NSDateFormatter *_dateFormatter;   //时间格式
    NSDate *         _openTime;        //开盘时间
    NSDate *         _nowTime;         //现在时间
    unsigned long    _vvTotal;         //虚拟成交量，用于vol-hs指标
    
    //绘制相关数据
    NSInteger _totalWidth;    //总宽度
	double _pillarWidth;   //柱子宽度
	double _pillarSpace;   //相邻柱子间距为
    NSInteger _pillarNum;     //计算出来的一屏幕可以显示的柱子个数
    
    NSInteger _leftOffset;   //由于整除或预留，默认为1
#ifdef KLINE_SHOWMAXMIN
    NSInteger _maxIndex;    //最高价下标
    NSInteger _minIndex;    //最低价下标
#endif
    
    float *         _ma1Data;
    float *         _ma2Data;
    float *         _ma3Data;
    float *         _ma4Data;
    float *         _ma5Data;
    float *         _ma6Data;
    float *         _ma7Data;
    float *         _ma8Data;
    MACD_float *    _macdData;
    RSI_float *     _rsiData;
    WR_float *      _wrData;
    KDJ_float *     _kdjData;
    PSY_float *     _psyData;
    BOLL_float *    _bollData;
    BIAS_float *    _biasData;
    ASI_float *     _asiData;
    VR_float *      _vrData;
    DMA_float *     _dmaData;
    DMI_float *     _dmiData;
    DMIDI_float *   _dmiDiData;
    VOLHS_float *   _volhsData;
    CCI_float *     _cciData;
    CCI_temp_float *_cciTempData;
    EMA_float *_emaData;
    TRIX_float *_trixData;

    UIColor *_lineColor[8];   //四个均线的颜色
    
    UIColor *_timeColor;   //最下面时间的颜色
    UIColor *_otherColor;
}

@property (nonatomic, strong) NSArray<HXKlineCompDayData *> *klineDataArr;
@property (nonatomic, strong) StockInfo *stockInfo;
@property (nonatomic, assign) PERIOD_TYPE period;

@property (nonatomic) int baseIndex;//基准柱子对应的数据下标，屏幕显示右边最后一条柱子
@property (nonatomic) int focusIndex;//用户焦点, 十字线
@property (assign, nonatomic) CGFloat focusIndexY;//用户焦点, 十字线Y轴坐标
@property (nonatomic) int focusIndexTmp;    //用户焦点, 十字线

@property (nonatomic) NSInteger totalWidth;
@property (nonatomic) double pillarWidth;
@property (nonatomic) double pillarSpace;

@property (nonatomic) int pointNum;

@property (assign, nonatomic) double upLimit;//数据当前上界 临时数据
@property (assign, nonatomic) double downLimit;//数据当前下界

@property (nonatomic, readonly) NSInteger leftOffset;
@property (nonatomic, readonly) NSInteger pillarNum;

@property (nonatomic, readonly) NSInteger firstIndex;  //屏幕中显示的左边第一条的索引
@property (nonatomic, readonly) NSInteger lastIndex;   //屏幕中显示的右边最后一条的索引

//配色
@property (nonatomic, strong) UIColor *riseColor;      //涨的颜色
@property (nonatomic, strong) UIColor *fallColor;      //跌的颜色
//目前只有MACD下有
@property (nonatomic, strong) UIColor *stableColor;    //平的颜色
//十字线颜色
@property (nonatomic, strong) UIColor *compositeLineColor;    //十字线中线颜色
@property (nonatomic, strong) UIColor *compositeBackgroundColor;  //十字线价格时间背景颜色
//k线里面最高最低点价格
@property (nonatomic, strong) UIColor *maxMinPriceColor;//k线里面最高最低点价格
//k线缩到最小显示线时线的颜色
@property (nonatomic, strong) UIColor *klineMinColor;
@property (nonatomic, assign) BOOL hiddenMaxMin;//是否隐藏最高最低值

- (void)generateIndicatrix;
- (double)preCloseOfIndex:(NSInteger)aInt;

- (void)updateWithStockCompdayDatas:(NSArray *)newDataArray;
- (NSString *)timeOfIndex:(NSInteger)index;
- (NSString *)timeOfDate:(long long)date;

@end

