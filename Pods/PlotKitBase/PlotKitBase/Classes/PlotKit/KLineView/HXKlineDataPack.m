//
//  HXKlineDataPack.m
//  TZYJ_IPhone
//
//  Created by 邓莹莹 on 16/11/25.
//
//

#import "HXKlineDataPack.h"
#import "HXKlineUtils.h"
#import "DateKit.h"
#import "ColorKit.h"
#import "NumberKit.h"
#import "UIView+Size.h"
#import "TradConfig.h"
#import "KLineIndicators.h"
#import "NSString+Size.h"

#define KLINE_PILLAR_WIDTH 0.5

#define KlineIndexInfoFont [UIFont systemFontOfSize:11]
#define KLINE_FONT_TIME             [UIFont systemFontOfSize:11]
#define KLINE_FONT_Price             [UIFont systemFontOfSize:10]
#define KLINE_FONT_MAXMIN           [UIFont systemFontOfSize:9]

#define KLINE_IMAGE_HEIGHT 14

#define KLINE_CURVENAME_SEP 5

#define BIAS1PARAM 6
#define BIAS2PARAM 12
#define BIAS3PARAM 24
#define VRPARAM 24
#define PSYNPARAM 12
#define PSYMPARAM 6
#define RSI1PARAM 6
#define RSI2PARAM 12
#define RSI3PARAM 24
#define WRPARAM 14
#define WR2PARAM 28
#define ASIMAPARAM 6

#define veryLightColor [UIColor colorWithWhite:240/255.0 alpha:1]

#define FOR_I_ON_SHOW       for (NSInteger i = self.firstIndex; i < _baseIndex + 1; i++)
#define OFFSET_I_ON_SHOW    (i - self.firstIndex)
#define OFFSET_ON_SHOW(pos) (pos - self.firstIndex)

#pragma mark - *************** HsKlineDataPackHD

@implementation HXKlineDataPack

#pragma mark init and override methods

- (void)dealloc
{
    [self freeAllMemory];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        _pointNum = 0;
        _pillarWidth = KLINE_PIECE_WIDTH;
		_pillarSpace = 2;
        _totalWidth = KLINE_BOUND_WIDTH * 0.5;
        _pillarNum = 20;
        _baseIndex = -1;
        _focusIndex = -1;
        
#ifdef KLINE_SHOWMAXMIN
        _maxIndex = -1;
        _minIndex = -1;
#endif
        _period = 0;
        
        _riseColor = RED_COLOR_STOCK_RISE;
        _fallColor = GREEN_COLOR_STOCK_FALL;
        _stableColor = KLineMACDZeroColor;
        
        _lineColor[0] = KLineChaType0Color;
        _lineColor[1] = KLineChaType1Color;
        _lineColor[2] = KLineChaType2Color;
        _lineColor[3] = KLineChaType3Color;
        _lineColor[4] = KLineChaType4Color;
        _lineColor[5] = KLineChaType5Color;
        _lineColor[6] = KLineChaType6Color;
        _lineColor[7] = KLineChaType7Color;

        _timeColor = colorWithHex(0x89898b);
        _otherColor = [UIColor blackColor];

		self.compositeLineColor = HXCompositeTrendPriceLineColor;
		self.compositeBackgroundColor = HXCompositeTrendPriceBackgroundColor;
		self.klineMinColor = KLineMinColor;
    }
    
    return self;
}

#pragma mark setters & getters

//分时图和K线图切换时，如果_baseIndex没有重置会出问题
- (void)setPeriod:(PERIOD_TYPE)period
{
	_period = period;
	_baseIndex = -1;  //重置baseIndex
}

- (void)setBaseIndex:(int)baseIndex
{
    if (_pointNum <= 0) {
        _baseIndex = -1;
        return;
    }
    
    _baseIndex = baseIndex;
}

- (void)setPillarWidth:(double)pillarWidth
{
    if (pillarWidth != _pillarWidth) {
        _pillarWidth = pillarWidth;

        [self updatePillarNum];
        [self updateBaseIndexByPillarNum];
    }
}

- (void)setTotalWidth:(NSInteger)totalWidth
{
    if (_totalWidth != totalWidth) {
        _totalWidth = totalWidth;
        
        [self updatePillarNum];
        [self updateBaseIndexByPillarNum];
    }
}

- (void)updatePillarNum
{
    //一屏幕可以显示的柱子个数, pillarWidth + _pillarSpace是柱子的宽度+两个柱子之间的间隔
    _pillarSpace = MAX(_pillarWidth / 2, 1);
    
    // 防止间隙太大
    if (_pillarSpace > 4){
        _pillarSpace = 4;
        _pillarWidth = _pillarWidth + (_pillarSpace-4);
    }
    
    _pillarNum = (_totalWidth + _pillarSpace) / (_pillarWidth + _pillarSpace);
    CGFloat dY = _totalWidth - (_pillarWidth + _pillarSpace) * _pillarNum + _pillarSpace;
    _pillarSpace += dY / (_pillarNum - 1);
}

//柱子宽度变化之后，一屏幕显示的K线柱子变多或变少了，会影响最右侧K线柱子的索引，即会影响_baseIndex
- (void)updateBaseIndexByPillarNum
{
    if (_baseIndex < _pillarNum - 1) {
        if (_pointNum < _pillarNum) { //最近的K线，但柱子没有填满屏幕，说明该股票刚上市不久
            _baseIndex = _pointNum - 1;
        }
        else {
            _baseIndex = (int)_pillarNum - 1;
        }
    }
}

- (NSInteger)firstIndex
{
    NSInteger tempIndex = _baseIndex - _pillarNum + 1;
    
    if (tempIndex < 0) {
        return 0;
    }
    
    if (tempIndex > _baseIndex) {
        return _baseIndex;
    }
    
    return tempIndex;
}

- (NSInteger)lastIndex
{
    return _baseIndex;
}

#pragma mark - data methods

- (void)updateWithStockCompdayDatas:(NSArray<HXKlineCompDayData *> *)newDataArray
{
    int newDataSize = (int)[newDataArray count];
    self.klineDataArr = newDataArray;

    [self prepareIndicatrixMemory:newDataSize];
    //baseIndex指向K线最右边的点
    if (_baseIndex == -1) {
        _baseIndex = newDataSize - 1;
        [self updatePillarNum];
    } else {
        int lenght = _pointNum - _baseIndex;
        _baseIndex = newDataSize - lenght;
        _baseIndex =  MIN(MAX(0, _baseIndex), newDataSize - 1);
    }
    _pointNum = newDataSize;

    //计算指标
    [self generateIndicatrix];
    [self updatePillarNum];
    [self updateBaseIndexByPillarNum];
    _upLimit = 1;
    _downLimit = 0;
}

#pragma mark - ************ inner methods

- (void)freeAllMemory
{
    if (NULL != _ma1Data) {
        free(_ma1Data);
        _ma1Data = NULL;
    }
    if (NULL != _ma2Data) {
        free(_ma2Data);
        _ma2Data = NULL;
    }
    if (NULL != _ma3Data) {
        free(_ma3Data);
        _ma3Data = NULL;
    }
    if (NULL != _ma4Data) {
        free(_ma4Data);
        _ma4Data = NULL;
    }
    if (NULL != _ma5Data) {
        free(_ma5Data);
        _ma5Data = NULL;
    }
    if (NULL != _ma6Data) {
        free(_ma6Data);
        _ma6Data = NULL;
    }
    if (NULL != _ma7Data) {
        free(_ma7Data);
        _ma7Data = NULL;
    }
    if (NULL != _ma8Data) {
        free(_ma8Data);
        _ma8Data = NULL;
    }
    if (NULL != _macdData) {
        free(_macdData);
        _macdData = NULL;
    }
    if (NULL != _rsiData) {
        free(_rsiData);
        _rsiData = NULL;
    }
    if (NULL != _wrData) {
        free(_wrData);
        _wrData = NULL;
    }
    if (NULL != _kdjData) {
        free(_kdjData);
        _kdjData = NULL;
    }
    if (NULL != _psyData) {
        free(_psyData);
        _psyData = NULL;
    }
    if (NULL != _bollData) {
        free(_bollData);
        _bollData = NULL;
    }
    if (NULL != _biasData) {
        free(_biasData);
        _biasData = NULL;
    }
    if (NULL != _asiData) {
        free(_asiData);
        _asiData = NULL;
    }
    if (NULL != _vrData) {
        free(_vrData);
        _vrData = NULL;
    }
    if (NULL != _dmaData) {
        free(_dmaData);
        _dmaData = NULL;
    }
    if (NULL != _dmiData) {
        free(_dmiData);
        _dmiData = NULL;
    }
    if (NULL != _dmiDiData) {
        free(_dmiDiData);
        _dmiDiData = NULL;
    }

    if (NULL != _cciData) {
        free(_cciData);
        _cciData = NULL;
    }
    if (NULL != _cciTempData) {
        free(_cciTempData);
        _cciTempData = NULL;
    }
    if (NULL != _volhsData) {
        free(_volhsData);
        _volhsData = NULL;
    }
    if (NULL != _emaData) {
        free(_emaData);
        _emaData = NULL;
    }
    if (NULL != _trixData) {
        free(_trixData);
        _trixData = NULL;
    }
}

- (void)prepareIndicatrixMemory:(int)memNum
{
    [self freeAllMemory];
    
//内存申请
	_ma1Data = (float *) malloc(memNum * sizeof(float));
	_ma2Data = (float *) malloc(memNum * sizeof(float));
    _ma3Data = (float *) malloc(memNum * sizeof(float));
    _ma4Data = (float *) malloc(memNum * sizeof(float));
    _ma5Data = (float *) malloc(memNum * sizeof(float));
    _ma6Data = (float *) malloc(memNum * sizeof(float));
    _ma7Data = (float *) malloc(memNum * sizeof(float));
    _ma8Data = (float *) malloc(memNum * sizeof(float));
	_macdData = (MACD_float *) malloc(memNum * sizeof(MACD_float));
	_rsiData = (RSI_float *) malloc(memNum * sizeof(RSI_float));
	_wrData = (WR_float *) malloc(memNum * sizeof(WR_float));
	_kdjData = (KDJ_float *) malloc(memNum * sizeof(KDJ_float));
	_psyData = (PSY_float *) malloc(memNum * sizeof(PSY_float));
	_bollData = (BOLL_float *) malloc(memNum * sizeof(BOLL_float));
	_biasData = (BIAS_float *) malloc(memNum * sizeof(BIAS_float));
	_asiData = (ASI_float *) malloc(memNum * sizeof(ASI_float));
	_vrData = (VR_float *) malloc(memNum * sizeof(VR_float));
	_dmaData = (DMA_float *) malloc(memNum * sizeof(DMA_float));
	_dmiData = (DMI_float *) malloc(memNum * sizeof(DMI_float));
	_dmiDiData = (DMIDI_float *) malloc(memNum * sizeof(DMIDI_float));
	_cciData = (CCI_float *) malloc(memNum * sizeof(CCI_float));
    _cciTempData = (CCI_temp_float *) malloc(memNum * sizeof(CCI_temp_float));
    _volhsData = (VOLHS_float *) malloc(memNum * sizeof(VOLHS_float));
    _emaData = (EMA_float *) malloc(memNum * sizeof(EMA_float));
    _trixData = (TRIX_float *) malloc(memNum * sizeof(TRIX_float));
}

#pragma mark - instant methods

- (NSString *)timeOfIndex:(NSInteger)index
{
    if (index >= self.klineDataArr.count) return nil;
    
    long long date = [self.klineDataArr objectAtIndex:index].m_openTime;
    return [self timeOfDate:date];
}

- (NSString *)timeOfDate:(long long)dateTime
{
    if (self.period == PERIOD_TYPE_DAY) {
        return dateStringByMarketTime(dateTime);
    } else if (self.period == PERIOD_TYPE_MINUTE) {
        return dateHourMinuteStringByMarketTime(dateTime);
    } else if (self.period == PERIOD_TYPE_Hour) {
        return monthHourStringByMarketTime(dateTime);
    }

    return dateStringByMarketTime(dateTime);
}

- (double)preCloseOfIndex:(NSInteger)aInt
{
    if (_pointNum < 1) {
        return 0.f;
    }
    
    if (aInt == 0) {
        return ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:0]).m_lOpenPrice;
    }
    else if (aInt > _pointNum) {
        return ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:_pointNum - 1]).m_lClosePrice;
    }
    else {
        return ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:aInt - 1]).m_lClosePrice;
    }
}

#pragma mark - single Indicatrix
#pragma mark 计算指标

//计算指标
- (void)generateIndicatrix
{
    double        ma1Sum = 0, ma2Sum = 0, ma3Sum = 0, ma4Sum = 0, ma5Sum = 0, ma6Sum = 0, ma7Sum = 0, ma8Sum = 0; //均线相关
    double        ema1 = 0, ema2 = 0, diffSum = 0; //MACD相关
    double        rsi[3][2];//rsi1、rsi2、rsi3涨跌和 //0涨1跌
    double        highPrice = 0.0, lowPrice = 0.0;//wr、kdj相关
    double        rsv = 0;//kdj相关
    NSInteger     psySum = 0;//psy相关
    double        psymaSum = 0.0;
    double        bollmaSum = 0.0;//BOLL相关
    double        dmaShortmaSum = 0.0, dmaLongmaSum = 0.0, dmaDDDmaSum = 0.0, dmaShortma = 0.0, dmaLongma = 0.0;//DMA相关
    double        dmiUpDMSum = 0.0, dmiDownDMSum = 0.0, dmiTRSum = 0.0, dmiDXSum = 0.0;//DMI相关
    double        volhsMa5Sum = 0.0, volhsMa10Sum = 0.0, volhsMa30Sum = 0.0, volhsMaSum4 = 0.0, volhsMaSum5 = 0.0, volhsMaSum6 = 0.0, volhsMaSum7 = 0.0, volhsMaSum8 = 0.0;//VOLHS相关
    double        TPSum = 0.0, TPma = 0.0, BIASSum = 0.0, BIASMa = 0.0;//CCI相关
    double        bias1maSum = 0.0, bias2maSum = 0, bias3maSum = 0; //bias相关
    double        asiA = 0, asiB = 0, asiC = 0, asiD = 0, asiE = 0, asiF = 0, asiG = 0, asiX = 0, asiR = 0, asiK = 0, asiSI = 0;//ASI
    double        vrAVS = 0, vrBVS = 0, vrCVS = 0;
    double        asimaSum = 0;
    double        emaA1 = 2. / ([KLineIndicators shareObject].EMA1Param + 1);
    double        emaA2 = 2. / ([KLineIndicators shareObject].EMA2Param + 1);
    double        emaA3 = 2. / ([KLineIndicators shareObject].EMA3Param + 1);
    double        trixA = 2. / ([KLineIndicators shareObject].TRIXParam + 1);
    double        trix1[_pointNum];
    double        trix2[_pointNum];
    double        trix3[_pointNum];
    if (self.focusIndex >= _pointNum) self.focusIndex = -1;
    
    for (NSInteger i = 0; i < _pointNum; i++) {
        HXKlineCompDayData *stockCompDayData = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:i];
        
        if (i == 0) {
            
            //ma基本值
            ma1Sum = ma2Sum = ma3Sum = ma4Sum = ma5Sum = ma6Sum = ma7Sum = ma8Sum = _ma1Data[0] = _ma2Data[0] = _ma3Data[0] = _ma4Data[0] = _ma5Data[0] = _ma6Data[0] = _ma7Data[0] = _ma8Data[0] = stockCompDayData.m_lClosePrice;

            //macd基本值初始化
            ema1 = stockCompDayData.m_lClosePrice;
            ema2 = stockCompDayData.m_lClosePrice;
            _macdData[0].diff = 0;
            _macdData[0].dea = 0;
            _macdData[0].macd = 0;
            diffSum = 0;
            
            
            //rsi基本值初始化
            rsi[0][0] = rsi[1][0] = rsi[2][0] = rsi[0][1] = rsi[1][1] = rsi[2][1] = 0;
            _rsiData[0].RSI[0] = _rsiData[0].RSI[1] = _rsiData[0].RSI[2] = 50;
            
            
            //wr、kdj基本值初始化
            if (stockCompDayData.m_lMaxPrice == stockCompDayData.m_lMinPrice) {
                _wrData[0].W_R = 100;
                rsv = 0;
            }
            else {
                _wrData[0].W_R = 100.0 * (stockCompDayData.m_lMaxPrice - stockCompDayData.m_lClosePrice) / (stockCompDayData.m_lMaxPrice - stockCompDayData.m_lMinPrice);
                rsv = 100.0 * (stockCompDayData.m_lClosePrice - stockCompDayData.m_lMinPrice) / (stockCompDayData.m_lMaxPrice - stockCompDayData.m_lMinPrice);
            }
            
            
            //kdj基本值初始化
            _kdjData[i].K = rsv;
            _kdjData[i].D = _kdjData[i].K;
            _kdjData[i].J = 3.0 * _kdjData[i].K - 2.0 * _kdjData[i].D;
            
            
            //psy基本值初始化
            psySum = 0;
            psymaSum = 0;
            _psyData[i].PSY = 0;
            _psyData[i].PSYMA = 0;
            
            //boll基本值初始化
            bollmaSum   =  stockCompDayData.m_lClosePrice;
            _bollData[0].MB = stockCompDayData.m_lClosePrice;
            _bollData[0].UP = stockCompDayData.m_lClosePrice;
            _bollData[0].DN = stockCompDayData.m_lClosePrice;
            
            //dma基本值初始化
            dmaShortmaSum = dmaLongmaSum  =  stockCompDayData.m_lClosePrice;
            dmaDDDmaSum = 0;
            _dmaData[0].DDD = 0;
            _dmaData[0].AMA = 0;
            
            //dmi基本值初始化
            dmiUpDMSum = dmiDownDMSum = dmiTRSum = 0;
            dmiDXSum = 0;
            _dmiDiData[0].UPDM = 0;
            _dmiDiData[0].DOWNDM = 0;
            _dmiDiData[0].DX = 0;
            _dmiDiData[0].TR = 0;
            _dmiData[0].PDI = 0;
            _dmiData[0].MDI = 0;
            _dmiData[0].ADX = 0;
            _dmiData[0].ADXR =0;
            
            
            //volhs基本值初始化
            volhsMa5Sum = volhsMa10Sum = volhsMa30Sum = volhsMaSum4 = volhsMaSum5 = volhsMaSum6 = volhsMaSum7 = volhsMaSum8 =
            _volhsData[0].MAVOL1 = _volhsData[0].MAVOL2 = _volhsData[0].MAVOL3 = _volhsData[0].MAVOL4 = _volhsData[0].MAVOL5 = _volhsData[0].MAVOL6 = _volhsData[0].MAVOL7 = _volhsData[0].MAVOL8 = stockCompDayData.m_lTotal;

            
            //CCI基本值初始化
            BIASSum = TPSum = _cciData[0].CCI = 0;
            
            
            //bias基本值初始化
            bias1maSum = bias2maSum = bias3maSum = stockCompDayData.m_lClosePrice;
            _biasData[0].BIAS[0] = _biasData[0].BIAS[1] = _biasData[0].BIAS[2] = 0;
            
            
            //ASI
            _asiData[i].ASI = 0;
            _asiData[i].ASIMA = 0;
            asimaSum = 0;
            
            vrAVS = 0;
            vrBVS = 0;
            vrCVS = stockCompDayData.m_lTotal;
            
            _emaData[0].EMA1 = _emaData[0].EMA2 = _emaData[0].EMA3 = stockCompDayData.m_lClosePrice;
            trix1[0] = trix2[0] = trix3[0] = stockCompDayData.m_lClosePrice;
//            _trixData[0].TRIX = 0;
        }
        else {
            HXKlineCompDayData *prevStockCompDayData = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - 1];
            
#pragma mark 计算均线各项指标
            if (i < [KLineIndicators shareObject].MA1Param) {
                ma1Sum += stockCompDayData.m_lClosePrice;
				_ma1Data[i] = ma1Sum / (i + 1);
            } else {
                ma1Sum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].MA1Param]).m_lClosePrice;
				_ma1Data[i] = ma1Sum / [KLineIndicators shareObject].MA1Param;
            }
            
            if (i < [KLineIndicators shareObject].MA2Param) {
                ma2Sum += stockCompDayData.m_lClosePrice;
				_ma2Data[i] = ma2Sum / (i + 1);
            } else {
                ma2Sum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].MA2Param]).m_lClosePrice;
				_ma2Data[i] = ma2Sum / [KLineIndicators shareObject].MA2Param;
            }
            
            if (i < [KLineIndicators shareObject].MA3Param) {
                ma3Sum += stockCompDayData.m_lClosePrice;
				_ma3Data[i] = ma3Sum / (i + 1);
            } else {
                ma3Sum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].MA3Param]).m_lClosePrice;
				_ma3Data[i] = ma3Sum / [KLineIndicators shareObject].MA3Param;
            }
            
            if (i < [KLineIndicators shareObject].MA4Param) {
                ma4Sum += stockCompDayData.m_lClosePrice;
                _ma4Data[i] = ma4Sum / (i + 1);
            } else {
                ma4Sum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].MA4Param]).m_lClosePrice;
                _ma4Data[i] = ma4Sum / [KLineIndicators shareObject].MA4Param;
            }
            if (i < [KLineIndicators shareObject].MA5Param) {
                ma5Sum += stockCompDayData.m_lClosePrice;
                _ma5Data[i] = ma5Sum / (i + 1);
            } else {
                ma5Sum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].MA5Param]).m_lClosePrice;
                _ma5Data[i] = ma5Sum / [KLineIndicators shareObject].MA5Param;
            }
            if (i < [KLineIndicators shareObject].MA6Param) {
                ma6Sum += stockCompDayData.m_lClosePrice;
                _ma6Data[i] = ma6Sum / (i + 1);
            } else {
                ma6Sum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].MA6Param]).m_lClosePrice;
                _ma6Data[i] = ma6Sum / [KLineIndicators shareObject].MA6Param;
            }
            if (i < [KLineIndicators shareObject].MA7Param) {
                ma7Sum += stockCompDayData.m_lClosePrice;
                _ma7Data[i] = ma7Sum / (i + 1);
            } else {
                ma7Sum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].MA7Param]).m_lClosePrice;
                _ma7Data[i] = ma7Sum / [KLineIndicators shareObject].MA7Param;
            }
            if (i < [KLineIndicators shareObject].MA8Param) {
                ma8Sum += stockCompDayData.m_lClosePrice;
                _ma8Data[i] = ma8Sum / (i + 1);
            } else {
                ma8Sum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].MA8Param]).m_lClosePrice;
                _ma8Data[i] = ma8Sum / [KLineIndicators shareObject].MA8Param;
            }
            
#pragma mark 计算macd各项指标
            /**
             * DIFF线　收盘价短期、长期指数平滑移动平均线间的差 DEA线　 DIFF线的M日指数平滑移动平均线
             * MACD线　DIFF线与DEA线的差，彩色柱状线 参数：SHORT(短期)、LONG(长期)、M 天数，一般为12、26、9
             * 加权平均指数（ＤＩ）=（当日最高指数+当日收盘指数+2倍的当日最低指数） 十二日平滑系数（Ｌ１２）=2/（12+1）=0.1538
             * 二十六日平滑系数（Ｌ２６）=2/（26+1）=0.0741
             * 十二日指数平均值（１２日ＥＭＡ）=L12×当日收盘指数+11/（12+1）×昨日的12日EMA
             * 二十六日指数平均值（２６日ＥＭＡ）=L26×当日收盘指数+25/（26+1）×昨日的26日EMA 差离率（ＤＩＦ）=12日EMA-26日EMA
             * 九日DIF平均值（DEA） =最近9日的DIF之和/9 柱状值（ＢＡＲ）=DIF-DEA
             *
             * 第二种算法： 1.EMA（SHORT）=收市价SHORT日指数移动平均；EMA（LONG）=收市价LONG日指数移动平均
             * 2.DIF=EMA（SHORT）-EMA（LONG） 3.DEA=DIF的MID日指数移动平均 4.MACD=DIF-DEA
             * 5.参数SHORT为12，参数LONG为26，参数MID为9
             */
            //_MACDsParam = 12; _MACDlParam = 26; _MACDaParam = 9;
            ema1 = stockCompDayData.m_lClosePrice * 2.0 / ([KLineIndicators shareObject].MACDsParam + 1) + ema1 * ([KLineIndicators shareObject].MACDsParam - 1.0) / ([KLineIndicators shareObject].MACDsParam + 1);
            ema2 = stockCompDayData.m_lClosePrice * 2.0 / ([KLineIndicators shareObject].MACDlParam + 1) + ema2 * ([KLineIndicators shareObject].MACDlParam - 1.0) / ([KLineIndicators shareObject].MACDlParam + 1);

            _macdData[i].diff = ema1 - ema2;
            _macdData[i].dea = _macdData[i].diff * 2.0 / ([KLineIndicators shareObject].MACDaParam + 1) + _macdData[i - 1].dea * ([KLineIndicators shareObject].MACDaParam - 1.0) / ([KLineIndicators shareObject].MACDaParam + 1.0);
            _macdData[i].macd = 2.0 * (_macdData[i].diff - _macdData[i].dea);

#pragma mark 计算rsi各项指标(0-100)
            NSInteger j;
            for (j = 0; j < 3; j++) {
                NSInteger limit = 0;
                switch (j) {
                    case 0:
                        limit = [KLineIndicators shareObject].RSI1Param;
                        break;
                    case 1:
                        limit = [KLineIndicators shareObject].RSI2Param;
                        break;
                    case 2:
                        limit = [KLineIndicators shareObject].RSI3Param;
                        break;
                    default:
                        break;
                }
                if (stockCompDayData.m_lClosePrice > prevStockCompDayData.m_lClosePrice) {
                    rsi[j][0] = (stockCompDayData.m_lClosePrice - prevStockCompDayData.m_lClosePrice + rsi[j][0] * (limit - 1.0)) / limit;
                    rsi[j][1] = (stockCompDayData.m_lClosePrice - prevStockCompDayData.m_lClosePrice + rsi[j][1] * (limit - 1.0)) / limit;;
                }
                else {
                    rsi[j][0] = rsi[j][0] * (limit - 1.0) / limit;
                    rsi[j][1] = (prevStockCompDayData.m_lClosePrice - stockCompDayData.m_lClosePrice + rsi[j][1] * (limit - 1.0)) / limit;
                }
                if (rsi[j][1] == 0) {
                    _rsiData[i].RSI[j] = (rsi[j][0] == 0) ? 50 : 100;
                }
                else {
                    _rsiData[i].RSI[j] = rsi[j][0] / rsi[j][1] * 100;
                }
            }
            
            
            //wr指标(0-100)
            //WR1一般是6天买卖强弱指标；
            //WR2一般是10天买卖强弱指标
            j = i > ([KLineIndicators shareObject].WR1Param - 1) ? (i - [KLineIndicators shareObject].WR1Param + 1) : 0;
            lowPrice = highPrice = 0;
            for (; j <= i; j++) {
                HXKlineCompDayData *item = (HXKlineCompDayData *) [_klineDataArr objectAtIndex:j];
                if (item.m_lMaxPrice > highPrice || highPrice == 0) {
                    highPrice = item.m_lMaxPrice;
                }
                if ((item.m_lMinPrice < lowPrice || lowPrice == 0) && item.m_lMinPrice != 0) {
                    lowPrice = item.m_lMinPrice;
                }
            }
            
            if (lowerThanOrEqualToZero(highPrice - lowPrice)) {  //  连续停牌
                _wrData[i].W_R = 100.0;
            } else {
                _wrData[i].W_R = 100.0 * (highPrice - stockCompDayData.m_lClosePrice) / (highPrice - lowPrice);
            }
        

            j = i > ([KLineIndicators shareObject].WR2Param - 1) ? (i - [KLineIndicators shareObject].WR2Param + 1) : 0;
            lowPrice = highPrice = 0;
            for (; j <= i; j++) {
                HXKlineCompDayData *item = (HXKlineCompDayData *) [_klineDataArr objectAtIndex:j];
                if (item.m_lMaxPrice > highPrice || highPrice == 0) {
                    highPrice = item.m_lMaxPrice;
                }
                if ((item.m_lMinPrice < lowPrice || lowPrice == 0) && item.m_lMinPrice != 0) {
                    lowPrice = item.m_lMinPrice;
                }
            }
            
            
            if (lowerThanOrEqualToZero(highPrice - lowPrice)) { //  连续停牌
                _wrData[i].W_R2 = 100.0;
            }
            else {
                _wrData[i].W_R2 = 100.0 * (highPrice - stockCompDayData.m_lClosePrice) / (highPrice - lowPrice);
            }
            long start = 0;
            long len = [KLineIndicators shareObject].KDJkParam;
            if (i < 8) {
                len = i + 1;
            } else {
                start = i - 8;
            }
            lowPrice = ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:start]).m_lMinPrice;
            highPrice = ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:start]).m_lMaxPrice;
            for (long index = start; index < MIN(start +len, _klineDataArr.count); index ++) {
                HXKlineCompDayData *item = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:index];
                if ((item.m_lMaxPrice > highPrice || highPrice == 0)&& item.m_lMaxPrice > 0) {
                    highPrice = item.m_lMaxPrice;
                }
                if ((item.m_lMinPrice < lowPrice || lowPrice == 0) && item.m_lMinPrice > 0) {
                    
                    lowPrice = item.m_lMinPrice;
                }
                
            }
            
            if (zeroValue(highPrice - lowPrice)) {
                _kdjData[i].K = 0 ;
            }
            else {
                rsv = 100.0 * (stockCompDayData.m_lClosePrice - lowPrice) / (highPrice - lowPrice);
            }
            if (i == 0) {
                _kdjData[i].K = rsv;
                _kdjData[i].D = rsv;
            } else {
                _kdjData[i].K = (rsv + _kdjData[i - 1].K * ([KLineIndicators shareObject].KDJdParam - 1.0)) / [KLineIndicators shareObject].KDJdParam;
                _kdjData[i].D = (_kdjData[i].K + _kdjData[i - 1].D * ([KLineIndicators shareObject].KDJrParam - 1.0)) / [KLineIndicators shareObject].KDJrParam;
                
            }
            _kdjData[i].J = 3.0 * _kdjData[i].K - 2.0 * _kdjData[i].D;
            
            if (_kdjData[i].K > 100) {
                _kdjData[i].K  = 100;
                
            }else if(_kdjData[i].K < 0){
                _kdjData[i].K  = 0;
            }
            
            if (_kdjData[i].D > 100) {
                _kdjData[i].D  = 100;
            }else if(_kdjData[i].D < 0){
                _kdjData[i].D  = 0;
            }
            
            if (_kdjData[i].J > 100) {
                _kdjData[i].J  = 100;
            }else if(_kdjData[i].J < 0){
                _kdjData[i].J  = 0;
            }
            
            //PSY指标（0－100）

            if (i < [KLineIndicators shareObject].PSYnParam + 1) {
                if (stockCompDayData.m_lClosePrice > prevStockCompDayData.m_lClosePrice) {
                    psySum++;
                }
                _psyData[i].PSY = 100.0 * psySum / (float)(i + 1);
            }
            else {
                if (stockCompDayData.m_lClosePrice > prevStockCompDayData.m_lClosePrice) {
                    psySum++;
                }
                if (((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].PSYnParam]).m_lClosePrice > ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].PSYnParam - 1]).m_lClosePrice) {
                    psySum--;
                }
                _psyData[i].PSY = 100.0 * psySum / [KLineIndicators shareObject].PSYnParam;
            }
            
            if (i < [KLineIndicators shareObject].PSYmParam) {
                psymaSum += _psyData[i].PSY;
                _psyData[i].PSYMA = psymaSum / (i + 1);
            }
            else {
                psymaSum += _psyData[i].PSY - _psyData[i - [KLineIndicators shareObject].PSYmParam].PSY;
                _psyData[i].PSYMA = psymaSum / [KLineIndicators shareObject].PSYmParam;
            }
            
            //DMA
            if (i < [KLineIndicators shareObject].DMAshortMaParam) {
                dmaShortmaSum += stockCompDayData.m_lClosePrice;
                dmaShortma = dmaShortmaSum / (i + 1);
            }
            else {
                dmaShortmaSum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].DMAshortMaParam]).m_lClosePrice;
                dmaShortma = dmaShortmaSum / [KLineIndicators shareObject].DMAshortMaParam;
            }
            if (i < [KLineIndicators shareObject].DMAlongMaParam) {
                dmaLongmaSum += stockCompDayData.m_lClosePrice;
                dmaLongma = dmaLongmaSum / (i + 1);
            }
            else {
                dmaLongmaSum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].DMAlongMaParam]).m_lClosePrice;
                dmaLongma = dmaLongmaSum / [KLineIndicators shareObject].DMAlongMaParam;
            }
            _dmaData[i].DDD = dmaShortma - dmaLongma;
            if (i < [KLineIndicators shareObject].DMAdddMaParam) {
                dmaDDDmaSum += _dmaData[i].DDD;
                _dmaData[i].AMA = dmaDDDmaSum / (i + 1);
            }
            else {
                dmaDDDmaSum += _dmaData[i].DDD - _dmaData[i - [KLineIndicators shareObject].DMAdddMaParam].DDD;
                _dmaData[i].AMA = dmaDDDmaSum / [KLineIndicators shareObject].DMAshortMaParam;
            }
            
            //DMI
            _dmiDiData[i].UPDM = stockCompDayData.m_lMaxPrice - prevStockCompDayData.m_lMaxPrice;
            if (_dmiDiData[i].UPDM<0) {
                _dmiDiData[i].UPDM = 0;
            }
            _dmiDiData[i].DOWNDM = prevStockCompDayData.m_lMinPrice - stockCompDayData.m_lMinPrice;
            if (_dmiDiData[i].DOWNDM<0) {
                _dmiDiData[i].DOWNDM = 0;
            }
            if (_dmiDiData[i].UPDM>_dmiDiData[i].DOWNDM) {
                _dmiDiData[i].DOWNDM = 0;
            }
            else if (_dmiDiData[i].UPDM<_dmiDiData[i].DOWNDM) {
                _dmiDiData[i].UPDM = 0;
            }
            else {
                _dmiDiData[i].UPDM = _dmiDiData[i].DOWNDM =0;
            }
            if (i<[KLineIndicators shareObject].DMInParam) {
                dmiUpDMSum += _dmiDiData[i].UPDM;
            }
            else {
                dmiUpDMSum +=_dmiDiData[i].UPDM - _dmiDiData[i - [KLineIndicators shareObject].DMInParam].UPDM;
            }
            if (i<[KLineIndicators shareObject].DMInParam) {
                dmiDownDMSum += _dmiDiData[i].DOWNDM;
            }
            else {
                dmiDownDMSum +=_dmiDiData[i].DOWNDM - _dmiDiData[i - [KLineIndicators shareObject].DMInParam].DOWNDM;
            }
            _dmiDiData[i].TR = MAX(MAX(fabs(stockCompDayData.m_lMaxPrice - stockCompDayData.m_lMinPrice),
                                       fabs(stockCompDayData.m_lMaxPrice - prevStockCompDayData.m_lClosePrice)),
                                   fabs(stockCompDayData.m_lMinPrice - prevStockCompDayData.m_lClosePrice));
            if (i<[KLineIndicators shareObject].DMInParam) {
                dmiTRSum += _dmiDiData[i].TR;
            }
            else {
                dmiTRSum +=_dmiDiData[i].TR - _dmiDiData[i - [KLineIndicators shareObject].DMInParam].TR;
            }
            if (dmiTRSum != 0) {
                _dmiData[i].PDI = dmiUpDMSum / dmiTRSum * 100;
                _dmiData[i].MDI = dmiDownDMSum / dmiTRSum * 100;
            }
            else {
                _dmiData[i].PDI = 0;
                _dmiData[i].MDI = 0;
            }
            if ((_dmiData[i].PDI + _dmiData[i].MDI) != 0) {
                _dmiDiData[i].DX = fabsf(_dmiData[i].PDI - _dmiData[i].MDI) /
                (_dmiData[i].PDI + _dmiData[i].MDI) * 100;
            }
            else {
                _dmiDiData[i].DX = 0;
            }
            if (i<[KLineIndicators shareObject].DMImParam) {
                dmiDXSum += _dmiDiData[i].DX;
                _dmiData[i].ADX = dmiDXSum / (i + 1);
            }
            else {
                dmiDXSum +=_dmiDiData[i].DX - _dmiDiData[i - [KLineIndicators shareObject].DMImParam].DX;
                _dmiData[i].ADX = dmiDXSum / [KLineIndicators shareObject].DMImParam;
            }
            if (i<[KLineIndicators shareObject].DMImParam) {
                _dmiData[i].ADXR = (_dmiData[i].ADX + _dmiData[i - 1].ADX) / 2;
            }
            else {
                _dmiData[i].ADXR = (_dmiData[i].ADX + _dmiData[i - [KLineIndicators shareObject].DMImParam].ADX) / 2;
            }

			//根据成交量计算
			if (i<[KLineIndicators shareObject].VOLMA1Param) {
				volhsMa5Sum += stockCompDayData.m_lTotal;
				_volhsData[i].MAVOL1 = volhsMa5Sum / (i + 1);
			}
			else {
				volhsMa5Sum +=stockCompDayData.m_lTotal - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VOLMA1Param]).m_lTotal;
				_volhsData[i].MAVOL1 = volhsMa5Sum / [KLineIndicators shareObject].VOLMA1Param;
			}

			if (i<[KLineIndicators shareObject].VOLMA2Param) {
				volhsMa10Sum +=stockCompDayData.m_lTotal;
				_volhsData[i].MAVOL2 = volhsMa10Sum / (i + 1);
			} else {
				volhsMa10Sum +=stockCompDayData.m_lTotal - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VOLMA2Param]).m_lTotal;
				_volhsData[i].MAVOL2 = volhsMa10Sum / [KLineIndicators shareObject].VOLMA2Param;
			}

            if (i<[KLineIndicators shareObject].VOLMA3Param) {
                volhsMa30Sum +=stockCompDayData.m_lTotal;
                _volhsData[i].MAVOL3 = volhsMa30Sum / (i + 1);
            } else {
                volhsMa30Sum +=stockCompDayData.m_lTotal - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VOLMA3Param]).m_lTotal;
                _volhsData[i].MAVOL3 = volhsMa30Sum / [KLineIndicators shareObject].VOLMA3Param;
            }
            
            if (i<[KLineIndicators shareObject].VOLMA4Param) {
                volhsMaSum4 += stockCompDayData.m_lTotal;
                _volhsData[i].MAVOL4 = volhsMaSum4 / (i + 1);
            } else {
                volhsMaSum4 +=stockCompDayData.m_lTotal - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VOLMA4Param]).m_lTotal;
                _volhsData[i].MAVOL4 = volhsMaSum4 / [KLineIndicators shareObject].VOLMA4Param;
            }
            if (i<[KLineIndicators shareObject].VOLMA5Param) {
                volhsMaSum5 += stockCompDayData.m_lTotal;
                _volhsData[i].MAVOL5 = volhsMaSum5 / (i + 1);
            } else {
                volhsMaSum5 +=stockCompDayData.m_lTotal - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VOLMA5Param]).m_lTotal;
                _volhsData[i].MAVOL5 = volhsMaSum5 / [KLineIndicators shareObject].VOLMA5Param;
            }
            if (i<[KLineIndicators shareObject].VOLMA6Param) {
                volhsMaSum6 += stockCompDayData.m_lTotal;
                _volhsData[i].MAVOL6 = volhsMaSum6 / (i + 1);
            } else {
                volhsMaSum6 +=stockCompDayData.m_lTotal - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VOLMA6Param]).m_lTotal;
                _volhsData[i].MAVOL6 = volhsMaSum6 / [KLineIndicators shareObject].VOLMA6Param;
            }
            if (i<[KLineIndicators shareObject].VOLMA7Param) {
                volhsMaSum7 += stockCompDayData.m_lTotal;
                _volhsData[i].MAVOL7 = volhsMaSum7 / (i + 1);
            } else {
                volhsMaSum7 +=stockCompDayData.m_lTotal - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VOLMA7Param]).m_lTotal;
                _volhsData[i].MAVOL7 = volhsMaSum7 / [KLineIndicators shareObject].VOLMA7Param;
            }
            if (i<[KLineIndicators shareObject].VOLMA8Param) {
                volhsMaSum8 += stockCompDayData.m_lTotal;
                _volhsData[i].MAVOL8 = volhsMaSum8 / (i + 1);
            } else {
                volhsMaSum8 +=stockCompDayData.m_lTotal - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VOLMA8Param]).m_lTotal;
                _volhsData[i].MAVOL8 = volhsMaSum8 / [KLineIndicators shareObject].VOLMA8Param;
            }
            
            //CCI
            if (i < [KLineIndicators shareObject].CCINParam) {
                _cciTempData[i].TP = (stockCompDayData.m_lMaxPrice + stockCompDayData.m_lMinPrice + stockCompDayData.m_lClosePrice) / 3000.0;
                TPSum += _cciTempData[i].TP;
                TPma = TPSum / (i + 1);
                _cciTempData[i].MD = _cciTempData[i].TP - TPma;
                _cciTempData[i].BIAS = fabs(_cciTempData[i].TP - TPma);
                BIASSum += _cciTempData[i].BIAS;
                BIASMa = 0.015 * BIASSum / (i + 1);
                _cciData[i].CCI = (_cciTempData[i].TP - TPma) / BIASMa;
            }
            else {
                _cciTempData[i].TP = (stockCompDayData.m_lMaxPrice + stockCompDayData.m_lMinPrice + stockCompDayData.m_lClosePrice) / 3000.0;
                TPSum += _cciTempData[i].TP - _cciTempData[i - [KLineIndicators shareObject].CCINParam].TP;
                TPma = TPSum / [KLineIndicators shareObject].CCINParam;
                _cciTempData[i].MD = _cciTempData[i].TP - TPma;
                _cciTempData[i].BIAS = fabs(_cciTempData[i].TP - TPma);
                BIASSum += _cciTempData[i].BIAS - _cciTempData[i - [KLineIndicators shareObject].CCINParam].BIAS;
                BIASMa = 0.015 * BIASSum / [KLineIndicators shareObject].CCINParam;
                _cciData[i].CCI = (_cciTempData[i].TP - TPma) / BIASMa;
            }

            //BOLL，有意义实体线
            double bollMS, bollMD;
            if (i < [KLineIndicators shareObject].BOLLmaParam) {
                
                bollmaSum += stockCompDayData.m_lClosePrice;
                
                _bollData[i].MB = bollmaSum / (i + 1);
                bollMS = 0;
                for (int j = 0; j < i + 1; j++) {
                    bollMS += pow(((HXKlineCompDayData *)[_klineDataArr objectAtIndex:j]).m_lClosePrice - _bollData[i].MB, 2);
                }
                bollMD = sqrt(bollMS / i);
                _bollData[i].UP = _bollData[i].MB + (double)[KLineIndicators shareObject].BOLLwParam * bollMD;
                _bollData[i].DN = _bollData[i].MB - (double)[KLineIndicators shareObject].BOLLwParam * bollMD;
            } else {
                bollmaSum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].BOLLmaParam]).m_lClosePrice;
                _bollData[i].MB = bollmaSum / [KLineIndicators shareObject].BOLLmaParam;
                bollMS = 0;
                for (NSInteger j = i - [KLineIndicators shareObject].BOLLmaParam + 1; j < i + 1; j++) {
                    bollMS += pow(((HXKlineCompDayData *)[_klineDataArr objectAtIndex:j]).m_lClosePrice - _bollData[i].MB, 2);
                }
                bollMD = sqrt(bollMS / ([KLineIndicators shareObject].BOLLmaParam - 1));
                _bollData[i].UP = _bollData[i].MB + (double)[KLineIndicators shareObject].BOLLwParam * bollMD;
                _bollData[i].DN = _bollData[i].MB - (double)[KLineIndicators shareObject].BOLLwParam * bollMD;
            }

            //BIAS
            double maValue;
            if (i < [KLineIndicators shareObject].BIAS1Param) {
                bias1maSum += stockCompDayData.m_lClosePrice;
                maValue = bias1maSum / i;
            }
            else {
                bias1maSum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].BIAS1Param]).m_lClosePrice;
                maValue = bias1maSum / [KLineIndicators shareObject].BIAS1Param;
            }
            if (maValue < FLOAT_ZERO_ERROR && maValue > -FLOAT_ZERO_ERROR) {
                maValue = PRICE_ZERO_ERROR;
            }
            _biasData[i].BIAS[0] = (stockCompDayData.m_lClosePrice - maValue) / maValue * 100.0;
            if (i < [KLineIndicators shareObject].BIAS2Param) {
                bias2maSum += stockCompDayData.m_lClosePrice;
                maValue = bias2maSum / i;
            }
            else {
                bias2maSum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].BIAS2Param]).m_lClosePrice;
                maValue = bias2maSum / [KLineIndicators shareObject].BIAS2Param;
            }
            if (maValue < FLOAT_ZERO_ERROR && maValue > -FLOAT_ZERO_ERROR) {
                maValue = PRICE_ZERO_ERROR;
            }
            _biasData[i].BIAS[1] = (stockCompDayData.m_lClosePrice - maValue) / maValue * 100.0;
            if (i < [KLineIndicators shareObject].BIAS3Param) {
                bias3maSum += stockCompDayData.m_lClosePrice;
                maValue = bias3maSum / i;
            }
            else {
                bias3maSum += stockCompDayData.m_lClosePrice - ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].BIAS3Param]).m_lClosePrice;
                maValue = bias3maSum / [KLineIndicators shareObject].BIAS3Param;
            }
            if (maValue < FLOAT_ZERO_ERROR && maValue > -FLOAT_ZERO_ERROR) {
                maValue = PRICE_ZERO_ERROR;
            }
            _biasData[i].BIAS[2] = (stockCompDayData.m_lClosePrice - maValue) / maValue * 100.0;
            
            
            
            //ASI
            asiA = fabs(stockCompDayData.m_lMaxPrice - prevStockCompDayData.m_lClosePrice);
            asiB = fabs(stockCompDayData.m_lMinPrice - prevStockCompDayData.m_lClosePrice);
            asiC = fabs(stockCompDayData.m_lMaxPrice - prevStockCompDayData.m_lMinPrice);
            asiD = fabs(prevStockCompDayData.m_lClosePrice - prevStockCompDayData.m_lOpenPrice);
           
            if (asiA > asiB && asiA > asiC) {
                asiR = asiA + asiB / 2 + asiD / 4;
            }
            else if (asiB > asiA && asiB > asiC) {
                asiR = asiB + asiA / 2 + asiD / 4;
            }
            else {
                asiR = asiC + asiD / 4;
            }
            
            asiE = stockCompDayData.m_lClosePrice - prevStockCompDayData.m_lClosePrice;
            asiF = stockCompDayData.m_lClosePrice - stockCompDayData.m_lOpenPrice;
            asiG = prevStockCompDayData.m_lClosePrice - prevStockCompDayData.m_lOpenPrice;
            asiX = asiE + asiF / 2 + asiG;
            asiK = asiA > asiB ? asiA : asiB;
           
            if (asiR == 0) {
                asiSI = 0.0160 * asiK;
            }
            else {
                asiSI = 0.0160 * asiX / asiR * asiK;
            }
            _asiData[i].ASI = _asiData[i - 1].ASI + asiSI;
            
            
            if (i < ASIMAPARAM) {
                asimaSum += _asiData[i].ASI;
                _asiData[i].ASIMA = asimaSum / i;
            }
            else {
                asimaSum += _asiData[i].ASI - _asiData[i - ASIMAPARAM].ASI;
                _asiData[i].ASIMA = asimaSum / ASIMAPARAM;
            }
            
            if (stockCompDayData.m_lClosePrice > prevStockCompDayData.m_lClosePrice) {
                vrAVS += stockCompDayData.m_lTotal;
            }
            else if (stockCompDayData.m_lClosePrice < prevStockCompDayData.m_lClosePrice) {
                vrBVS += stockCompDayData.m_lTotal;
            }
            else {
                vrCVS += stockCompDayData.m_lTotal;
            }
            
            if (i == [KLineIndicators shareObject].VRParam) {
                HXKlineCompDayData *itemVRPARAM = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VRParam];
                vrCVS += itemVRPARAM.m_lTotal;
            }
            else if (i > [KLineIndicators shareObject].VRParam) {
                HXKlineCompDayData *itemVRPARAM = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VRParam];
                HXKlineCompDayData *prevItemVRPARAM = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:i - [KLineIndicators shareObject].VRParam - 1];
                if (itemVRPARAM.m_lClosePrice > prevItemVRPARAM.m_lClosePrice) {
                    vrAVS -= itemVRPARAM.m_lTotal;
                }
                else if (itemVRPARAM.m_lClosePrice < prevItemVRPARAM.m_lClosePrice) {
                    vrBVS -= itemVRPARAM.m_lTotal;
                }
                else {
                    vrCVS -= itemVRPARAM.m_lTotal;
                }
            }
            if (vrBVS + vrCVS / 2 < FLOAT_ZERO_ERROR && vrBVS + vrCVS / 2 > -FLOAT_ZERO_ERROR) {
                _vrData[i].VR = 100.0;
            }
            else {
                _vrData[i].VR = (vrAVS + vrCVS / 2) / (vrBVS + vrCVS / 2) * 100.0;
            }
            
            _emaData[i].EMA1 = emaA1 * stockCompDayData.m_lClosePrice + (1 - emaA1) * _emaData[i - 1].EMA1;
            _emaData[i].EMA2 = emaA2 * stockCompDayData.m_lClosePrice + (1 - emaA2) * _emaData[i - 1].EMA2;
            _emaData[i].EMA3 = emaA3 * stockCompDayData.m_lClosePrice + (1 - emaA3) * _emaData[i - 1].EMA3;
            
            trix1[i] = trixA * stockCompDayData.m_lClosePrice + (1 - trixA) * trix1[i - 1];
            trix2[i] = trixA * trix1[i] + (1 - trixA) * trix2[i - 1];
            trix3[i] = trixA * trix2[i] + (1 - trixA) * trix3[i - 1];
//            _trixData[i].TRIX = trixA * trix2[i] + (1 - trixA) * _trixData[i - 1].TRIX;
            _trixData[i].TRIX = (trix3[i] - trix3[i - 1]) / trix3[i - 1] * 100;
        }
    }
}

//计算指定绘制标准的曲线的上下限
- (void)prepareDrawData:(const void *)data numOfLines:(NSInteger)num
{
    float *floatData = (float*)data;
    _upLimit = _downLimit = floatData[_baseIndex * num];
    
    FOR_I_ON_SHOW {
        for (int j = 0; j < num; j++) {
            if (_upLimit  < floatData[i * num + j]) {
                _upLimit = floatData[i * num + j];
            }
            if (_downLimit > floatData[i * num + j]) {
                _downLimit = floatData[i * num + j];
            }
        }
    }
    
    if (_upLimit == _downLimit) {
        _upLimit = _upLimit * 1.1;
        _downLimit = _downLimit * 0.9;
        if (_upLimit == 0) {
            _upLimit = 100;
        }
    }
}

- (void)prepareDrawPrice
{
    _upLimit = ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:self.firstIndex]).m_lMaxPrice;
    _downLimit = ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:self.firstIndex]).m_lMinPrice;
    
#ifdef KLINE_SHOWMAXMIN
    _maxIndex = _minIndex = _baseIndex;
#endif
    
//    	FOR_I_ON_SHOW {
    for(NSInteger i = self.firstIndex; i < _baseIndex + 1; i++) {
    
        HXKlineCompDayData *stockCompDayData = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:i];
        
        if (stockCompDayData.m_lMaxPrice > _upLimit) {
            _upLimit = stockCompDayData.m_lMaxPrice;
        }
        if (stockCompDayData.m_lMinPrice < _downLimit && stockCompDayData.m_lMinPrice != 0) {
            _downLimit = stockCompDayData.m_lMinPrice;
        }
        
        if (stockCompDayData.m_lOpenPrice > _upLimit) {
            _upLimit = stockCompDayData.m_lOpenPrice;
        }
        if (stockCompDayData.m_lOpenPrice < _downLimit && stockCompDayData.m_lOpenPrice != 0) {
            _downLimit = stockCompDayData.m_lOpenPrice;
        }
        
        if (stockCompDayData.m_lClosePrice > _upLimit) {
            _upLimit = stockCompDayData.m_lClosePrice;
        }
        if (stockCompDayData.m_lClosePrice < _downLimit && stockCompDayData.m_lClosePrice != 0) {
            _downLimit = stockCompDayData.m_lClosePrice;
        }
        
        if ([KLineIndicators shareObject].MA1Show && i >= [KLineIndicators shareObject].MA1Param - 1) {
            if (_ma1Data[i] > _upLimit) {
                _upLimit = _ma1Data[i];
            }
            if (_ma1Data[i] < _downLimit) {
                _downLimit = _ma1Data[i];
            }
        }
        
        if ([KLineIndicators shareObject].MA2Show && i >= [KLineIndicators shareObject].MA2Param - 1) {
            if (_ma2Data[i] > _upLimit) {
                _upLimit = _ma2Data[i];
            }
            if (_ma2Data[i] < _downLimit) {
                _downLimit = _ma2Data[i];
            }
        }
        
        if ([KLineIndicators shareObject].MA3Show && i >= [KLineIndicators shareObject].MA3Param - 1) {
            if (_ma3Data[i] > _upLimit) {
                _upLimit = _ma3Data[i];
            }
            if (_ma3Data[i] < _downLimit) {
                _downLimit = _ma3Data[i];
            }
        }
        if ([KLineIndicators shareObject].MA4Show && i >= [KLineIndicators shareObject].MA4Param - 1) {
            if (_ma4Data[i] > _upLimit) {
                _upLimit = _ma4Data[i];
            }
            if (_ma4Data[i] < _downLimit) {
                _downLimit = _ma4Data[i];
            }
        }
        if ([KLineIndicators shareObject].MA5Show && i >= [KLineIndicators shareObject].MA5Param - 1) {
            if (_ma5Data[i] > _upLimit) {
                _upLimit = _ma5Data[i];
            }
            if (_ma5Data[i] < _downLimit) {
                _downLimit = _ma5Data[i];
            }
        }
        if ([KLineIndicators shareObject].MA6Show && i >= [KLineIndicators shareObject].MA6Param - 1) {
            if (_ma6Data[i] > _upLimit) {
                _upLimit = _ma6Data[i];
            }
            if (_ma6Data[i] < _downLimit) {
                _downLimit = _ma6Data[i];
            }
        }
        if ([KLineIndicators shareObject].MA7Show && i >= [KLineIndicators shareObject].MA7Param - 1) {
            if (_ma7Data[i] > _upLimit) {
                _upLimit = _ma7Data[i];
            }
            if (_ma7Data[i] < _downLimit) {
                _downLimit = _ma7Data[i];
            }
        }
        if ([KLineIndicators shareObject].MA8Show && i >= [KLineIndicators shareObject].MA8Param - 1) {
            if (_ma8Data[i] > _upLimit) {
                _upLimit = _ma8Data[i];
            }
            if (_ma8Data[i] < _downLimit) {
                _downLimit = _ma8Data[i];
            }
        }
        
        //		if (_upLimit  < _bollData[i].UP) {//和boll统一坐标系
        //			_upLimit = _bollData[i].UP;
        //		}
        //		if (_downLimit > _bollData[i].DN) {
        //			_downLimit = _bollData[i].DN;
        //		}
        
        
#ifdef KLINE_SHOWMAXMIN
        if (stockCompDayData.m_lMaxPrice >= ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:_maxIndex]).m_lMaxPrice) {
            _maxIndex = i;  //最高价下标
        }
        if (stockCompDayData.m_lMinPrice <= ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:_minIndex]).m_lMinPrice) {
            _minIndex = i;  //最低价下标
        }
#endif
    }
    
    if (_upLimit == 0 && dequal(_downLimit, _upLimit)) {
        _upLimit = 1000;
    }
    else {
        CGFloat scaleFactor = 1.03;

        double center = (_upLimit + _downLimit) / 2;
        
        scaleFactor = (_upLimit - center) / center;
        scaleFactor = scaleFactor * 1.015;
        
        _upLimit = center * (1 + scaleFactor);
        _downLimit = center * (1 - scaleFactor);
    }
}

- (void)prepareDrawDealMoney
{
    _nowTime =[NSDate date];
    
    NSString *nowTimeString =[_dateFormatter stringFromDate:_nowTime];
    
    _nowTime = [_dateFormatter dateFromString:nowTimeString];
    
    NSInteger timeInterval = (NSInteger)[_nowTime timeIntervalSinceDate:_openTime] / 60;
    
    if (timeInterval < 0 || timeInterval > 330) {//9点30之前与3点之后
        timeInterval = 240;
    }
    else if (timeInterval > 120 && timeInterval < 210) {//9点半之后与1点之前
        timeInterval = 120;
    }
    else if (timeInterval >= 210 && timeInterval <= 330) {
        timeInterval -= 90;
    }
    else {
        // TODO: 这个时间判断貌似不正确，现在走的都是这个特殊情况
        timeInterval = 240;
    }
    
    _vvTotal = self.klineDataArr[_pointNum - 1].m_lMoney * (240.0 / timeInterval);
    
    _upLimit = ((HXKlineCompDayData *)[_klineDataArr objectAtIndex:self.firstIndex]).m_lMoney;
    _downLimit = 0;
    
    FOR_I_ON_SHOW {
        HXKlineCompDayData *stockCompDayData = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:i];
        if (stockCompDayData.m_lMoney > _upLimit) {
            _upLimit = stockCompDayData.m_lMoney;
        }
    }
    if (_vvTotal > _upLimit) {
        _upLimit = _vvTotal;
    }
    
    if (_upLimit == 0) {
        _upLimit = 100;
    }
}

- (void)prepareDrawVolume
{
    _nowTime = [NSDate date];
    
    NSString *nowTimeString = [_dateFormatter stringFromDate:_nowTime];
    
    _nowTime = [_dateFormatter dateFromString:nowTimeString];
    
    NSInteger timeInterval = (NSInteger) [_nowTime timeIntervalSinceDate:_openTime] / 60;
    
    if (timeInterval < 0 || timeInterval > 330) { //9点30之前与3点之后
        timeInterval = 240;
    }
    else if (timeInterval > 120 && timeInterval < 210) { //9点半之后与1点之前
        timeInterval = 120;
    }
    else if (timeInterval >= 210 && timeInterval <= 330) {
        timeInterval -= 90;
    }
    else {
        // TODO: 这个时间判断貌似不正确，现在走的都是这个特殊情况
        timeInterval = 240;
    }
    
    _vvTotal = self.klineDataArr[_pointNum - 1].m_lTotal * (240.0 / timeInterval);
    
    _upLimit = ((HXKlineCompDayData *) [_klineDataArr objectAtIndex:self.firstIndex]).m_lTotal;
    _downLimit = 0;
    
    FOR_I_ON_SHOW {
        HXKlineCompDayData *stockCompDayData = (HXKlineCompDayData *) [_klineDataArr objectAtIndex:i];
        if (stockCompDayData.m_lTotal > _upLimit) {
            _upLimit = stockCompDayData.m_lTotal;
        }
    }
    
    if (_vvTotal > _upLimit) {
        _upLimit = _vvTotal;
    }
    
    if (_upLimit == 0) {
        _upLimit = 100;
    }
}

- (void)prepareDrawMACD
{
    _upLimit = 0;
    _downLimit = 0;
    
    FOR_I_ON_SHOW {
        if (_upLimit < _macdData[i].macd) {
            _upLimit = _macdData[i].macd;
        }
        if (_downLimit > _macdData[i].macd) {
            _downLimit = _macdData[i].macd;
        }
        
        if (_upLimit < _macdData[i].dea) {
            _upLimit = _macdData[i].dea;
        }
        if (_downLimit > _macdData[i].dea) {
            _downLimit = _macdData[i].dea;
        }
        
        if (_upLimit < _macdData[i].diff) {
            _upLimit = _macdData[i].diff;
        }
        if (_downLimit > _macdData[i].diff) {
            _downLimit = _macdData[i].diff;
        }
    }
    
    if (_upLimit == _downLimit) {
        _upLimit += 10;
        _downLimit -= 10;
    }
}

- (void)prepareDrawRSI
{
	_upLimit = _downLimit = _rsiData[self.firstIndex].RSI[0];
	FOR_I_ON_SHOW {
		for (int j = 0; j < 3; j++) {
			if (_upLimit < _rsiData[i].RSI[j]) {
				_upLimit = _rsiData[i].RSI[j];
			}
			if (_downLimit > _rsiData[i].RSI[j]) {
				_downLimit = _rsiData[i].RSI[j];
			}
		}
	}
	if (_upLimit == _downLimit) {
		_upLimit = 100;
		_downLimit = 0;
	}
}

- (void)prepareDrawWR
{
    _upLimit = _downLimit = _wrData[self.firstIndex].W_R;
    FOR_I_ON_SHOW {
        if (_upLimit < _wrData[i].W_R) {
            _upLimit = _wrData[i].W_R;
        }
        if (_downLimit > _wrData[i].W_R) {
            _downLimit = _wrData[i].W_R;
        }
        if (_upLimit < _wrData[i].W_R2) {
            _upLimit = _wrData[i].W_R2;
        }
        if (_downLimit > _wrData[i].W_R2) {
            _downLimit = _wrData[i].W_R2;
        }
    }
    if (lowerThanOrEqualToZero(_upLimit - _downLimit)) {
        _upLimit = 100;
        _downLimit = 0;
    }
}

- (void)prepareDrawKDJ
{
    _upLimit = _downLimit = _kdjData[self.firstIndex].K;
    FOR_I_ON_SHOW {
        //add by dyy. 分析软件上KDJ显示范围是 0-100
        if (_kdjData[i].J < 0) {
            _kdjData[i].J = 0;
        }
        if (_kdjData[i].J > 100) {
            _kdjData[i].J = 100;
        }
        
        
        if (_upLimit < _kdjData[i].K) {
            _upLimit = _kdjData[i].K;
        }
        if (_downLimit > _kdjData[i].K) {
            _downLimit = _kdjData[i].K;
        }
        if (_upLimit < _kdjData[i].D) {
            _upLimit = _kdjData[i].D;
        }
        if (_downLimit > _kdjData[i].D) {
            _downLimit = _kdjData[i].D;
        }
        if (_upLimit < _kdjData[i].J) {
            _upLimit = _kdjData[i].J;
        }
        if (_downLimit > _kdjData[i].J) {
            _downLimit = _kdjData[i].J;
        }
    }
    
    if (_upLimit == _downLimit) {
        _upLimit = 100;
        _downLimit = 0;
    }
}

- (void)prepareDrawBOLL
{
    FOR_I_ON_SHOW {
        if (_upLimit < _bollData[i].UP) { //和boll统一坐标系
            _upLimit = _bollData[i].UP;
        }
        if (_downLimit > _bollData[i].DN) {
            _downLimit = _bollData[i].DN;
        }
    }
    if (_upLimit == _downLimit) {
        _upLimit = 1000;
        _downLimit = 0;
    }
}

- (void)prepareDrawPSY
{
	_upLimit = _downLimit = _psyData[self.firstIndex].PSY;
	FOR_I_ON_SHOW {
		if (_upLimit < _psyData[i].PSY) {
			_upLimit = _psyData[i].PSY;
		}
		if (_downLimit > _psyData[i].PSY) {
			_downLimit = _psyData[i].PSY;
		}
		if (_upLimit < _psyData[i].PSYMA) {
			_upLimit = _psyData[i].PSYMA;
		}
		if (_downLimit > _psyData[i].PSYMA) {
			_downLimit = _psyData[i].PSYMA;
		}
	}
	if (_upLimit == _downLimit) {
		_upLimit = 100;
		_downLimit = 0;
	}
}

- (void)prepareDrawBIAS
{
	[self prepareDrawData:_biasData numOfLines:3];
}

- (void)prepareDrawVR
{
	[self prepareDrawData:_vrData numOfLines:1];
}

- (void)prepareDrawASI
{
	[self prepareDrawData:_asiData numOfLines:2];
}

- (void)prepareDrawDMA
{
	_upLimit = _downLimit = _dmaData[self.firstIndex].DDD;
    
	FOR_I_ON_SHOW {
		if (_upLimit < _dmaData[i].DDD) {
			_upLimit = _dmaData[i].DDD;
		}
		if (_downLimit > _dmaData[i].DDD) {
			_downLimit = _dmaData[i].DDD;
		}
		if (_upLimit < _dmaData[i].AMA) {
			_upLimit = _dmaData[i].AMA;
		}
		if (_downLimit > _dmaData[i].AMA) {
			_downLimit = _dmaData[i].AMA;
		}
	}
    
	if (_upLimit == _downLimit) {
		_upLimit = _upLimit * 1.1;
		_downLimit = _downLimit * 0.9;
	}
}

- (void)prepareDrawDMI
{
	_upLimit = _downLimit = _dmiData[self.firstIndex].PDI;
    
	FOR_I_ON_SHOW {
		if (_upLimit < _dmiData[i].PDI) {
			_upLimit = _dmiData[i].PDI;
		}
		if (_downLimit > _dmiData[i].PDI) {
			_downLimit = _dmiData[i].PDI;
		}
		if (_upLimit < _dmiData[i].MDI) {
			_upLimit = _dmiData[i].MDI;
		}
		if (_downLimit > _dmiData[i].MDI) {
			_downLimit = _dmiData[i].MDI;
		}
		if (_upLimit < _dmiData[i].ADX) {
			_upLimit = _dmiData[i].ADX;
		}
		if (_downLimit > _dmiData[i].ADX) {
			_downLimit = _dmiData[i].ADX;
		}
		if (_upLimit < _dmiData[i].ADXR) {
			_upLimit = _dmiData[i].ADXR;
		}
		if (_downLimit > _dmiData[i].ADXR) {
			_downLimit = _dmiData[i].ADXR;
		}
	}
	if (_upLimit == _downLimit) {
		_upLimit = _upLimit * 1.1;
		_downLimit = _downLimit * 0.9;
	}
}

- (void)prepareDrawVOLHS
{
    [self prepareDrawVolume];
    
    FOR_I_ON_SHOW {
        if (_upLimit < _volhsData[i].MAVOL1) {
            _upLimit = _volhsData[i].MAVOL1;
        }
        if (_upLimit < _volhsData[i].MAVOL2) {
            _upLimit = _volhsData[i].MAVOL2;
        }
        if (_upLimit < _volhsData[i].MAVOL3) {
            _upLimit = _volhsData[i].MAVOL3;
        }
        if (_upLimit < _volhsData[i].MAVOL4) {
            _upLimit = _volhsData[i].MAVOL4;
        }
        if (_upLimit < _volhsData[i].MAVOL5) {
            _upLimit = _volhsData[i].MAVOL5;
        }
        if (_upLimit < _volhsData[i].MAVOL6) {
            _upLimit = _volhsData[i].MAVOL6;
        }
        if (_upLimit < _volhsData[i].MAVOL7) {
            _upLimit = _volhsData[i].MAVOL7;
        }
        if (_upLimit < _volhsData[i].MAVOL8) {
            _upLimit = _volhsData[i].MAVOL8;
        }
    }
    
    if (_upLimit == _downLimit) {
        _upLimit = _upLimit * 1.1;
        _downLimit = _downLimit * 0.9;
    }
}

- (void)prepareDrawDealMoneyHS
{
    [self prepareDrawVOLHS];
}

- (void)prepareDrawCCI
{
	_upLimit = _downLimit = _cciData[self.firstIndex].CCI;
    
	FOR_I_ON_SHOW {
		if (_upLimit < _cciData[i].CCI) {
			_upLimit = _cciData[i].CCI;
		}
		if (_downLimit > _cciData[i].CCI) {
			_downLimit = _cciData[i].CCI;
		}
	}
    
	if (_upLimit == _downLimit) {
		_upLimit = _upLimit * 1.1;
		_downLimit = _downLimit * 0.9;
	}
}

#pragma mark -
#pragma mark draw methods

//在指定绘制标准的曲线，data为标准***_float型
- (void)drawData:(const void *)data numOfLines:(NSInteger)num inRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:data numOfLines:num inRect:rect context:context offset:0];
}

- (void)drawData:(const void *)data numOfLines:(NSInteger)num inRect:(CGRect)rect context:(CGContextRef)context offset:(NSInteger)offset
{
	for (int line = 0; line < num; line++) {
        [self drawData:data line:line numOfLines:num inRect:rect context:context offset:offset];
	}
}

- (void)drawData:(const void *)data line:(NSInteger)line numOfLines:(NSInteger)num inRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:data line:line numOfLines:num inRect:rect context:context offset:0];
}

- (void)drawData:(const void *)data line:(NSInteger)line numOfLines:(NSInteger)num inRect:(CGRect)rect context:(CGContextRef)context offset:(NSInteger)offset
{
    float *floatData = (float *) data;
    NSInteger firstIndex = MAX(self.firstIndex, offset);

    float drawX, drawY;
    drawX = rect.origin.x + _leftOffset + _pillarWidth / 2;
    drawY = (NSInteger) rect.origin.y + 1 + (rect.size.height - 3) * (_upLimit - floatData[firstIndex * num + line]) / (_upLimit - _downLimit);
    
    if (drawY < (NSInteger) rect.origin.y + 1) {
        drawY = (NSInteger) rect.origin.y + 1;
    }

    CGContextMoveToPoint(context, drawX + 0.5, drawY + 0.5);
    
    for (NSInteger i = firstIndex; i < _baseIndex + 1; i++) {
        drawX = rect.origin.x + _leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace) * OFFSET_I_ON_SHOW;
        drawY = (NSInteger) rect.origin.y + 1 + (rect.size.height - 3) * (_upLimit - floatData[i * num + line]) / (_upLimit - _downLimit);
        if (drawY < (NSInteger) rect.origin.y + 1) {
            drawY = (NSInteger) rect.origin.y + 1;
        }
        
        CGContextAddLineToPoint(context, drawX + 0.5, drawY + 0.5);
    }
    
    CGContextSetStrokeColorWithColor(context, _lineColor[line].CGColor);
    CGContextStrokePath(context);
}

//array 内个数为线数＋1，首个是不跟数据的指示
- (void)drawCenterInfo:(NSArray *)array withData:(const void *)data inRect:(CGRect)rect context:(CGContextRef)context
{
    NSInteger drawX, drawY;
    CGSize    drawSize;
    NSString *tempString;
    drawX = rect.origin.x + 1;
    NSInteger num = (NSInteger)[array count];
    float *   floatData = (float *) data;
    
    for (int i = 1; i < num; i++) {

		if (_focusIndex > -1) {
			tempString = [NSString stringWithFormat:@"%@%@", [array objectAtIndex:i],formatNumberWithDoubleAndDecimals( floatData[_focusIndex * (num - 1) + i - 1],3)];
		}
		else if (_pointNum > 0) {
			tempString = [NSString stringWithFormat:@"%@%@", [array objectAtIndex:i], formatterKlinePrice_pkb(floatData[(_baseIndex) * (num - 1) + i - 1])];
		}
		else {

			tempString = [NSString stringWithFormat:@"%@--", [array objectAtIndex:i]];
		}

		CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);


        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
        if (drawSize.width > 1) {
            drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
        }
    }
}

- (void)drawInfo:(NSArray *)array withData:(const void *)data inRect:(CGRect)rect context:(CGContextRef)context
{
	NSInteger drawX, drawY;
	CGSize    drawSize;
	NSString *tempString;
	drawX = rect.origin.x + 1;
	NSInteger num = (NSInteger)[array count];
	float *   floatData = (float *) data;
    
	for (int i = 0; i < num; i++) {
		if (i == 0) {
			tempString = [array objectAtIndex:0];
			CGContextSetFillColorWithColor(context, _otherColor.CGColor);
		}
        else {
            
			if (_focusIndex > -1) {
				tempString = [NSString stringWithFormat:@"%@%@", [array objectAtIndex:i], formatterKlinePrice_pkb(floatData[_focusIndex * (num - 1) + i - 1])];
			}
            else if (_pointNum > 0) {
				tempString = [NSString stringWithFormat:@"%@%@", [array objectAtIndex:i], formatterKlinePrice_pkb(floatData[(_baseIndex) * (num - 1) + i - 1])];
			}
            else {

				tempString = [NSString stringWithFormat:@"%@--", [array objectAtIndex:i]];
			}
            
			CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);
            
		}
        
		drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
		
        drawY = rect.origin.y;
		
        [TradConfig drawString:tempString
                        atPoint:CGPointMake(drawX, drawY)
                       withFont:KlineIndexInfoFont];
		
        if (drawSize.width > 1) {
			drawX += drawSize.width + KLINE_CURVENAME_SEP;
		}
	}
}

//绘制分割线
- (void)drawSeperateLineWithBeginPotin:(CGPoint)beginPotin endPoint:(CGPoint)endPoint context:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, beginPotin.x, beginPotin.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetAlpha(context, 0.3);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)drawPriceCalInRect:(CGRect)rect
             withRowNumber:(NSInteger)row
                   context:(CGContextRef)context
                     space:(CGFloat)space
              inBackground:(BOOL)inBackground
                boundLimit:(BOOL)limit
{
    NSInteger drawX, drawY;
    CGSize    drawSize;
    CGFloat   tempFloat;
    NSString *tempString;
    
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    double dPrice = _upLimit - _downLimit;
    double upLimit = _upLimit + dPrice * space / rect.size.height;
    double downLimit = _downLimit - dPrice * space / rect.size.height;
    for (int i = 0; i < row + 1; i++) {
        tempFloat = upLimit - (upLimit - downLimit) * i / row;
        if (tempFloat < 0)
            continue;
        tempString =  [_stockInfo stringOfPrice:tempFloat];//[self.stockInfo stringOfPrice:tempFloat];
        
        drawSize = [TradConfig sizeForString:tempString
                                    withFont:KLINE_FONT_Price
                                 minFontSize:5
                              actualFontSize:&tempFloat
                                    forWidth:rect.size.width
                               lineBreakMode:NSLineBreakByTruncatingHead];
        
        drawX = rect.origin.x + 3;
        drawY = rect.origin.y + rect.size.height * i / row - drawSize.height / 2;
        
        if (limit) {
            if (i == 0) {
                drawY = rect.origin.y;
            } else if (i == row) {
                drawY = rect.origin.y + rect.size.height * i / row - (drawSize.height + tempFloat - 1) / 2;
            }
        }
        
        if (inBackground) {
            CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor);
            CGContextFillRect(context, CGRectMake(drawX, drawY, drawSize.width, drawSize.height));
        }
        
        CGContextSetFillColorWithColor(context, KLinePriceCalColor.CGColor);
        
        [TradConfig drawString:tempString
                       atPoint:CGPointMake(drawX, drawY)
                      forWidth:rect.size.width
                      withFont:KLINE_FONT_Price
                   minFontSize:5
                actualFontSize:&tempFloat
                 lineBreakMode:NSLineBreakByTruncatingHead
            baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    }
}

- (void)drawPriceCalInRect:(CGRect)rect withRowNumber:(NSInteger)row context:(CGContextRef)context
{
    [self drawPriceCalInRect:rect withRowNumber:row context:context space:0 inBackground:NO boundLimit:false];
}

- (void)drawPriceCalInRect:(CGRect)rect withRowNumber:(NSInteger)row space:(CGFloat)space context:(CGContextRef)context
{
	[self drawPriceCalInRect:rect withRowNumber:row context:context space:space inBackground:NO boundLimit:true];
}

#define RECT_HEIGHT_OFFSET 0
#define RECT_Y_OFFSET 0.5
#define RECT_Y_COEFFICIENT 0
#define RECT_X_OFFSET 0.0

- (void)drawDayDatasInRect:(CGRect)rect context: (CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);

    for (NSInteger i = self.firstIndex; i < _baseIndex + 1; i++) {
        CGFloat height = rect.size.height;
        CGFloat originY = rect.origin.y;
        UIColor *targetColor = [self getCandleColor:i];
        HXKlineCompDayData *data = [self.klineDataArr objectAtIndex:i];
        double Dy = _upLimit - _downLimit;
        CGFloat openY = [self getYWithPrice:data.m_lOpenPrice inRect:rect];
        CGFloat closeY = originY + height * (_upLimit - data.m_lClosePrice) / Dy;
        CGFloat highY = originY + height * (_upLimit - data.m_lMaxPrice) / Dy;
        CGFloat lowY = originY + height * (_upLimit - data.m_lMinPrice) / Dy;
        CGFloat candleX = rect.origin.x + _leftOffset +
        (_pillarWidth + _pillarSpace) * (i - self.firstIndex) + 0.1;
        
        CGContextSetStrokeColorWithColor(context, targetColor.CGColor);
        CGContextSetFillColorWithColor(context, targetColor.CGColor);
        CGContextSetLineWidth(context, KLINE_PILLAR_WIDTH);
        CGContextMoveToPoint(context, candleX + _pillarWidth / 2 + RECT_X_OFFSET, highY);
        CGContextAddLineToPoint(context, candleX + _pillarWidth / 2 + RECT_X_OFFSET, lowY);
        
        CGRect rect = CGRectMake(candleX + 0.5, MIN(openY, closeY), _pillarWidth - 1, ABS(openY - closeY));
        CGContextStrokePath(context);
        CGContextStrokeRect(context, rect);
        CGContextFillRect(context, rect);
    }
    CGContextRestoreGState(context);

#ifdef KLINE_SHOWMAXMIN
    if (!self.hiddenMaxMin) {
        if (_maxIndex > 0 && _maxIndex<self.klineDataArr.count){
            HXKlineCompDayData *maxData = [self.klineDataArr objectAtIndex:_maxIndex];
            [self drawMaxMinCandleInRect:rect idx:_maxIndex price:maxData.m_lMaxPrice context:context];
        }
        if (_minIndex > 0 && _minIndex<self.klineDataArr.count){
            HXKlineCompDayData *minData = [self.klineDataArr objectAtIndex:_minIndex];
            [self drawMaxMinCandleInRect:rect idx:_minIndex price:minData.m_lMinPrice context:context];
        }
    }
#endif
}

- (void)drawMaxMinCandleInRect:(CGRect)rect idx:(NSInteger)idx price:(double)price context: (CGContextRef)context
{
    //画最高最低指示
    CGContextSetFillColorWithColor(context, self.maxMinPriceColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.maxMinPriceColor.CGColor);
    
    if (idx > -1) {
        NSString *tempString = [_stockInfo stringOfPrice:price];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:tempString attributes:@{NSFontAttributeName : KLINE_FONT_MAXMIN}];
#if TARGET_OS_IPHONE || TARGET_OS_TV
        CGRect drawRect = [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
#else
        CGRect drawRect = [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin];
#endif
        CGSize drawSize = CGSizeMake(drawRect.size.width, drawRect.size.height);
        
        double Dy = _upLimit - _downLimit;
        CGFloat drawY = rect.origin.y + rect.size.height * (_upLimit - price) / Dy;
        CGFloat drawX = rect.origin.x + _leftOffset + (_pillarWidth + _pillarSpace) * OFFSET_ON_SHOW(idx) + _pillarWidth / 2;
        drawX = MIN(MAX(drawX, rect.origin.x + 1), CGRectGetMaxX(rect) - 1);

        [self drawArrowInRect:rect point:CGPointMake(drawX, drawY) context:context];
        drawY = drawY - drawSize.height / 2 + 0.5;
        drawX = drawX < CGRectGetMidX(rect) ? (drawX + 11.5 + 0.5) : (drawX - drawSize.width - 11.5);
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX, drawY) withFont:KLINE_FONT_MAXMIN];
    }
}

- (void)drawArrowInRect:(CGRect)rect point:(CGPoint)point context: (CGContextRef)context
{
    CGFloat drawX = point.x;
    CGFloat drawY = point.y;
    CGFloat offset = 1.5;
    if (point.x > CGRectGetMidX(rect)) {
        drawX -= offset;
        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        CGContextAddLineToPoint(context, drawX - 10, drawY + 0.5);
        //CGContextMoveToPoint(context, drawX - 4, drawY - 4 + 0.5);
//        CGContextAddLineToPoint(context, drawX, drawY + 0.5);
//        CGContextAddLineToPoint(context, drawX - 4, drawY + 4 + 0.5);
        CGPoint sPoints[3];//坐标点
        sPoints[0] = CGPointMake(drawX, drawY + 0.5);//坐标1
        sPoints[1] = CGPointMake(drawX - 3, drawY + 3 + 0.5);//坐标2
        sPoints[2] = CGPointMake(drawX - 3, drawY - 3 + 0.5);//坐标3
        CGContextAddLines(context, sPoints, 3);//添加线
        CGContextClosePath(context);//封起来
        CGContextDrawPath(context, kCGPathFillStroke);
    } else {
        drawX += offset + 0.5;
        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        CGContextAddLineToPoint(context, drawX + 10, drawY + 0.5);
//        CGContextMoveToPoint(context, drawX + 4, drawY - 4 + 0.5);
//        CGContextAddLineToPoint(context, drawX, drawY + 0.5);
//        CGContextAddLineToPoint(context, drawX + 4, drawY + 4 + 0.5);
        CGPoint sPoints[3];//坐标点
        sPoints[0] = CGPointMake(drawX + 3, drawY + 3 + 0.5);//坐标1
        sPoints[1] = CGPointMake(drawX + 3, drawY - 3 + 0.5);//坐标2
        sPoints[2] = CGPointMake(drawX, drawY + 0.5);//坐标3
        CGContextAddLines(context, sPoints, 3);//添加线
        CGContextClosePath(context);//封起来
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    CGContextStrokePath(context);
}

- (UIColor *)getCandleColor:(NSInteger)index
{
    UIColor *targetColor = _riseColor;
    HXKlineCompDayData *stockCompDayData = [_klineDataArr objectAtIndex:index];

    //根据收盘价和开盘价以及昨收价确定柱子颜色
    if (stockCompDayData.m_lOpenPrice > stockCompDayData.m_lClosePrice) {
        targetColor = _fallColor;
    } else if (stockCompDayData.m_lOpenPrice < stockCompDayData.m_lClosePrice) {
        targetColor = _riseColor;
    } else {
        //今天收盘价和开盘价一样时，拿今天的收盘价和昨收价比较
        double preClosePrise = [self preCloseOfIndex:index];
        //今天收盘价大于昨收价，红色
        if (stockCompDayData.m_lClosePrice > preClosePrise) {
            targetColor = _riseColor;
        }
        else if (stockCompDayData.m_lClosePrice < preClosePrise) {
            //今天收盘价小于昨收价，绿色
            targetColor = _fallColor;
        } else {
            //今天收盘价等于昨收价，和上一天柱子颜色保持一致
        }
    }

    return targetColor;
}

- (void)drawMinPillarDayDatasInRect:(CGRect)rect context: (CGContextRef)context {
    
    CGContextSetStrokeColorWithColor(context, self.klineMinColor.CGColor);
    CGContextSetFillColorWithColor(context, self.klineMinColor.CGColor);
    
    NSInteger drawX, drawY;
    for (NSInteger i = self.firstIndex; i < _baseIndex + 1; i++) {
        
        HXKlineCompDayData *stockCompDayData = (HXKlineCompDayData *)[_klineDataArr objectAtIndex:i];
        
        drawX = rect.origin.x + _leftOffset + (_pillarWidth + _pillarSpace) * (i - self.firstIndex) + 0.1;
        
        if (stockCompDayData.m_lMaxPrice == 0) {
            if (stockCompDayData.m_lOpenPrice > stockCompDayData.m_lClosePrice) {
                stockCompDayData.m_lMaxPrice = stockCompDayData.m_lOpenPrice;
            } else {
                stockCompDayData.m_lMaxPrice = stockCompDayData.m_lClosePrice;
            }
        }
        if (stockCompDayData.m_lMinPrice == 0) {
            if (stockCompDayData.m_lOpenPrice > stockCompDayData.m_lClosePrice) {
                stockCompDayData.m_lMinPrice = stockCompDayData.m_lClosePrice;
            } else {
                stockCompDayData.m_lMinPrice = stockCompDayData.m_lOpenPrice;
            }
        }
        drawY = rect.origin.y + RECT_Y_OFFSET + (rect.size.height - RECT_HEIGHT_OFFSET) * (_upLimit - stockCompDayData.m_lMaxPrice) / (_upLimit - _downLimit) + RECT_Y_COEFFICIENT;
        
        if (drawY > rect.origin.y + rect.size.height - RECT_HEIGHT_OFFSET) {
            drawY = rect.origin.y + rect.size.height + RECT_Y_COEFFICIENT - RECT_HEIGHT_OFFSET;
        } else if (drawY < rect.origin.y + RECT_Y_OFFSET + RECT_Y_COEFFICIENT) {
            drawY = rect.origin.y + RECT_Y_OFFSET + RECT_Y_COEFFICIENT;
        }

        if (stockCompDayData.m_lOpenPrice > stockCompDayData.m_lClosePrice) {
            drawY = rect.origin.y + RECT_Y_OFFSET + (rect.size.height - RECT_HEIGHT_OFFSET) * (_upLimit - stockCompDayData.m_lOpenPrice) / (float)(_upLimit - _downLimit) + RECT_Y_COEFFICIENT;
        } else if (stockCompDayData.m_lOpenPrice < stockCompDayData.m_lClosePrice) {
            drawY = rect.origin.y + RECT_Y_OFFSET + (rect.size.height - RECT_HEIGHT_OFFSET) * (_upLimit - stockCompDayData.m_lClosePrice) / (float)(_upLimit - _downLimit) + RECT_Y_COEFFICIENT;
        } else {
            drawY = rect.origin.y + RECT_Y_OFFSET + (rect.size.height - RECT_HEIGHT_OFFSET) * (_upLimit - stockCompDayData.m_lClosePrice) / (float)(_upLimit - _downLimit) + RECT_Y_COEFFICIENT;
        }
        
        if (drawY > rect.origin.y + rect.size.height - RECT_HEIGHT_OFFSET) {
            drawY = rect.origin.y + rect.size.height + RECT_Y_COEFFICIENT - RECT_HEIGHT_OFFSET;
        } else if (drawY < rect.origin.y + RECT_Y_OFFSET + RECT_Y_COEFFICIENT) {
            drawY = rect.origin.y + RECT_Y_OFFSET + RECT_Y_COEFFICIENT;
        }
        
        if (i == self.firstIndex) {
            CGContextMoveToPoint(context, drawX + 0.5, drawY + 0.5);
        } else {
            CGContextAddLineToPoint(context, drawX + 0.5, drawY + 0.5);
        }
    }
    CGContextStrokePath(context);
}

- (void)drawMACurve:(float *)data offset:(NSInteger)offset inRect:(CGRect)rect context:(CGContextRef)context
{
    NSInteger drawX, drawY;
    NSInteger first = _baseIndex - _pillarNum + 1 > offset ? _baseIndex - _pillarNum + 1 : offset;
    drawX = rect.origin.x + _leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace) * OFFSET_ON_SHOW(first);
    drawY = rect.origin.y + 1 + (_upLimit - data[first]) / (_upLimit - _downLimit) * (rect.size.height - 3);
    
    if (drawY < (NSInteger)rect.origin.y + 1) {
        drawY = (NSInteger)rect.origin.y + 1;
    }
    CGContextMoveToPoint(context, drawX + 0.5, drawY + 0.5);
    
    FOR_I_ON_SHOW {
        if (i < first) {
            continue;
        }
        drawX = rect.origin.x + _leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace) * OFFSET_I_ON_SHOW;
        drawY = rect.origin.y + 1 + (_upLimit - data[i]) / (_upLimit - _downLimit) * (rect.size.height - 3);
        if (drawY < (NSInteger)rect.origin.y + 1) {
            drawY = (NSInteger)rect.origin.y + 1;
        }
        CGContextAddLineToPoint(context, drawX + 0.5, drawY + 0.5);
    }
    CGContextStrokePath(context);
}

- (void)drawMACurvesInRect:(CGRect)rect context:(CGContextRef)context
{
    if ([KLineIndicators shareObject].MA1Show)
        [self drawMACurvesInRect:rect color:_lineColor[1 - 1] data:_ma1Data context:context];
    if ([KLineIndicators shareObject].MA2Show)
        [self drawMACurvesInRect:rect color:_lineColor[2 - 1] data:_ma2Data context:context];
    if ([KLineIndicators shareObject].MA3Show)
        [self drawMACurvesInRect:rect color:_lineColor[3 - 1] data:_ma3Data context:context];
    if ([KLineIndicators shareObject].MA4Show)
        [self drawMACurvesInRect:rect color:_lineColor[4 - 1] data:_ma4Data context:context];
    if ([KLineIndicators shareObject].MA5Show)
        [self drawMACurvesInRect:rect color:_lineColor[5 - 1] data:_ma5Data context:context];
    if ([KLineIndicators shareObject].MA6Show)
        [self drawMACurvesInRect:rect color:_lineColor[6 - 1] data:_ma6Data context:context];
    if ([KLineIndicators shareObject].MA7Show)
        [self drawMACurvesInRect:rect color:_lineColor[7 - 1] data:_ma7Data context:context];
    if ([KLineIndicators shareObject].MA8Show)
        [self drawMACurvesInRect:rect color:_lineColor[8 - 1] data:_ma8Data context:context];
}

- (void)drawMACurvesInRect:(CGRect)rect color:(UIColor *)color data:(float *)data context:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    [self drawMACurve:data offset:0 inRect:rect context:context];
}

- (void)prepareDrawEMA
{
    FOR_I_ON_SHOW {
        if (_emaData[i].EMA1 > _upLimit) {
            _upLimit = _emaData[i].EMA1;
        }
        if (_emaData[i].EMA1 < _downLimit) {
            _downLimit = _emaData[i].EMA1;
        }
        if (_emaData[i].EMA2 > _upLimit) {
            _upLimit = _emaData[i].EMA2;
        }
        if (_emaData[i].EMA2 < _downLimit) {
            _downLimit = _emaData[i].EMA2;
        }
        if (_emaData[i].EMA3 > _upLimit) {
            _upLimit = _emaData[i].EMA3;
        }
        if (_emaData[i].EMA3 < _downLimit) {
            _downLimit = _emaData[i].EMA3;
        }
    }
}

- (void)drawEMAInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    if (!_stockInfo || _pointNum < 1) return;
    NSInteger drawX = rect.origin.x + 0.1 + 3;

    EMA_float ema = _focusIndex >= 0 ? _emaData[_focusIndex] : _emaData[_baseIndex];
    drawX += [self drawCenterInRect:rect header:@"EMA" idx:0 drawX:drawX param:[KLineIndicators shareObject].EMA1Param volume:ema.EMA1 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    drawX += [self drawCenterInRect:rect header:@"EMA" idx:1 drawX:drawX param:[KLineIndicators shareObject].EMA2Param volume:ema.EMA2 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    drawX += [self drawCenterInRect:rect header:@"EMA" idx:2 drawX:drawX param:[KLineIndicators shareObject].EMA3Param volume:ema.EMA3 context:context] + TrendKlineAreaQuotaTitleValuePadding;
}

- (void)drawEMAInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_emaData numOfLines:3 inRect:rect context:context];
}

- (void)prepareDrawTRIX
{
    if (self.klineDataArr.count < 2) {
        return;
    }
    NSInteger firstIndex = MAX(self.firstIndex, 1);
    _upLimit = _downLimit = _trixData[firstIndex].TRIX;

    for (NSInteger i = firstIndex; i < _baseIndex + 1; i++) {
        float TRIX = _trixData[i].TRIX;
        if (TRIX > _upLimit) {
            _upLimit = _trixData[i].TRIX;
        }
        if (TRIX < _downLimit) {
            _downLimit = _trixData[i].TRIX;
        }
    }
    double limit = MAX(ABS(_upLimit), ABS(_downLimit));
    _upLimit = limit;
    _downLimit = -limit;
}

- (void)drawTRIXInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    if (!_stockInfo || _pointNum < 1) return;
    NSInteger drawX = rect.origin.x + 0.1;
    
    TRIX_float trix = _focusIndex >= 0 ? _trixData[_focusIndex] : _trixData[_baseIndex];
    [self drawCenterInRect:rect header:@"TRIX" idx:0 drawX:drawX param:[KLineIndicators shareObject].TRIXParam volume:trix.TRIX context:context];
}

- (void)drawTRIXInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_trixData numOfLines:1 inRect:rect context:context offset:1];
}

- (void)drawTopRightTime:(CGRect)rect context:(CGContextRef)context
{
    if (self.baseIndex < 0 || self.baseIndex >= self.klineDataArr.count) return;

    UIFont *timeFont = KLINE_FONT_TIME;
    NSString *tempString = [self timeOfIndex:self.baseIndex];
    CGSize drawSize = [TradConfig sizeForString:tempString withFont:timeFont];

    CGContextSetFillColorWithColor(context, _timeColor.CGColor);
    [TradConfig drawString:tempString atPoint:CGPointMake(CGRectGetMaxX(rect) - drawSize.width - 3, rect.origin.y + 1) withFont:timeFont];
}

- (CGFloat)drawTimeCalInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
    
    UIFont *timeFont = KLINE_FONT_TIME;
    
    CGFloat fuQuanXPos = drawX;
    
    if (_baseIndex > -1) {
        CGContextSetStrokeColorWithColor(context, _timeColor.CGColor);
        CGContextSetFillColorWithColor(context, _timeColor.CGColor);
        if (_pointNum > _baseIndex) {
            tempString = [self timeOfIndex:self.firstIndex];
            drawSize = [TradConfig sizeForString:tempString withFont:timeFont];
            drawX = rect.origin.x + 1;
            drawY = rect.origin.y + (rect.size.height - drawSize.height)/4;
            
            if (drawX + drawSize.width > rect.origin.x + rect.size.width) {
                drawX = rect.origin.x + rect.size.width - drawSize.width;
            }
            [TradConfig drawString:tempString
                            atPoint:CGPointMake(drawX, drawY)
                           withFont:timeFont];
            
            fuQuanXPos = drawX + drawSize.width + 8;
        }
        else {
            fuQuanXPos = drawX;
        }
        
        NSInteger usedWidth = drawX + drawSize.width;
        if (self.lastIndex > self.firstIndex) {
            tempString = [self timeOfIndex:self.lastIndex];
            drawSize = [TradConfig sizeForString:tempString withFont:timeFont];
            drawX = rect.origin.x + rect.size.width * OFFSET_ON_SHOW(self.lastIndex) / _pillarNum;
            
            // bug7802 结束日期 都显示在末尾  过滤掉不显示
            drawX = rect.origin.x + rect.size.width - drawSize.width;
            
            drawY = rect.origin.y + (rect.size.height - drawSize.height)/4;
            if (drawX >= usedWidth) {
                if (drawX + drawSize.width > rect.origin.x + rect.size.width) {
                    drawX = rect.origin.x + rect.size.width - drawSize.width;
                }
                [TradConfig drawString:tempString
                                atPoint:CGPointMake(drawX, drawY)
                               withFont:timeFont];
            }
        }
    }
    
    return fuQuanXPos;
}

//十字线的交叉点
- (CGPoint)focusLineCenterInRect:(CGRect)rect klineHeight:(CGFloat)klineHeight
{
	if (_focusIndex < 0) return CGPointZero;

    CGPoint point = [self klineCenterIndex:_focusIndex inRect:rect klineHeight:klineHeight];
    point.y = self.focusIndexY;
    
    return point;
}

- (CGPoint)klineCenterIndex:(NSInteger)index inRect:(CGRect)rect klineHeight:(CGFloat)klineHeight
{
    if (index < 0 || index > _klineDataArr.count) {
        return CGPointZero;
    }
    
    HXKlineCompDayData *dayData = [_klineDataArr objectAtIndex:index];
    
    CGFloat pointX = rect.origin.x + _leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace) * OFFSET_ON_SHOW(index);
    CGFloat pointY = rect.origin.y + (klineHeight) * (_upLimit - dayData.m_lClosePrice) / (_upLimit - _downLimit);
    
    return CGPointMake(pointX, pointY);
}

- (void)drawFocusPriceLineInRect:(CGRect)rect context:(CGContextRef)context point:(CGPoint)point
{
    CGContextSaveGState(context);
    
    NSInteger drawX, drawY;
    NSInteger pointX, pointY; //焦点
    
    //EDLog(@"_focusIndex   %d", _focusIndex);
    if (_focusIndex > -1) {
        //竖线
        pointX = drawX = point.x;
        drawY = rect.origin.y + 1;
        CGContextMoveToPoint(context, drawX + 0.5, drawY);
        drawY = rect.origin.y + rect.size.height - 2;
        CGContextAddLineToPoint(context, drawX + 0.5, drawY);
        
		//横线
        pointY = drawY = point.y;
        drawX = rect.origin.x + 1;
        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        drawX = rect.origin.x + rect.size.width - 2;
        CGContextAddLineToPoint(context, drawX, drawY + 0.5);
        
        CGContextSetStrokeColorWithColor(context, self.compositeLineColor.CGColor);
        CGContextStrokePath(context);
        CGContextSetFillColorWithColor(context, self.compositeLineColor.CGColor);
    }
    
    CGContextRestoreGState(context);
}

- (void)drawLastLine:(NSInteger)index inRect:(CGRect)rect context:(CGContextRef)context point:(CGPoint)point
{
    NSInteger drawX = rect.origin.x + 1;
    NSInteger drawY = point.y;
    if (drawY > CGRectGetMaxY(rect)+20) {
        return;
    }
    
    CGContextSaveGState(context);
    UIColor *targetColor = [UIColor colorWithWhite:188/255.0 alpha:1]; //[self getCandleColor:index];
    CGContextMoveToPoint(context, drawX, drawY + 0.5);
    drawX = rect.origin.x + rect.size.width - 2;
    CGContextAddLineToPoint(context, drawX, drawY + 0.5);
    CGContextSetLineWidth(context, 1);
    CGContextSetLineDash(context, 0, (CGFloat[]){2, 3}, 2);
    
    CGContextSetStrokeColorWithColor(context, targetColor.CGColor);
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, targetColor.CGColor);

    CGContextRestoreGState(context);
}

- (CGFloat)getPrecentInPriceOnIndex:(NSInteger)index
{
    if (index < 0 || index > _klineDataArr.count)
        return 0;
    
    return (_upLimit - ((HXKlineCompDayData *) [_klineDataArr objectAtIndex:index]).m_lClosePrice) / (_upLimit - _downLimit);
}

- (void)drawLastPrice:(NSInteger)index inRect:(CGRect)rect context:(CGContextRef)context
{
    if (index < 0 || index >= _klineDataArr.count) {
        return;
    }
    UIColor *targetColor = veryLightColor; //[self getCandleColor:index];
    [self drawPriceIdex:index inRect:rect color:targetColor context:context];
}

- (void)drawPriceIdex:(NSInteger)index inRect:(CGRect)rect color:(UIColor *)color context:(CGContextRef)context
{
    if (index < 0 || index >= _klineDataArr.count) return;
    
    double price = ((HXKlineCompDayData *) [_klineDataArr objectAtIndex:index]).m_lClosePrice;
    [self drawPrice:price inRect:rect color:color context:context];
}

- (void)drawPrice:(double)price inRect:(CGRect)rect color:(UIColor *)color context:(CGContextRef)context
{        
    NSInteger drawX = rect.origin.x + 2;
    NSString *tempString = [_stockInfo stringOfPrice:price];
    CGSize    drawSize;
    CGFloat   tempFloat;
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    drawSize = [TradConfig sizeForString:tempString
                                withFont:KLINE_FONT_Price
                             minFontSize:8
                          actualFontSize:&tempFloat
                                forWidth:CGFLOAT_MAX
                           lineBreakMode:NSLineBreakByClipping];
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    // CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    if ([color isEqual: veryLightColor]){
        CGContextSetFillColorWithColor(context, [UIColor darkTextColor].CGColor);
    }
    else{
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
        
    
    [TradConfig drawString:tempString
                   atPoint:CGPointMake(drawX, CGRectGetMidY(rect) - drawSize.height / 2)
                  forWidth:rect.size.width - 2
                  withFont:KLINE_FONT_Price
               minFontSize:8
            actualFontSize:&tempFloat
             lineBreakMode:NSLineBreakByClipping
        baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    CGContextRestoreGState(context);
}

- (void)drawFocusTimeInRect:(CGRect)rect context:(CGContextRef)context
{
	NSInteger drawX, drawY;
	NSString *tempString;
	CGSize    drawSize;
	if (_focusIndex > -1 && _focusIndex < _pointNum) {
		tempString = [self timeOfIndex:_focusIndex];
        
		drawSize = [TradConfig sizeForString:tempString
                                     withFont:KLINE_FONT_TIME];
        
		drawX = rect.origin.x + _leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace) * OFFSET_ON_SHOW(_focusIndex) - drawSize.width / 2; //左宽7
		drawY = rect.origin.y + 0.1;
        
		CGFloat k = 3;
        
		if (drawX > rect.origin.x + rect.size.width - drawSize.width + 2 * k) {
			drawX = rect.origin.x + rect.size.width - drawSize.width - k;
		}
		if (drawX < rect.origin.x) {
			drawX = rect.origin.x;
		}

		CGContextSaveGState(context);
        
		CGContextSetFillColorWithColor(context, self.compositeBackgroundColor.CGColor);
		CGContextFillRect(context, CGRectMake(drawX - k, drawY, drawSize.width + 2 * k, drawSize.height));
		
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);

		CGRect stringRect = CGRectMake(drawX, drawY, drawSize.width, drawSize.height);

		[TradConfig drawString:tempString
                         inRect:stringRect
                       withFont:KLINE_FONT_TIME
                  lineBreakMode:NSLineBreakByCharWrapping
                      alignment:NSTextAlignmentCenter];
        
		CGContextRestoreGState(context);
	}
}

- (void)drawFocusVolumeInRect:(CGRect)rect context:(CGContextRef)context inBackgourn:(BOOL)inBackground
{
	NSInteger drawX, drawY;
	NSString *tempString;
	CGSize    drawSize;
	if (_focusIndex > -1 && _focusIndex < _pointNum) {

		CGFloat volume = ((HXKlineCompDayData *) [_klineDataArr objectAtIndex:_focusIndex]).m_lTotal;

		tempString = [_stockInfo stringOfVolume:volume withUnit:NO];
		drawSize = [TradConfig sizeForString:tempString withFont:KLINE_FONT_TIME];
		drawX = rect.origin.x;
		drawY = rect.origin.y + 0.1;

		CGContextSaveGState(context);

		if (inBackground) {
			CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor);
			CGContextFillRect(context, CGRectMake(drawX, drawY, drawSize.width, drawSize.height));
		}

		CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);

		CGRect stringRect = CGRectMake(drawX, drawY, drawSize.width, drawSize.height);

		[TradConfig drawString:tempString
                         inRect:stringRect
                       withFont:KLINE_FONT_TIME
                  lineBreakMode:NSLineBreakByCharWrapping
                      alignment:NSTextAlignmentCenter];
        
		CGContextRestoreGState(context);
	}
}


#pragma mark - deal money



- (void)drawDealMoneyChartInRect:(CGRect)rect context:(CGContextRef)context
{
    NSInteger drawX, drawY, height;
    FOR_I_ON_SHOW {
        HXKlineCompDayData *stockCompDayData = (HXKlineCompDayData *) [_klineDataArr objectAtIndex:i];
        drawX = rect.origin.x + _leftOffset + (_pillarWidth + _pillarSpace) * OFFSET_I_ON_SHOW;
        height = stockCompDayData.m_lMoney / _upLimit * (rect.size.height - 3) + 0.1; //柱形画法，共有3个线宽
        
        if (height > rect.size.height - 3) {
            height = rect.size.height - 3;
        }
        
        drawY = rect.origin.y + rect.size.height - 2;
        
        if (stockCompDayData.m_lClosePrice < stockCompDayData.m_lOpenPrice) {
            CGContextSetFillColorWithColor(context, _fallColor.CGColor);
            CGContextSetStrokeColorWithColor(context, _fallColor.CGColor);
        }
        else {
//            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);//空心柱
            CGContextSetFillColorWithColor(context, _riseColor.CGColor);
            CGContextSetStrokeColorWithColor(context, _riseColor.CGColor);
        }
        
        CGContextStrokeRect(context, CGRectMake(drawX + 0.5, drawY + 0.5, _pillarWidth - 1, -height));
        CGContextFillRect(context, CGRectMake(drawX + 0.5, drawY + 0.5, _pillarWidth - 1, -height));
    }
}


//Y坐标轴显示的最大成交额信息
- (void)drawDealMoneyCalInRect:(CGRect)rect
                 withRowNumber:(NSInteger)row
                       context:(CGContextRef)context
                  inBackground:(BOOL)inBackground
{
    if (_stockInfo == nil) {
        return;
    }

    NSInteger drawX, drawY;
    CGSize drawSize;
    CGFloat tempFloat;
    NSString *tempString;

    CGContextSaveGState(context);
    
    for (int i = 0; i < row; i++) {
        
        tempFloat = _upLimit - _upLimit * i / row; //成交额
        
        tempString = [_stockInfo stringOfAmount:tempFloat];

        drawSize = [TradConfig sizeForString:tempString
                                     withFont:KLINE_FONT_Price
                                  minFontSize:5
                               actualFontSize:&tempFloat
                                     forWidth:rect.size.width
                                lineBreakMode:NSLineBreakByTruncatingHead];

        drawX = rect.origin.x;

        if (i == 0) {
            drawY = rect.origin.y;
        }
        else {
            drawY = rect.origin.y + rect.size.height * i / row - drawSize.height / 2;
        }

        if (inBackground) {
            CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.4].CGColor);
            CGContextFillRect(context, CGRectMake(drawX, drawY, drawSize.width, drawSize.height));
        }

        CGContextSetFillColorWithColor(context, KLineChaTypeCalColor.CGColor);

        [TradConfig drawString:tempString
                        atPoint:CGPointMake(drawX, drawY)
                       forWidth:rect.size.width
                       withFont:KLINE_FONT_Price
                    minFontSize:5
                 actualFontSize:&tempFloat
                  lineBreakMode:NSLineBreakByTruncatingHead
             baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    }
    
    CGContextRestoreGState(context);
}

- (void)drawDealMoneyCalInRect:(CGRect)rect withRowNumber:(NSInteger)row context:(CGContextRef)context
{
    [self drawDealMoneyCalInRect:rect withRowNumber:row context:context inBackground:NO];
}

- (void)drawFocusDealMoneyInRect:(CGRect)rect context:(CGContextRef)context inBackgournd:(BOOL)inBackground
{
	NSInteger drawX, drawY;
	NSString *tempString;
	CGSize    drawSize;
	if (_focusIndex > -1 && _focusIndex < _pointNum) {

		CGFloat volume = ((HXKlineCompDayData *) [_klineDataArr objectAtIndex:_focusIndex]).m_lMoney;

		tempString = [_stockInfo stringOfVolume:volume withUnit:NO];
        
		drawSize = [TradConfig sizeForString:tempString withFont:KLINE_FONT_TIME];
        
		drawX = rect.origin.x;
		drawY = rect.origin.y + 0.1;

		CGContextSaveGState(context);

		if (inBackground) {
			CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor);
			CGContextFillRect(context, CGRectMake(drawX, drawY, drawSize.width, drawSize.height));
		}

		CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);

		CGRect stringRect = CGRectMake(drawX, drawY, drawSize.width, drawSize.height);

		[TradConfig drawString:tempString
                         inRect:stringRect
                       withFont:KLINE_FONT_TIME
                  lineBreakMode:NSLineBreakByCharWrapping
                      alignment:NSTextAlignmentCenter];
        
		CGContextRestoreGState(context);
	}
}

- (void)drawFocusDealMoneyInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawFocusDealMoneyInRect:rect context:context];
}


#pragma mark - draw volumn

//成交量柱子
- (void)drawVolumeChartInRect:(CGRect)rect context:(CGContextRef)context
{
    CGFloat drawX, drawY, height;
    
    UIColor *targetColor = _riseColor;
    
    FOR_I_ON_SHOW {
        HXKlineCompDayData *stockCompDayData = (HXKlineCompDayData *) [_klineDataArr objectAtIndex:i];
        
        drawX = rect.origin.x + _leftOffset + (_pillarWidth + _pillarSpace) * OFFSET_I_ON_SHOW;
        
        height = stockCompDayData.m_lTotal / _upLimit * (rect.size.height - 3) + 0.1; //柱形画法，共有3个线宽
        
        if (height > rect.size.height - 3) {
            height = rect.size.height - 3;
        }
        
        drawY = rect.origin.y + rect.size.height - 2;
        
        //根据收盘价和开盘价以及昨收价确定柱子颜色
        if (stockCompDayData.m_lClosePrice < stockCompDayData.m_lOpenPrice) {
            targetColor = _fallColor;
        }
        else if (stockCompDayData.m_lClosePrice > stockCompDayData.m_lOpenPrice) {
            targetColor = _riseColor;
        }
        else {
            //今天收盘价和开盘价一样时，拿今天的收盘价和昨收价比较
            double preClosePrise = [self preCloseOfIndex:i];
            
            //今天收盘价大于昨收价，红色
            if (stockCompDayData.m_lClosePrice > preClosePrise) {
                targetColor = _riseColor;
            }
            else if (stockCompDayData.m_lClosePrice < preClosePrise) {
                //今天收盘价小于昨收价，绿色
                targetColor = _fallColor;
            } else {
                //今天收盘价等于昨收价，和上一天柱子颜色保持一致
            }
        }
        
        CGContextSetStrokeColorWithColor(context, targetColor.CGColor);
        CGContextSetFillColorWithColor(context, targetColor.CGColor);//实心柱子
        
        CGContextStrokeRect(context, CGRectMake(drawX + 0.5, drawY + 0.5, _pillarWidth - 1, -height));
        CGContextFillRect(context, CGRectMake(drawX + 0.5, drawY + 0.5, _pillarWidth - 1, -height));
    }
}


- (void)drawCenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    if (!_stockInfo || _pointNum < 1) return;
    
    NSInteger drawX = rect.origin.x + 0.1;

    HXKlineCompDayData *klineData = (HXKlineCompDayData *) [_klineDataArr objectAtIndex:_baseIndex];
    VOLHS_float volhs = _volhsData[_baseIndex];
    if (_focusIndex >= 0) {
        volhs = _volhsData[_focusIndex];
        klineData = (HXKlineCompDayData *) [_klineDataArr objectAtIndex:_focusIndex ];
    }

    NSString *volume = [_stockInfo stringOfVolume:klineData.m_lTotal withUnit:YES];
    NSString *valueString = [NSString stringWithFormat:@"%@: %@", @"成交量", volume];
    CGSize drawSize = [TradConfig sizeForString:valueString withFont:KLINE_FONT_TIME];
    NSInteger drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
    CGContextSetFillColorWithColor(context, KLineChaTypeCalColor.CGColor);
    [TradConfig drawString:valueString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KLINE_FONT_TIME];
    drawX += drawSize.width + TrendKlineAreaQuotaTitleValuePadding;

    if ([KLineIndicators shareObject].VOLMA1Show)
        drawX += [self drawCenterInRect:rect header:@"MA" idx:0 drawX:drawX param:[KLineIndicators shareObject].VOLMA1Param volume:volhs.MAVOL1 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].VOLMA2Show)
        drawX += [self drawCenterInRect:rect header:@"MA" idx:1 drawX:drawX param:[KLineIndicators shareObject].VOLMA2Param volume:volhs.MAVOL2 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].VOLMA3Show)
        drawX += [self drawCenterInRect:rect header:@"MA" idx:2 drawX:drawX param:[KLineIndicators shareObject].VOLMA3Param volume:volhs.MAVOL3 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].VOLMA4Show)
        drawX += [self drawCenterInRect:rect header:@"MA" idx:3 drawX:drawX param:[KLineIndicators shareObject].VOLMA4Param volume:volhs.MAVOL4 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].VOLMA5Show)
        drawX += [self drawCenterInRect:rect header:@"MA" idx:4 drawX:drawX param:[KLineIndicators shareObject].VOLMA5Param volume:volhs.MAVOL5 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].VOLMA6Show)
        drawX += [self drawCenterInRect:rect header:@"MA" idx:5 drawX:drawX param:[KLineIndicators shareObject].VOLMA6Param volume:volhs.MAVOL6 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].VOLMA7Show)
        drawX += [self drawCenterInRect:rect header:@"MA" idx:6 drawX:drawX param:[KLineIndicators shareObject].VOLMA7Param volume:volhs.MAVOL7 context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].VOLMA8Show)
        drawX += [self drawCenterInRect:rect header:@"MA" idx:7 drawX:drawX param:[KLineIndicators shareObject].VOLMA8Param volume:volhs.MAVOL8 context:context] + TrendKlineAreaQuotaTitleValuePadding;
}

//中间画内容
- (CGFloat)drawCenterInRect:(CGRect)rect header:(NSString *)header idx:(NSInteger)idx drawX:(CGFloat)drawX param:(NSInteger)param volume:(float)volume context:(CGContextRef)context
{
    UIFont *volumeInfoFont = KlineIndexInfoFont;
    NSString *volumeStr = [_stockInfo stringOfVolume:volume withUnit:NO];
    NSString *mutableValueString = [NSString stringWithFormat:@"%@%ld:%@",header, param, volumeStr];

    CGContextSetFillColorWithColor(context, _lineColor[idx].CGColor);

    CGSize drawSize = [TradConfig sizeForString:mutableValueString withFont:volumeInfoFont];
    CGFloat drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
    if (drawX + drawSize.width > rect.size.width) {
        return rect.size.width;
    }
    [TradConfig drawString:mutableValueString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:volumeInfoFont];
    
    return drawSize.width;
}

//Y坐标轴显示的最大成交量信息
- (void)drawVolumeCalInRect:(CGRect)rect
              withRowNumber:(NSInteger)row
                    context:(CGContextRef)context
               inBackground:(BOOL)inBackground {
    if (_stockInfo == nil) {
        return;
    }
    
    NSInteger drawX, drawY;
    CGSize drawSize;
    CGFloat tempFloat;
    NSString *tempString;
    
    CGContextSaveGState(context);
    for (int i = 0; i < row; i++) {
        tempFloat = _upLimit - _upLimit * i / row; //已经是手数
        tempString = [_stockInfo stringOfVolume:tempFloat withUnit:NO];
        drawSize = [TradConfig sizeForString:tempString
                                     withFont:KLINE_FONT_Price
                                  minFontSize:5
                               actualFontSize:&tempFloat
                                     forWidth:rect.size.width
                                lineBreakMode:NSLineBreakByTruncatingHead];
        drawX = rect.origin.x;
        
        if (i == 0) {
            drawY = rect.origin.y; // + rect.size.height * i / row - (drawSize.height - tempFloat + 1)/2;
        } else {
            drawY = rect.origin.y + rect.size.height * i / row - drawSize.height / 2;
        }
        if (inBackground) {
            CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.4].CGColor);
            CGContextFillRect(context, CGRectMake(drawX, drawY, drawSize.width, drawSize.height));
        }
        CGContextSetFillColorWithColor(context, KLineChaTypeCalColor.CGColor);
        
        [TradConfig drawString:tempString
                        atPoint:CGPointMake(drawX, drawY)
                       forWidth:rect.size.width
                       withFont:KLINE_FONT_Price
                    minFontSize:5
                 actualFontSize:&tempFloat
                  lineBreakMode:NSLineBreakByTruncatingHead
             baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    }
    
    CGContextRestoreGState(context);
}

- (void)drawVolumeCalInRect:(CGRect)rect withRowNumber:(NSInteger)row context:(CGContextRef)context
{
	[self drawVolumeCalInRect:rect withRowNumber:row context:context inBackground:NO];
}


//绘制两根实线
- (void)drawVOLHSDataInRect:(CGRect)rect context:(CGContextRef)context
{
    CGContextSetLineDash(context, 0, NULL, 0); //恢复成实线
    NSInteger number = 8;
    if ([KLineIndicators shareObject].VOLMA1Show)
        [self drawData:_volhsData line:0 numOfLines:number inRect:rect context:context];
    if ([KLineIndicators shareObject].VOLMA2Show)
        [self drawData:_volhsData line:1 numOfLines:number inRect:rect context:context];
    if ([KLineIndicators shareObject].VOLMA3Show)
        [self drawData:_volhsData line:2 numOfLines:number inRect:rect context:context];
    if ([KLineIndicators shareObject].VOLMA4Show)
        [self drawData:_volhsData line:3 numOfLines:number inRect:rect context:context];
    if ([KLineIndicators shareObject].VOLMA5Show)
        [self drawData:_volhsData line:4 numOfLines:number inRect:rect context:context];
    if ([KLineIndicators shareObject].VOLMA6Show)
        [self drawData:_volhsData line:5 numOfLines:number inRect:rect context:context];
    if ([KLineIndicators shareObject].VOLMA7Show)
        [self drawData:_volhsData line:6 numOfLines:number inRect:rect context:context];
    if ([KLineIndicators shareObject].VOLMA8Show)
        [self drawData:_volhsData line:7 numOfLines:number inRect:rect context:context];
}

- (void)drawVolumeInIdxRect:(CGRect)rect context:(CGContextRef)context
{
    CGFloat dash[2] = {2.0, 2.0};
    
    NSInteger drawX, drawY, height;
    
    FOR_I_ON_SHOW {
        
        HXKlineCompDayData *stockCompDayData = (HXKlineCompDayData *) [_klineDataArr objectAtIndex:i];
        
        drawX = rect.origin.x + _leftOffset + (_pillarWidth + _pillarSpace) * OFFSET_I_ON_SHOW;
        
        if (i == _pointNum - 1 && _period == PERIOD_TYPE_DAY) { //只支持日k线
            
            height = _vvTotal / _upLimit * (rect.size.height - 3) + 0.1; //虚拟成交量高度
            if (height > rect.size.height - 3) {
                height = rect.size.height - 3;
            }
            
            drawY = rect.origin.y + rect.size.height - 2;
            
            if (_vvTotal == stockCompDayData.m_lTotal) {
                CGContextSetLineDash(context, 0, NULL, 0);
            }
            else {
                CGContextSetLineDash(context, 0, dash, 2);
            }
            
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
            CGContextStrokeRect(context, CGRectMake(drawX + 0.5, drawY + 0.5, _pillarWidth - 1, -height));
            CGContextFillRect(context, CGRectMake(drawX + 0.5, drawY + 0.5, _pillarWidth - 1, -height));
        }
        
        height = stockCompDayData.m_lTotal / _upLimit * (rect.size.height - 3) + 0.1; //柱形画法，共有3个线宽
        
        if (height > rect.size.height - 3) {
            height = rect.size.height - 3;
        }
        
        
        drawY = rect.origin.y + rect.size.height - 2;
        
        
        if (stockCompDayData.m_lClosePrice < stockCompDayData.m_lOpenPrice) {
            CGContextSetFillColorWithColor(context, _fallColor.CGColor);
            CGContextSetStrokeColorWithColor(context, _fallColor.CGColor);
        } else {
//            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);//空心柱
            CGContextSetFillColorWithColor(context, _riseColor.CGColor);
            CGContextSetStrokeColorWithColor(context, _riseColor.CGColor);
        }
        
        CGContextStrokeRect(context, CGRectMake(drawX + 0.5, drawY + 0.5, _pillarWidth - 1, -height));
        CGContextFillRect(context, CGRectMake(drawX + 0.5, drawY + 0.5, _pillarWidth - 1, -height));
    }
}

#pragma mark -

- (void)drawIdxCalInRect:(CGRect)rect withRowNumber:(NSInteger)row context:(CGContextRef)context
{
	NSInteger drawX, drawY;
	CGSize    drawSize;
	CGFloat   tempFloat;
	NSString *tempString;

	CGContextSetFillColorWithColor(context, KLinePriceCalColor.CGColor);

	for (int i = 0; i < row + 1; i++) {

		tempFloat = _upLimit - (_upLimit - _downLimit) * i / row;
		tempString = formarterLimitPrice_pkb(tempFloat);

		drawSize = [TradConfig sizeForString:tempString
                                     withFont:KLINE_FONT_Price
                                  minFontSize:5
                               actualFontSize:&tempFloat
                                     forWidth:rect.size.width
                                lineBreakMode:NSLineBreakByTruncatingHead];
		drawX = rect.origin.x + 0.5 + 1;

//        if (i == 0) {
//            drawY = rect.origin.y + rect.size.height * i / row - (drawSize.height - 0 + 1) / 2;
//        }
//        else if (i == row) {
//            drawY = rect.origin.y + rect.size.height * i / row - (drawSize.height + 0 - 1) / 2;
//        }
 //            drawY = rect.origin.y + rect.size.height * i / row - drawSize.height / 2;
//        }
        drawY = rect.origin.y + rect.size.height * i / row - drawSize.height / 2;

		[TradConfig drawString:tempString
                        atPoint:CGPointMake(drawX, drawY)
                       forWidth:rect.size.width
                       withFont:KLINE_FONT_Price
                    minFontSize:5
                 actualFontSize:&tempFloat
                  lineBreakMode:NSLineBreakByTruncatingHead
             baselineAdjustment:UIBaselineAdjustmentAlignCenters];
	}
}


#pragma mark - draw KDJ

- (void)drawKDJDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_kdjData numOfLines:3 inRect:rect context:context];
}

//K线图和量图中间显示的KDJ信息
- (void)drawKDJCenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
    for (int i = 0; i < 4; i++) {
		if (i == 0) {
			tempString = [NSString stringWithFormat:@"KDJ(%d,%d,%d)", [KLineIndicators shareObject].KDJkParam, [KLineIndicators shareObject].KDJdParam, [KLineIndicators shareObject].KDJrParam];
			CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
		}else if (i == 1) {
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat:@"K:%@",formatNumberWithDoubleAndDecimals( _kdjData[_focusIndex].K , 3)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat:@"K:%@",formatNumberWithDoubleAndDecimals(_kdjData[_baseIndex].K , 3)];
            }
            else {
                tempString = @"K:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[0].CGColor);
            
        } else if (i == 2) {
            
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat:@"D:%@",formatNumberWithDoubleAndDecimals(_kdjData[_focusIndex].D, 3)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat:@"D:%@",formatNumberWithDoubleAndDecimals( _kdjData[_baseIndex].D, 3)];
            }
            else {
                tempString = @"D:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[1].CGColor);
            
        } else {
            
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat:@"J:%@",formatNumberWithDoubleAndDecimals(_kdjData[_focusIndex].J, 3)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat:@"J:%@",formatNumberWithDoubleAndDecimals(_kdjData[_baseIndex].J, 3)];
            }
            else {
                tempString = @"J:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[2].CGColor);
        }
        
        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
        drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
    }
}




#pragma mark - draw MACD

// MACD绘制
- (void)drawMACDCenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
	NSInteger index = 0;
    if (_pointNum >= 1) {
         index = _baseIndex;
        if (_focusIndex >= 0 && _focusIndex <= _pointNum - 1) {
            index = _focusIndex;
        }
    }
    
    for (int i = 0; i < 4; i++) {
		if (i == 0) {
			tempString = [NSString stringWithFormat:@"MACD(%d,%d,%d)", [KLineIndicators shareObject].MACDsParam, [KLineIndicators shareObject].MACDlParam, [KLineIndicators shareObject].MACDaParam];
			CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
		}else if (i == 1) {
            if (index > -1) {
                tempString = [NSString stringWithFormat: @"DIFF:%@", formatterKlinePrice_pkb(_macdData[index].diff)];
            } else {
                tempString = @"DIFF:--";
            }
            CGContextSetFillColorWithColor(context, _lineColor[0].CGColor);
        } else if (i == 2) {
            if (index > -1) {
                tempString = [NSString stringWithFormat: @"DEA:%@", formatterKlinePrice_pkb(_macdData[index].dea)];
            } else {
                tempString = @"DEA:--";
            }
            CGContextSetFillColorWithColor(context, _lineColor[1].CGColor);
        } else if (i == 3) {
            if (index > -1) {
                tempString = [NSString stringWithFormat: @"MACD:%@", formatterKlinePrice_pkb(_macdData[index].macd)];
                if (_macdData[index].macd > 0) {
                    CGContextSetFillColorWithColor(context, _riseColor.CGColor);
                } else if (_macdData[index].macd < 0) {
                    CGContextSetFillColorWithColor(context, _fallColor.CGColor);
                } else {
                CGContextSetFillColorWithColor(context, _lineColor[2].CGColor);
                }
            } else {
                tempString = @"MACD:--";
                CGContextSetFillColorWithColor(context, _stableColor.CGColor);
            }
        }
        
        
        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
        drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
    }
}

- (void)drawMACDDataInRect:(CGRect)rect context:(CGContextRef)context
{
    CGContextSaveGState(context);
    NSInteger drawX, drawY;
    drawX = rect.origin.x + _leftOffset + _pillarWidth / 2;
    drawY = rect.origin.y + 1 + (_upLimit - _macdData[self.firstIndex].diff) / (_upLimit - _downLimit) * (rect.size.height - 3);
    if (drawY < (NSInteger)rect.origin.y + 1) {
        drawY = (NSInteger)rect.origin.y + 1;
    }
    CGContextMoveToPoint(context, drawX + 0.5, drawY + 0.5);
    FOR_I_ON_SHOW {
        drawX = rect.origin.x + _leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace) * OFFSET_I_ON_SHOW;
        drawY = rect.origin.y + 1 + (_upLimit - _macdData[i].diff) / (_upLimit - _downLimit) * (rect.size.height - 3);
        if (drawY < (NSInteger)rect.origin.y + 1) {
            drawY = (NSInteger)rect.origin.y + 1;
        }
        CGContextAddLineToPoint(context, drawX + 0.5, drawY + 0.5);
    }
    CGContextSetStrokeColorWithColor(context, _lineColor[0].CGColor);
    CGContextStrokePath(context);
    
    drawX = rect.origin.x + _leftOffset + _pillarWidth / 2;
    drawY = rect.origin.y + 1 + (_upLimit - _macdData[self.firstIndex].dea) / (_upLimit - _downLimit) * (rect.size.height - 3);
    if (drawY < (NSInteger)rect.origin.y + 1) {
        drawY = (NSInteger)rect.origin.y + 1;
    }
    CGContextMoveToPoint(context, drawX + 0.5, drawY + 0.5);
    FOR_I_ON_SHOW {
        drawX = rect.origin.x + _leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace) * OFFSET_I_ON_SHOW;
        drawY = rect.origin.y + 1 + (_upLimit - _macdData[i].dea) / (_upLimit - _downLimit) * (rect.size.height - 3);
        if (drawY < (NSInteger)rect.origin.y + 1) {
            drawY = (NSInteger)rect.origin.y + 1;
        }
         CGContextAddLineToPoint(context, drawX + 0.5, drawY + 0.5);
    }
    CGContextSetStrokeColorWithColor(context, _lineColor[1].CGColor);
    CGContextStrokePath(context);
    
    CGFloat rWidth = (_leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace))/2;
    FOR_I_ON_SHOW {
        if (_macdData[i].macd > 0) {
            CGContextSetFillColorWithColor(context, _riseColor.CGColor);
        }
        else if (_macdData[i].macd < 0) {
            CGContextSetFillColorWithColor(context, _fallColor.CGColor);
        }
        else {
            CGContextSetFillColorWithColor(context, _stableColor.CGColor);
        }
        
        drawX = rect.origin.x + _leftOffset + _pillarWidth / 2 + (_pillarWidth + _pillarSpace) * OFFSET_I_ON_SHOW;
        drawY = rect.origin.y + 1 + _upLimit / (_upLimit - _downLimit) * (rect.size.height - 3);
        CGFloat tmpY = drawY + 0.5;
        CGFloat tmpX = drawX;
        //CGContextMoveToPoint(context, drawX + 0.5, drawY);
        drawY = rect.origin.y + 1 + (_upLimit - _macdData[i].macd) / (_upLimit - _downLimit) * (rect.size.height - 3);
        if (drawY < (NSInteger)rect.origin.y + 1) {
            drawY = (NSInteger)rect.origin.y + 1;
        }
        //CGContextAddLineToPoint(context, drawX + 0.5, drawY);
        CGFloat rHeight = drawY - tmpY;
        CGRect rect = CGRectMake(tmpX-rWidth / 2, tmpY, rWidth, rHeight);
        if (drawY < tmpY){
            rHeight = -rHeight;
            rect = CGRectMake(drawX-rWidth / 2, drawY, rWidth, rHeight);
        }
        CGContextFillRect(context, rect);
        
    }
    CGContextRestoreGState(context);
}

#pragma mark - draw RSI

- (void)drawRSIDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_rsiData numOfLines:3 inRect:rect context:context];
}

// RSI
- (void)drawRSICenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
    for (int i = 0; i < 4; i++) {
		if (i == 0) {
			tempString = [NSString stringWithFormat:@"RSI(%d,%d,%d)", [KLineIndicators shareObject].RSI1Param, [KLineIndicators shareObject].RSI2Param, [KLineIndicators shareObject].RSI3Param];
			CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
		} else {
			if (_focusIndex > -1) {
				tempString = [NSString stringWithFormat:@"RSI%d:%@", i, formatterKlinePrice_pkb(_rsiData[_focusIndex].RSI[i - 1])];
			} else if (_pointNum > 0) {
				tempString = [NSString stringWithFormat:@"RSI%d:%@", i, formatterKlinePrice_pkb(_rsiData[_baseIndex].RSI[i - 1])];
			} else {
				tempString = [NSString stringWithFormat:@"RSI%d:--", i];
			}

			CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);
		}
        
        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
        drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
    }
}


#pragma mark - draw BOLL


- (void)drawBOLLDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_bollData numOfLines:3 inRect:rect context:context];
}


//BOLL
- (void)drawBOLLCenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1 + 3;
    for (int i = 0; i < 4; i++) {
        switch (i) {
			case 0:{
				tempString = [NSString stringWithFormat:@"BOLL(%d,%d)", [KLineIndicators shareObject].BOLLmaParam, [KLineIndicators shareObject].BOLLwParam];
				CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
			}
				break;
            case 1: {
                if (_focusIndex > -1) {
                    tempString = [NSString stringWithFormat:@"MID:%@", formatNumberWithDoubleAndDecimals(_bollData[_focusIndex].MB,3)];
                }
                else if (_pointNum > 0) {
                    tempString = [NSString stringWithFormat:@"MID:%@", formatNumberWithDoubleAndDecimals(_bollData[_baseIndex].MB,3)];
                }
                else {
                    tempString = @"MID:--";
                }
                
                CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);
                
                break;
            }
            case 2: {
                if (_focusIndex > -1) {
                    tempString = [NSString stringWithFormat:@"UPPER:%@", formatNumberWithDoubleAndDecimals(_bollData[_focusIndex].UP,3)];
                }
                else if (_pointNum > 0) {
                    tempString = [NSString stringWithFormat:@"UPPER:%@", formatNumberWithDoubleAndDecimals(_bollData[_baseIndex].UP,3)];
                }
                else {
                    tempString = @"UPPER:--";
                }
                
                CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);
                
                break;
            }
            case 3: {
                if (_focusIndex > -1) {
                    tempString = [NSString stringWithFormat:@"LOWER:%@", formatNumberWithDoubleAndDecimals(_bollData[_focusIndex].DN,3)];
                }
                else if (_pointNum > 0) {
                    tempString = [NSString stringWithFormat:@"LOWER:%@", formatNumberWithDoubleAndDecimals(_bollData[_baseIndex].DN,3)];
                }
                else {
                    tempString = @"LOWER:--";
                }
                
                CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);
                
                break;
            }
            default:
                break;
        }
        
        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
		drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
    }
}


#pragma mark - draw PSY

- (void)drawPSYDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_psyData numOfLines:2 inRect:rect context:context];
}


//PSY
- (void)drawPSYCenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
    for (int i = 0; i < 3; i++) {
		if (i == 0) {
			tempString = [NSString stringWithFormat:@"PSY(%d,%d)", [KLineIndicators shareObject].PSYnParam, [KLineIndicators shareObject].PSYmParam];
			CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
		} else if (i == 1) {
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat:@"PSY:%@", formatterKlinePrice_pkb(_psyData[_focusIndex].PSY)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat:@"PSY:%@", formatterKlinePrice_pkb(_psyData[_baseIndex].PSY)];
            }
            else {
                tempString = @"PSY:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[0].CGColor);
        }
        else {
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat:@"PSYMA:%@", formatterKlinePrice_pkb(_psyData[_focusIndex].PSYMA)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat:@"PSYMA:%@", formatterKlinePrice_pkb(_psyData[_baseIndex].PSYMA)];
            }
            else {
                tempString = @"PSYMA:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[1].CGColor);
        }
        
        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
        drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
    }
}


#pragma mark - draw DMI

- (void)drawDMIDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_dmiData numOfLines:4 inRect:rect context:context];
}


//DMI
- (void)drawDMICenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
    
    for (int i = 0; i < 5; i++) {
		if (i == 0){
			tempString = [NSString stringWithFormat:@"DMI(%d,%d)", [KLineIndicators shareObject].DMInParam, [KLineIndicators shareObject].DMImParam];
			CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
		} else if (i == 1) {
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat: @"PDI:%@", formatterKlinePrice_pkb(_dmiData[_focusIndex].PDI)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat: @"PDI:%@", formatterKlinePrice_pkb(_dmiData[_baseIndex].PDI)];
            }
            else {
                tempString = @"PDI:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[0].CGColor);
        } else if (i == 2) {
            
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat: @"MDI:%@", formatterKlinePrice_pkb(_dmiData[_focusIndex].MDI)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat: @"MDI:%@", formatterKlinePrice_pkb(_dmiData[_baseIndex].MDI)];
            }
            else {
                tempString = @"MDI:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[1].CGColor);
        }  else if (i == 3) {
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat: @"ADX:%@", formatterKlinePrice_pkb(_dmiData[_focusIndex].ADX)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat: @"ADX:%@", formatterKlinePrice_pkb(_dmiData[_baseIndex].ADX)];
            }
            else {
                tempString = @"ADX:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[2].CGColor);
        } else if (i == 4) {
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat: @"ADXR:%@", formatterKlinePrice_pkb(_dmiData[_focusIndex].ADXR)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat: @"ADXR:%@", formatterKlinePrice_pkb(_dmiData[_baseIndex].ADXR)];
            }
            else {
                tempString = @"ADXR:--";
            }
            
            CGContextSetFillColorWithColor(context, _lineColor[3].CGColor);
        }
        
        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
        drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
    }
}


#pragma mark - draw WR

- (void)drawWRDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_wrData numOfLines:2 inRect:rect context:context];
}


- (void)drawWRCenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
    drawY = rect.origin.y;
    
    for (int i = 0; i < 3; i++) {
        switch (i) {
			case 0:
				tempString = [NSString stringWithFormat:@"WR(%d,%d)", [KLineIndicators shareObject].WR1Param, [KLineIndicators shareObject].WR2Param];
				CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
				break;
            case 1:
                if (_focusIndex > -1) {
                    tempString = [NSString stringWithFormat:@"WR1:%@", formatterKlinePrice_pkb(_wrData[_focusIndex].W_R)];
                }
                else if (_pointNum > 0) {
                    tempString = [NSString stringWithFormat:@"WR1:%@", formatterKlinePrice_pkb(_wrData[_baseIndex].W_R)];
                }
                else {
                    tempString = @"WR:--";
                }
                
                CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);
                
                break;
                
            case 2:
                if (_focusIndex > -1) {
                    tempString = [NSString stringWithFormat:@"WR2:%@", formatterKlinePrice_pkb(_wrData[_focusIndex].W_R2)];
                }
                else if (_pointNum > 0) {
                    tempString = [NSString stringWithFormat:@"WR2:%@", formatterKlinePrice_pkb(_wrData[_baseIndex].W_R2)];
                }
                else {
                    tempString = @"WR:--";
                }
                
                CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);
                
                break;
                
            default:
                break;
        }
        
        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
		drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
    }
}


#pragma mark - draw ASI

- (void)drawASIDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_asiData numOfLines:2 inRect:rect context:context];
}

- (void)drawASICenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSArray * tempArray = [NSArray arrayWithObjects:@"ASI", @"ASI:", @"MASI:", nil];
    NSInteger drawX, drawY;
    CGSize    drawSize;
    NSString *tempString;
    drawX = rect.origin.x + 1;

    NSUInteger num = [tempArray count];
    
    float *floatData = (float *) _asiData;
    
	for (int i = 0; i < num; i++) {
		if (i == 0) {
			tempString = [NSString stringWithFormat:@"ASI(%d,%d,%d)", [KLineIndicators shareObject].BIAS1Param, [KLineIndicators shareObject].BIAS2Param, [KLineIndicators shareObject].BIAS3Param];
			CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
		} else {
			if (_focusIndex > -1) {
				tempString = [NSString stringWithFormat:@"%@%@", [tempArray objectAtIndex:i], formatterKlinePrice_pkb(floatData[_focusIndex * (num - 1) + i - 1])];
			}
			else if (_pointNum > 0) {
				tempString = [NSString stringWithFormat:@"%@%@", [tempArray objectAtIndex:i], formatterKlinePrice_pkb(floatData[(_baseIndex) * (num - 1) + i - 1])];
			}
			else {
				tempString = [NSString stringWithFormat:@"%@--", [tempArray objectAtIndex:i]];
			}
			CGContextSetFillColorWithColor(context, _lineColor[i - 1].CGColor);
		}

		drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
		drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;

		[TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
		if (drawSize.width > 0 ) {
			drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
		}
	}
}


#pragma mark - draw BIAS
- (void)drawBIASDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_biasData numOfLines:3 inRect:rect context:context];
}

- (void)drawBIASInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    
    NSArray *tempArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"BIAS(%d,%d,%d)", [KLineIndicators shareObject].BIAS1Param, [KLineIndicators shareObject].BIAS2Param, [KLineIndicators shareObject].BIAS3Param], @"BIAS1:", @"BIAS2:", @"BIAS3:", nil];
    [self drawCenterInfo:tempArray withData:_biasData inRect:rect context:context];
}

#pragma mark - draw VR
- (void)drawVRDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_vrData numOfLines:1 inRect:rect context:context];
}

- (void)drawVRInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSArray *tempArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"VR(%d)", [KLineIndicators shareObject].VRParam], @"VR:", nil];
    [self drawCenterInfo:tempArray withData:_vrData inRect:rect context:context];
}


#pragma mark - draw CCI

- (void)drawCCIDataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_cciData numOfLines:1 inRect:rect context:context];
}

- (void)drawCCICenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
    for (int i = 0; i < 2; i++) {
		if (i == 0) {
			tempString = [NSString stringWithFormat:@"CCI(%d)", [KLineIndicators shareObject].CCINParam];
			CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
		} else {
			if (_focusIndex > -1) {
				tempString = [NSString stringWithFormat:@"CCI:%@",  formatterKlinePrice_pkb(_cciData[_focusIndex].CCI)];
			} else if (_pointNum > 0) {
				tempString = [NSString stringWithFormat:@"CCI:%@",  formatterKlinePrice_pkb(_cciData[_baseIndex].CCI)];
			} else {
				tempString = [NSString stringWithFormat:@"CCI:--"];
			}

			CGContextSetFillColorWithColor(context, _lineColor[0].CGColor);
		}

		drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
		drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;

		[TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
		drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
    }
}

#pragma mark - draw DMA

- (void)drawDMADataInRect:(CGRect)rect context:(CGContextRef)context
{
    [self drawData:_dmaData numOfLines:2 inRect:rect context:context];
}

//DMA
- (void)drawDMACenterInfoInRect:(CGRect)rect context:(CGContextRef)context
{
    NSString *tempString;
    CGSize    drawSize;
    NSInteger drawX, drawY;
    drawX = rect.origin.x + 1;
    for (int i = 0; i < 3; i++) {
		if (i == 0) {
			tempString = [NSString stringWithFormat:@"DMA(%d,%d,%d)", [KLineIndicators shareObject].DMAshortMaParam, [KLineIndicators shareObject].DMAlongMaParam, [KLineIndicators shareObject].DMAdddMaParam];
			CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
		} else if (i == 1) {
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat:@"DDD:%@", formatterKlinePrice_pkb(_dmaData[_focusIndex].DDD)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat:@"DDD:%@", formatterKlinePrice_pkb(_dmaData[_baseIndex].DDD)];
            }
            else {
                tempString = @"DDD:--";
            }
            CGContextSetFillColorWithColor(context, _lineColor[0].CGColor);
        } else {
            if (_focusIndex > -1) {
                tempString = [NSString stringWithFormat:@"AMA:%@", formatterKlinePrice_pkb(_dmaData[_focusIndex].AMA)];
            }
            else if (_pointNum > 0) {
                tempString = [NSString stringWithFormat:@"AMA:%@", formatterKlinePrice_pkb(_dmaData[_baseIndex].AMA)];
            }
            else {
                tempString = @"AMA:--";
            }
            CGContextSetFillColorWithColor(context, _lineColor[1].CGColor);
        }
        
        drawSize = [TradConfig sizeForString:tempString withFont:KlineIndexInfoFont];
        drawY = rect.origin.y + (rect.size.height - drawSize.height) / 2;
        
        [TradConfig drawString:tempString atPoint:CGPointMake(drawX - 0.5, drawY) withFont:KlineIndexInfoFont];
        drawX = drawX + drawSize.width + TrendKlineAreaQuotaTitleValuePadding;
        
    }
}


#pragma mark - draw Data

- (void)drawMAInfoInRect:(CGRect)rect context:(CGContextRef)context screenIsPortrait:(BOOL)isPortrait
{
    NSInteger drawX = rect.origin.x + 1;
    
    NSString *title = @"均线";
    UIFont *infoFont = KLINE_FONT_TIME;
    CGFloat tempFloat = 0;
    CGSize drawSize = [TradConfig sizeForString:title
                                       withFont:infoFont
                                    minFontSize:5
                                 actualFontSize:&tempFloat
                                       forWidth:200
                                  lineBreakMode:NSLineBreakByTruncatingHead];
    CGContextSetFillColorWithColor(context, KLineChaTypeCalColor.CGColor);
    [TradConfig drawString:title
                   atPoint:CGPointMake(drawX, rect.origin.y + (rect.size.height - drawSize.height)/2)
                  forWidth:200
                  withFont:infoFont
               minFontSize:5
            actualFontSize:&tempFloat
             lineBreakMode:NSLineBreakByTruncatingHead
        baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    drawX += drawSize.width + 4;
    
    if ([KLineIndicators shareObject].MA1Show)
        drawX += [self drawMAInfoInRect:rect index:1 drawX:drawX data:_ma1Data param:(NSInteger)[KLineIndicators shareObject].MA1Param context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].MA2Show)
        drawX += [self drawMAInfoInRect:rect index:2 drawX:drawX data:_ma2Data param:(NSInteger)[KLineIndicators shareObject].MA2Param context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].MA3Show)
        drawX += [self drawMAInfoInRect:rect index:3 drawX:drawX data:_ma3Data param:(NSInteger)[KLineIndicators shareObject].MA3Param context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].MA4Show)
        drawX += [self drawMAInfoInRect:rect index:4 drawX:drawX data:_ma4Data param:(NSInteger)[KLineIndicators shareObject].MA4Param context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].MA5Show)
        drawX += [self drawMAInfoInRect:rect index:5 drawX:drawX data:_ma5Data param:(NSInteger)[KLineIndicators shareObject].MA5Param context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].MA6Show)
        drawX += [self drawMAInfoInRect:rect index:6 drawX:drawX data:_ma6Data param:(NSInteger)[KLineIndicators shareObject].MA6Param context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].MA7Show)
        drawX += [self drawMAInfoInRect:rect index:7 drawX:drawX data:_ma7Data param:(NSInteger)[KLineIndicators shareObject].MA7Param context:context] + TrendKlineAreaQuotaTitleValuePadding;
    if ([KLineIndicators shareObject].MA8Show)
        drawX += [self drawMAInfoInRect:rect index:8 drawX:drawX data:_ma8Data param:(NSInteger)[KLineIndicators shareObject].MA8Param context:context] + TrendKlineAreaQuotaTitleValuePadding;
}

- (CGFloat)drawMAInfoInRect:(CGRect)rect index:(NSInteger)index drawX:(CGFloat)drawX data:(float *)data param:(NSInteger)param context:(CGContextRef)context
{
    UIFont *infoFont = KlineIndexInfoFont;
    NSString *maInfoString = [NSString stringWithFormat:@"MA%ld:--", (long)param];
    if (_focusIndex > -1) {
        if (_focusIndex >= param - 1) {
            maInfoString = [NSString stringWithFormat:@"MA%ld:%@", (long)param, [_stockInfo stringOfPrice:data[_focusIndex]]];
        }
        else {
            maInfoString = [NSString stringWithFormat:@"MA%ld:--", (long)param];
        }
    }
    else if (_pointNum > 0) {
        maInfoString = [NSString stringWithFormat:@"MA%ld:%@", (long)param, [_stockInfo stringOfPrice:data[_baseIndex]]];
    }
    CGContextSetFillColorWithColor(context, _lineColor[index - 1].CGColor);
    CGFloat tempFloat = 0;
    CGSize drawSize = [TradConfig sizeForString:maInfoString
                                       withFont:infoFont
                                    minFontSize:5
                                 actualFontSize:&tempFloat
                                       forWidth:200
                                  lineBreakMode:NSLineBreakByTruncatingHead];
    if (drawX + drawSize.width > rect.size.width) {
        return rect.size.width;
    }
    
    [TradConfig drawString:maInfoString
                   atPoint:CGPointMake(drawX, rect.origin.y + (rect.size.height - drawSize.height)/2)
                  forWidth:200
                  withFont:infoFont
               minFontSize:5
            actualFontSize:&tempFloat
             lineBreakMode:NSLineBreakByTruncatingHead
        baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    return drawSize.width;
}

- (void)drawFocusCandleDotInRect:(CGRect)rect context:(CGContextRef)context
{
    
}

- (void)drawCandleDotInRect:(CGRect)rect context:(CGContextRef)context
{
    if (_focusIndex >= 0) {
        [self drawCandleDotIdx:_focusIndex inRect:rect context:context];
    } else {
        [self drawCandleDotIdx:_baseIndex inRect:rect context:context];
    }
}

- (void)drawCandleDotIdx:(NSInteger)idx inRect:(CGRect)rect context:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, KLineCandInfoColor.CGColor);
    CGContextFillRect(context, CGRectMake(rect.origin.x - 50, rect.origin.y, rect.size.width + 200, rect.size.height));

    //跟昨收比较计算涨跌幅
	HXKlineCompDayData *dayData = [_klineDataArr objectAtIndex:idx];
    HXKlineCompDayData * yData = idx > 0 ? [_klineDataArr objectAtIndex:idx - 1] : nil;
    CGFloat percent = yData ? (CGFloat)(dayData.m_lClosePrice - yData.m_lClosePrice) / (CGFloat) yData.m_lClosePrice : 0;

    NSString *open = @"开";
    NSString *high = @"高";
    NSString *low = @"低";
    NSString *close = @"收";
    NSString *change = @"幅";
	NSString *openPriceStr = [NSString stringWithFormat:@"%@ %@", open,[self.stockInfo stringOfPrice:dayData.m_lOpenPrice]];
	NSString *maxStr = [NSString stringWithFormat:@"%@ %@",high, [self.stockInfo stringOfPrice:dayData.m_lMaxPrice ]];
	NSString *minStr = [NSString stringWithFormat:@"%@ %@",low,[self.stockInfo stringOfPrice:dayData.m_lMinPrice ]];
	NSString *closePriceStr = [NSString stringWithFormat:@"%@ %@",close,[self.stockInfo stringOfPrice:dayData.m_lClosePrice ]];
	NSString *percentStr = [NSString stringWithFormat:@"%@ %@%.2f%%",change,percent > 0 ? @"+" : @"",percent * 100];
    NSString *string = [NSString stringWithFormat:@"%@  %@  %@  %@  %@", openPriceStr, maxStr, minStr, closePriceStr, percentStr];

    UIFont *infoFont = KlineIndexInfoFont;
	CGFloat space = 2;
    CGFloat drawX = rect.origin.x + space;
    CGFloat tempFloat = 0;
    CGSize drawSize = [TradConfig sizeForString:string
                                       withFont:infoFont
                                    minFontSize:5
                                 actualFontSize:&tempFloat
                                       forWidth:rect.size.width
                                  lineBreakMode:NSLineBreakByTruncatingHead];
    CGContextSetFillColorWithColor(context, KLineChaTypeParamColor.CGColor);
    [TradConfig drawString:string
                   atPoint:CGPointMake(drawX, rect.origin.y + (rect.size.height - drawSize.height) / 2)
                  forWidth:rect.size.width
                  withFont:KLINE_FONT_Price
               minFontSize:5
            actualFontSize:&tempFloat
             lineBreakMode:NSLineBreakByTruncatingHead
        baselineAdjustment:UIBaselineAdjustmentAlignCenters];


	CGContextSaveGState(context);
}

- (CGFloat)getYWithPrice:(double)price inRect:(CGRect)rect
{
    double Dy = _upLimit - _downLimit;
    CGFloat y = rect.origin.y + rect.size.height * (_upLimit - price) / Dy;
    
    return y;
}

@end

