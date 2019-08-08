//
//  KlineDataPack+Private.h
//  KLine
//
//  Created by Violet on 2017/10/7.
//  Copyright © 2017年 Violet. All rights reserved.
//

#import "HXKlineDataPack.h"

@interface HXKlineDataPack (Private)

// 设置日k 月k
- (void)setPeriod:(PERIOD_TYPE)period;

- (void)drawPrice:(double)price inRect:(CGRect)rect color:(UIColor *)color context:(CGContextRef)context;
- (CGPoint)focusLineCenterInRect:(CGRect)rect klineHeight:(CGFloat)klineHeight;
//获取当前位置蜡烛的中心点
- (CGPoint)klineCenterIndex:(NSInteger)index inRect:(CGRect)rect klineHeight:(CGFloat)klineHeight;
- (CGFloat)getPrecentInPriceOnIndex:(NSInteger)index;//获取当前蜡烛占比
- (void)drawLastPrice:(NSInteger)index inRect:(CGRect)rect context:(CGContextRef)context;//画价格
- (void)drawLastLine:(NSInteger)index inRect:(CGRect)rect context:(CGContextRef)context point:(CGPoint)point;//画横线
- (void)drawCandleDotInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawTopRightTime:(CGRect)rect context:(CGContextRef)context;//右上角时间

- (void)prepareDrawPriceWitfFlag: (BOOL) flag;
- (void)prepareDrawPrice;
- (void)drawDayDatasInRect:(CGRect)rect context: (CGContextRef)context;
- (void)drawMACurvesInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawMAInfoInRect:(CGRect)rect context:(CGContextRef)context screenIsPortrait:(BOOL)isPortrait;
- (void)drawMinPillarDayDatasInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawPriceCalInRect:(CGRect)rect withRowNumber:(NSInteger)row space:(CGFloat)space context:(CGContextRef)context;
- (void)drawPriceCalInRect:(CGRect)rect withRowNumber:(NSInteger)row context:(CGContextRef)context;
- (void)drawTimeCalInRect:(CGRect)rect context:(CGContextRef)context;
//十字线 point由
//获取十字线价格在价格列表的比例
- (void)drawFocusPriceLineInRect:(CGRect)rect context:(CGContextRef)context point:(CGPoint)point;
- (void)drawFocusTimeInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawFocusCandleDotInRect:(CGRect)rect context:(CGContextRef)context;

//成交量
- (void)prepareDrawVOLHS;
- (void)drawVolumeChartInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawVOLHSDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawCenterInfoInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawVolumeCalInRect:(CGRect)rect withRowNumber:(NSInteger)row context:(CGContextRef)context;

- (void)prepareDrawDealMoneyHS;
- (void)drawDealMoneyChartInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawDealMoneyCalInRect:(CGRect)rect withRowNumber:(NSInteger)row context:(CGContextRef)context;

- (void)prepareDrawMACD;
- (void)drawMACDDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawMACDCenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawKDJ;
- (void)drawKDJDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawKDJCenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawRSI;
- (void)drawRSIDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawRSICenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawBOLL;
- (void)drawBOLLDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawBOLLCenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawPSY;
- (void)drawPSYDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawPSYCenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawDMI;
- (void)drawDMIDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawDMICenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawWR;
- (void)drawWRDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawWRCenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawASI;
- (void)drawASIDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawASICenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawDMA;
- (void)drawDMADataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawDMACenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawBIAS;
- (void)drawBIASDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawBIASInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawVR;
- (void)drawVRDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawVRInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawCCI;
- (void)drawCCIDataInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawCCICenterInfoInRect:(CGRect)rect context:(CGContextRef)context;

- (void)drawIdxCalInRect:(CGRect)rect withRowNumber:(NSInteger)row context:(CGContextRef)context;

- (void)prepareDrawEMA;
- (void)drawEMAInfoInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawEMAInRect:(CGRect)rect context:(CGContextRef)context;

- (void)prepareDrawTRIX;
- (void)drawTRIXInfoInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawTRIXInRect:(CGRect)rect context:(CGContextRef)context;

@end
