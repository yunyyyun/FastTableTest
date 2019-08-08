//
//  KlinePrams.h
//  KLine
//
//  Created by Violet on 2017/10/7.
//  Copyright © 2017年 Violet. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef KlinePrams_h
#define KlinePrams_h

#pragma mark - ***************************************** 判断设备 *************************
//IPhone6P适配项
#define IS_IPHONE_6P \
(fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)736) < DBL_EPSILON || \
fabs((double)[[UIScreen mainScreen] bounds].size.width - (double)736) < DBL_EPSILON)
//IPhone6适配项
#define IS_IPHONE_6 \
(fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)667) < DBL_EPSILON || \
fabs((double)[[UIScreen mainScreen] bounds].size.width - (double)667) < DBL_EPSILON)
//IPhone5适配项
#define IS_IPHONE_5 \
(fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON || \
fabs((double)[[UIScreen mainScreen] bounds].size.width - (double)568) < DBL_EPSILON)
//IPhone4适配项
#define IS_IPHONE_4 \
(fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)480) < DBL_EPSILON || \
fabs((double)[[UIScreen mainScreen] bounds].size.width - (double)480) < DBL_EPSILON)

#if TARGET_OS_IPHONE || TARGET_OS_TV
#define FSIZE_6P(size)         ( IS_IPHONE_4 ? (size - 2) : (IS_IPHONE_6P ? (size + 1) : size) )
#else
#define FSIZE_6P(size)         (size + 3)
#endif



#define dequalzero(a) (fabs(a) < DBL_EPSILON)             //判断double数字是否为0

#define X_SCALE_6                   (IS_IPHONE_6 ? (1.0) : (g_PageSize.width / 375.0))


#pragma mark - ********************************** math ****************************

#define fequal(a, b)  (fabsf((a) - (b)) < FLT_EPSILON) //判断两个float是否相等
#define fequalzero(a) (fabsf(a) < FLT_EPSILON)            //判断float数字是否为0
#define dequal(a, b)  (fabs((a) - (b)) < DBL_EPSILON)  //判断两个double是否相等
#define dequalzero(a) (fabs(a) < DBL_EPSILON)             //判断double数字是否为0

#pragma mark - ********************************** Screen && Position **********************************

#define g_PageSize CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - [UIApplication sharedApplication].statusBarFrame.size.height)

#pragma mark - ********* 精度设置

#define TradeAmountDigitsNum  2  //成交额精度
#define KLINE_SHOWMAXMIN           //是否显示最高最低点
#define TREND_KLINE_CROSSLINE_STAYTIME  1.5  //分时图、K线图十字线停留时间
#define KLINE_COMBINATION


#pragma mark - ********** View 间距等设置 *************

#define KLINE_BOUND_WIDTH 300
#define KLINE_PIECE_WIDTH 5.5


#if TARGET_OS_IPHONE || TARGET_OS_TV
#define KLINE_HORIZONTAL_TIMEHEIGHT         25
#define KLINE_HORIZONTAL_VOLUMEINFOHEIGHT   ((IS_IPHONE_4 || IS_IPHONE_5) ? 18 : (IS_IPHONE_6 ? 18 : 21))
#else
#define KLINE_HORIZONTAL_TIMEHEIGHT         16
#define KLINE_HORIZONTAL_VOLUMEINFOHEIGHT   18
#endif


#define TrendKlineAreaQuotaTitleValuePadding  4

#define KlineViewPanFocusSpace 25       //k线拖动十字线的灵敏度

#pragma mark - ********* View 字体 及 颜色 等设置 ***********

#if TARGET_OS_IPHONE || TARGET_OS_TV
#define HXCompositeTrendPriceLineColor        colorWithHex(0x191919)  //十字线中线颜色
#define HXCompositeTrendPriceBackgroundColor        colorWithHex(0x282828)  //十字线价格时间背景颜色
#else
#define HXCompositeTrendPriceLineColor        colorWithHex(0xaaaaaa)  //十字线中线颜色
#define HXCompositeTrendPriceBackgroundColor        colorWithHex(0xaaaaaa)  //十字线价格时间背景颜色
#endif

#define KLineCandInfoColor        colorWithHexWithAlpha(0xaaaaaa, 0.1) // 开高低收背景色
// 添加内容
#define KLineBoundLineColor        colorWithHexWithAlpha(0xaaaaaa, 0.2) // 框和线的颜色
#define KLineBoundLineColorVer     colorWithHexWithAlpha(0xaaaaaa, 0.5) // 竖线线的颜色

// 未设置
#define KLinePriceCalColor         colorWithHex(0x666666) // 价格刻度
// 指标 未设置
#define KLineChaTypeParamColor     colorWithHex(0x888888) // 指标参数颜色
#define KLineChaType0Color         [UIColor colorWithRed:255/255.0 green:95/255.0  blue:46/255.0  alpha:1] // 指标颜色第一条
#define KLineChaType1Color         [UIColor colorWithRed:74/255.0 green:144/255.0  blue:226/255.0  alpha:1]  // 指标颜色第二条
#define KLineChaType2Color         [UIColor colorWithRed:139/255.0 green:11/255.0  blue:255/255.0  alpha:1]  // 指标颜色第三条
#define KLineChaType3Color         [UIColor colorWithRed:246/255.0 green:169/255.0  blue:59/255.0  alpha:1]  // 指标颜色第四条
#define KLineChaType4Color         colorWithHex(0x3396ff) // 指标颜色第5条
#define KLineChaType5Color         colorWithHex(0xf24949) // 指标颜色第6条
#define KLineChaType6Color         colorWithHex(0x854dff) // 指标颜色第7条
#define KLineChaType7Color         colorWithHex(0x50e3c2) // 指标颜色第8条
#define KLineChaTypeCalColor       colorWithHex(0x888888) // 指标刻度颜色 如交易量


//默认初始颜色 ----
#define KLineMinColor           colorWithHex(0x4a9afa)  //k线最小的线图的线的颜色
#define RED_COLOR_STOCK_RISE               [UIColor redColor]//[DMConfig sharedObjcet].changeUpColor //上涨
#define GREEN_COLOR_STOCK_FALL             [UIColor greenColor]//.changeDownColor //下跌

#define KLineMACDZeroColor                 colorWithHex(0x888888) //macd指标下平的颜色

#define NoneInfoText            @"--"

/* K线请求的周期类型 BEGIN */
typedef NS_ENUM(NSUInteger, PERIOD_TYPE) {
    PERIOD_TYPE_MINUTE, // 分钟k
    PERIOD_TYPE_Hour,     //  时k,
    PERIOD_TYPE_DAY     //  日k,
};

typedef NS_ENUM(int, KlineIdxType){
    KlineIdxTypeNone = -1,
    IDX_VOLUMN,
    IDX_MACD,
    IDX_RSI,
    IDX_WR,//目前绘画有问题
    IDX_KDJ,
    IDX_PSY,
    IDX_BIAS,
    IDX_ASI,
    IDX_VR,
    IDX_BOLL,
    IDX_DMA,
    IDX_DMI,
    IDX_CCI,
    IDX_TRIX,
};
#define klineIdxTypeStringArray @[@"VOL", @"MACD", @"RSI", @"WR", @"KDJ", @"PSY", @"BIAS", @"ASI", @"VR", @"BOLL", @"DMA", @"DMI", @"CCI", @"TRIX"]
#define klineIdxTypeString(x) ((x >= 0 && x < klineIdxTypeStringArray.count) ? klineIdxTypeStringArray[x] : @"")

typedef NS_ENUM(int, KlinePriceIdxType){
	KlinePriceIdxTypeNone = -1,
	IDX_PriceIdx_MA = 0,
    IDX_PriceIdx_BOLL = 1,
    IDX_PriceIdx_EMA = 2,
};
#define klinePriceIdxTypeStringArray @[@"MA", @"BOLL", @"EMA"]
#define klinePriceIdxTypeString(x) ((x >= 0 && x < klinePriceIdxTypeStringArray.count) ? klinePriceIdxTypeStringArray[x] : @"")

typedef struct {
    KlinePriceIdxType priceIdxType;               // 主图指标
    KlineIdxType mainIdxType;                     // 幅图一指标
    KlineIdxType idxType;                         // 幅图二指标
}KlineIdxConfig;

// 指标设置
#define kline_price_types @[@(IDX_PriceIdx_MA), @(IDX_PriceIdx_EMA), @(IDX_PriceIdx_BOLL)]
#define kline_main_types @[@(IDX_VOLUMN)]
#define kline_types @[@(IDX_MACD), @(IDX_KDJ), @(IDX_RSI), @(IDX_TRIX)]

typedef struct
{
    float        diff;
    float        dea;
    float        macd;
} MACD_float;

typedef struct
{
    float RSI[3];
} RSI_float;//相对强弱

typedef struct
{
    double        W_R;
    double        W_R2;
} WR_float;//威廉%R指标

typedef struct
{
    float        K;
    float        D;
    float        J;
}KDJ_float;//超买超卖

typedef struct
{
    float        PSY;
    float        PSYMA;
}PSY_float;//心理线

typedef struct
{
    float       MB;
    float       UP;
    float       DN;
}BOLL_float;//布林线

typedef struct
{
    float BIAS[3];
}BIAS_float;

typedef struct
{
    float ASI;
    float ASIMA;
}ASI_float;

typedef struct
{
    float VR;
}VR_float;

typedef struct
{
    float OBV;
}OBV_float;

typedef struct
{
    float DDD;
    float AMA;
}DMA_float;

typedef struct
{
    float PDI;
    float MDI;
    float ADX;
    float ADXR;
}DMI_float;

typedef struct{
    float UPDM;
    float DOWNDM;
    float DX;
    float TR;
} DMIDI_float;

typedef struct
{
    float MAVOL1;
    float MAVOL2;
    float MAVOL3;
    float MAVOL4;
    float MAVOL5;
    float MAVOL6;
    float MAVOL7;
    float MAVOL8;
}VOLHS_float;

typedef struct
{
    float CCI;
}CCI_float;

typedef struct
{
    float TP;//（最高价+最低价+收盘价）÷3
    float MD;//中价与中价的N日内移动平均的差
    float BIAS;//N日内中价的绝对偏差
    float BIASMA;//N日内中价的平均绝对偏差
} CCI_temp_float;

typedef struct
{
    float EMA1;
    float EMA2;
    float EMA3;
} EMA_float;

typedef struct
{
    float TRIX;
} TRIX_float;

#endif
