//
//  KlineHorizontalView.m
//  KLine
//
//  Created by Violet on 2017/10/7.
//  Copyright © 2017年 Violet. All rights reserved.
//

#import "KlineHorizontalView.h"
#import "HXKlineUtils.h"
#import "DateKit.h"
#import "ColorKit.h"
#import "NumberKit.h"
#import "UIView+Size.h"
#import "NSString+Size.h"
#import "TradConfig.h"
#import "StockInfo.h"
#import "KlinePrams.h"
#import "KlineDataPack+Private.h"
#import "TradConfig.h"

#define EDLog NSLog
#define ViewPanBackLeftSpace 30
#define KLINE_DISTANCE_ERROR 1200 //距离的平方
#define KLINE_MOVE_ERROR 20

#define WindowWidth CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds)
#define WindowHeight CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds)

#if TARGET_OS_IPHONE || TARGET_OS_TV
@interface KlineHorizontalView () <UIGestureRecognizerDelegate>
#else
@interface KlineHorizontalView ()
#endif
{
    double _lastDistance;  //不开方
    CGPoint _beginPoint;   //按下点
    CGPoint _endPoint;     //弹起点
	CGPoint _lastPanPoint; //上次拖动的点
    NSMutableDictionary *_dicPoint;
    
    CGFloat _priceW;
    CGFloat _timingH;
    CGFloat _margin;
    CGFloat _volumnH;
    CGFloat _mainIndicator;     //主图指标
    CGFloat _centerInfoHeight;  //成交量信息高度
    CGFloat _maInfoH;
    CGFloat _klineHeight;       //K线图边框的高度
    CGFloat _klineWidth;        //K线图边框的宽度
    CGFloat _tapResponseTopOriginY;      // 主图指标点击切换响应区域的最小Y
    CGFloat _tapResponseBottomOriginY;   // 副图指标点击切换响应区域的最小Y
}

@property (nonatomic, strong) HXKlineDataPack *klineDataPack;
@property (nonatomic, strong) NSMutableArray *arrayPoint;
@property (assign, nonatomic) BOOL isPanBacking;
@property (assign, nonatomic) BOOL isPanFocusing;//拖动十字线
@property (assign, nonatomic) CGPoint focusCenter;
@property (assign, nonatomic) BOOL canMove;
@end

@implementation KlineHorizontalView

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDraw) name: @"needRefreshKline" object:nil];
    _boundColor = KLineBoundLineColor;
    _boundColorVer = KLineBoundLineColorVer;
    _infoBlackColor = [UIColor clearColor];
    _thinLineColor = [UIColor colorWithWhite: 153/255.0 alpha: 0.15];
    _flatLineColor = [UIColor colorWithWhite: 153/255.0 alpha: 0.15];
    
    _lastPanPoint = CGPointZero;
    _arrayPoint = [[NSMutableArray alloc] init];
    
    _priceW = 0;
    _timingH = KLINE_HORIZONTAL_TIMEHEIGHT;
    _centerInfoHeight = KLINE_HORIZONTAL_VOLUMEINFOHEIGHT;
    _margin = 10;
    _maInfoH = 24;
    
#if TARGET_OS_IPHONE || TARGET_OS_TV
    self.backgroundColor = [UIColor clearColor];

    [self addiOSGesture];
#else
    [self addOSXEvent];
#endif
}

#if TARGET_OS_IPHONE || TARGET_OS_TV
#else
- (void)setNeedsDisplay
{
    [self setNeedsDisplay:true];
}
- (BOOL)isFlipped
{
    return true;
}
#endif

#pragma mark - ***** touches

- (void)addiOSGesture
{
    //轻点手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    //拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [panGesture setMaximumNumberOfTouches:1];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPressGesture.delegate = self;
    [self addGestureRecognizer: longPressGesture];
    
    //缩放手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
}

//开始进行手势识别时调用的方法，返回NO则结束识别，不再触发手势，用处：可以在控件指定的位置使用手势识别
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    EDLog(@"-------- %s", __func__);
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        return true;
    
    CGPoint point = [gestureRecognizer locationInView:self];
    if (point.x <= _priceW + _margin  ||
        point.y <= _maInfoH) {
        return NO;
    }
    
    return true;
}

//是否支持多手势触发，返回YES，则可以多个手势一起触发方法，返回NO则为互斥
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    EDLog(@"-------- %s", __func__);
    if (self.klineDataPack.focusIndex == -1)
        return true;
    //return self.klineDataPack.focusIndex == -1;
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (id)gestureRecognizer;
        CGPoint point = [panGesture locationInView:self];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        CGPoint windowPoint = [self convertPoint:point toView:keyWindow];

        if (windowPoint.x < ViewPanBackLeftSpace) {
            self.isPanBacking = true;
            return true;
        }

        if (self.klineDataPack.focusIndex >= 0 && ABS(self.focusCenter.x - point.x) < KlineViewPanFocusSpace) {
            return false;
        }
        CGPoint translation = [panGesture translationInView:self];
        if (translation.x > 0) {
            if (self.klineDataPack.firstIndex == 0) {
                if ([self.delegate respondsToSelector:@selector(requestKlineHistoryData)]) {
                    return ![self.delegate requestKlineHistoryData];
                } else {
                    return true;
                }
            }
        } else {
            return self.klineDataPack.lastIndex == self.klineDataPack.pointNum - 1;
        }
    }

    return false;
}

#pragma mark - gesture recognizer

- (void)pinchAction:(UIPinchGestureRecognizer *)pinchGesture
{
    EDLog(@"-------- %s", __func__);
	static CGFloat began_pillarWidth;
    static NSInteger centerIdx;
	switch (pinchGesture.state) {
		case UIGestureRecognizerStateBegan: {
			began_pillarWidth = self.klineDataPack.pillarWidth;
            centerIdx = [self klineIndexOnPoint:CGPointMake(_klineWidth / 2, 50)];
		} break;
		case UIGestureRecognizerStateChanged: {
			// NSInteger pillarWidth = began_pillarWidth * powf(pinchGesture.scale, 2.6);
            // pillarWidth = pillarWidth > 4? 4: pillarWidth;
            CGFloat pillarWidth = began_pillarWidth * powf(pinchGesture.scale, 2.6);
            CGFloat tmp = (int)(pillarWidth*2/2)+0.5;
            pillarWidth = tmp;
            // NSLog(@"pinchAction: %lf, %lf", pillarWidth, tmp);
            
			pillarWidth = MAX(MIN(pillarWidth, KLINE_PILLAR_MAXWIDTH), KLINE_PILLAR_MINWIDTH);
			if (self.klineDataPack.pillarWidth != pillarWidth) {
				self.klineDataPack.pillarWidth = pillarWidth;
                self.klineDataPack.baseIndex = MIN(MAX(centerIdx + (_klineWidth) / 2 / (self.klineDataPack.pillarWidth + self.klineDataPack.pillarSpace), 0), self.klineDataPack.pointNum - 1);
				[self setNeedsDisplay];
			}
            [self hideCrossLine];
		}
			break;
		default:
			break;
	}
}

- (void)panAction:(UIPanGestureRecognizer *)panGesture
{
    // EDLog(@"-------- %s", __func__);
    NSNotification *notification =[NSNotification notificationWithName:@"needHiddenSelectViewOfTrendCell" object:nil userInfo: nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    if (self.isPanBacking) {
        if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
            self.isPanBacking = false;
        return;
    }
    
    CGPoint translationPoint = [panGesture translationInView:self];

    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _lastPanPoint = translationPoint;
            self.klineDataPack.focusIndexTmp = self.klineDataPack.focusIndex;
            CGPoint point = [panGesture locationInView:self];
            self.isPanFocusing = self.klineDataPack.focusIndex >= 0 && ABS(self.focusCenter.x - point.x) < KlineViewPanFocusSpace;
        } break;
            
        case UIGestureRecognizerStateChanged: {
            CGFloat space = translationPoint.x - _lastPanPoint.x;
            
            int move = space / (self.klineDataPack.pillarWidth + 1);
            if (move == 0) {
                if (self.klineDataPack.focusIndex >= 0) {
                    CGPoint point = [panGesture locationInView:self];
                    self.klineDataPack.focusIndexY = point.y;
                    [self setNeedsDisplay];
                }
                return;
            }
            
            if (!self.isPanFocusing) {
                [self hideCrossLine];
                
                NSInteger baseIndex = self.klineDataPack.baseIndex - move;
                // NSLog(@"panGesturepanGesture %ld %d %ld",baseIndex, self.klineDataPack.pointNum, self.klineDataPack.pillarNum);
                if (baseIndex > self.klineDataPack.pointNum - 1 || baseIndex < self.klineDataPack.pillarNum - 1) {
                    // EDLog(@"panGesturepanGestureERR %ld %d %ld",baseIndex, self.klineDataPack.pointNum, self.klineDataPack.pillarNum);
                    _lastPanPoint = translationPoint;
                    return;
                }
                if (baseIndex < self.klineDataPack.pillarNum + 40) {
                    if (_delegate && [_delegate respondsToSelector:@selector(requestKlineHistoryData)]) {
                        [_delegate requestKlineHistoryData];
                    }
                }
                self.klineDataPack.baseIndex = (int)baseIndex;  //向左加载*条数据
            } else {
                NSInteger focusIndex = self.klineDataPack.focusIndexTmp + move;
                // EDLog(@"focusIndexfocusIndex: %ld", (long)focusIndex);
                if (focusIndex > self.klineDataPack.pointNum - 1 || focusIndex < 0) {
                    _lastPanPoint = translationPoint;
                    return;
                }
                self.klineDataPack.focusIndexTmp  = (int)focusIndex;
                if (focusIndex <= self.klineDataPack.baseIndex &&
                    focusIndex >= self.klineDataPack.firstIndex) {
                    self.klineDataPack.focusIndex = (int)focusIndex;
                }
                else{
                    
                }
                //self.klineDataPack.focusIndex = (int)focusIndex;
                CGPoint point = [panGesture locationInView:self];
                self.klineDataPack.focusIndexY = point.y;
            }
            
            CGFloat offset = move * (self.klineDataPack.pillarWidth + 1);
            _lastPanPoint = CGPointMake(_lastPanPoint.x + offset, translationPoint.y);
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (self.klineDataPack.focusIndex != -1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * TREND_KLINE_CROSSLINE_STAYTIME)), dispatch_get_main_queue(), ^{
                    [self hideCrossLine];
                });
            }
            _lastPanPoint = CGPointZero;
            self.isPanFocusing = false;
            break;
            
        default:
            break;
    }
    
    [self setNeedsDisplay];
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    EDLog(@"-------- %s", __func__);
    if (self.klineDataPack.focusIndex >= 0) {
        self.klineDataPack.focusIndex = -1;
        [self setNeedsDisplay];
        return;
    }
    
    CGPoint point = [tapGesture locationInView:self];
#if !KlineHorizontalViewShowAllFocuse
    if (point.y > _tapResponseBottomOriginY) {
        if (self.tapSwitchChartTypeBlock) self.tapSwitchChartTypeBlock();
    } else if (point.y > _tapResponseTopOriginY) {
        if (self.tapSwitchMainChartTypeBlock) self.tapSwitchMainChartTypeBlock();
    } else
#endif
    {
        NSInteger tempIndex = [self klineIndexOnPoint:point];
        if (tempIndex != self.klineDataPack.focusIndex) {
            self.klineDataPack.focusIndex = (int)tempIndex;
            self.klineDataPack.focusIndexY = point.y;
        }
        
        //重绘，会绘制十字线
        [self setNeedsDisplay];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longGesture
{
    CGPoint point = [longGesture locationInView:self];
    EDLog(@"longPressActionlongPressActionlongPressAction %d", self.klineDataPack.focusIndex);
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            NSInteger tempIndex = [self klineIndexOnPoint:point];
            if (tempIndex != self.klineDataPack.focusIndex) {
                self.klineDataPack.focusIndex = (int)tempIndex;
                self.klineDataPack.focusIndexY = point.y;
            }
            
            //重绘，会绘制十字线
            [self setNeedsDisplay];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Setter Getter

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setPeriod:(PERIOD_TYPE)period
{
    if (self.klineDataPack.period == period) {
        return;
    }
    
    [self resetKlinePillarWidth];
    self.klineDataPack.period = period;
    [self setNeedsDisplay];
}

- (PERIOD_TYPE)period
{
    return self.klineDataPack.period;
}

- (HXKlineDataPack *)klineDataPack
{
    if (!_klineDataPack) {
        _klineDataPack = [HXKlineDataPack new];
        StockInfo *stockInfo = [StockInfo new];
        _klineDataPack.stockInfo = stockInfo;
    }
    
    return _klineDataPack;
}

- (void)setIdxConfig:(KlineIdxConfig)idxConfig{
    _idxConfig = idxConfig;
    [self.klineDataPack generateIndicatrix];
    [self setNeedsDisplay];
}

- (void)setRiseColor:(UIColor *)riseColor
{
    self.klineDataPack.riseColor = riseColor;
}
- (UIColor *)riseColor
{
    return self.klineDataPack.riseColor;
}
- (void)setFallColor:(UIColor *)fallColor
{
    self.klineDataPack.fallColor = fallColor;
}
- (UIColor *)fallColor
{
    return self.klineDataPack.fallColor;
}
- (void)setStableColor:(UIColor *)stableColor
{
    self.klineDataPack.stableColor = stableColor;
}
- (UIColor *)stableColor
{
    return self.klineDataPack.stableColor;
}
- (void)setKlineMinColor:(UIColor *)klineMinColor
{
    self.klineDataPack.klineMinColor = klineMinColor;
}
- (UIColor *)klineMinColor
{
    return self.klineDataPack.klineMinColor;
}
- (void)setMaxMinPriceColor:(UIColor *)maxMinPriceColor
{
    self.klineDataPack.maxMinPriceColor = maxMinPriceColor;
}
- (UIColor *)maxMinPriceColor
{
    return self.klineDataPack.maxMinPriceColor;
}

- (void)updateStocks:(NSArray *)newDataArray//设置k线数据
{
    [self.klineDataPack updateWithStockCompdayDatas:newDataArray];//CandleDot
    [self setNeedsDisplay];
}

- (void)reDraw
{
	[self.klineDataPack generateIndicatrix];
	[self setNeedsDisplay];
}

- (NSInteger)klineIndexOnPoint:(CGPoint)point
{
    NSInteger tempIndex = (point.x - self.klineDataPack.leftOffset + 2) / (self.klineDataPack.pillarWidth + self.klineDataPack.pillarSpace) +
    self.klineDataPack.firstIndex;
    
    if (tempIndex > self.klineDataPack.lastIndex) {
        tempIndex = self.klineDataPack.lastIndex;
    }
    
    return tempIndex;
}

- (void)hideCrossLine
{
    if (self.klineDataPack.focusIndex != -1) {
        self.klineDataPack.focusIndex = -1;
        [self setNeedsDisplay];
    }
}

- (void)resetKlinePillarWidth
{
    self.klineDataPack.pillarWidth = KLINE_PIECE_WIDTH;
}

- (void)dataShowMove:(NSInteger)aInterger
{
    NSInteger tempIndex;
    if (self.klineDataPack.firstIndex == 0 && self.klineDataPack.focusIndex == 0 && aInterger < 0) { //请求更多数据
        if (_delegate && [_delegate respondsToSelector:@selector(requestKlineHistoryData)]) {
            [_delegate requestKlineHistoryData];
        }
        
        return;
    }
    
    tempIndex = self.klineDataPack.focusIndex + aInterger;
    
    if (tempIndex >= self.klineDataPack.pointNum) {
        tempIndex = self.klineDataPack.pointNum - 1;
    }
    
    if (tempIndex != self.klineDataPack.focusIndex) { //没有移到最右边一条
        if (self.klineDataPack.focusIndex > -1) {
            self.klineDataPack.focusIndex = (int)tempIndex;
        }
        
        self.klineDataPack.baseIndex += (int)aInterger;
        if (self.klineDataPack.baseIndex >= self.klineDataPack.pointNum) {
            self.klineDataPack.baseIndex = self.klineDataPack.pointNum - 1;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(dataChangeByUser)]) {
            [_delegate dataChangeByUser];
        }
    }
}

#define ContentClipDraw(x) \
CGContextSaveGState(context);\
CGContextClipToRect(context, volumnRect); \
x \
CGContextRestoreGState(context);

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.boundColor.CGColor);

    switch (self.kLineType) {
        case KLineViewTypeNormal:
            [self drawNormalRect:rect context:context];
            break;
            
        case KLineViewTypeFullHorizontalScreen:
            [self drawFullHorizontalScreenRect:rect context:context];
            break;
            
        default:
            break;
    }
    
    if (self.updateFocusBlock) {
        NSInteger idx = self.klineDataPack.focusIndex;
        NSString *tempString = @"";
        if (self.klineDataPack.klineDataArr.count<1){
            self.updateFocusBlock(-1, -1, -1, -1, -1, -1, @"-1");
        }
        else{
            if (idx < 0 || idx >= self.klineDataPack.klineDataArr.count) {
                if (self.kLineType == KLineViewTypeNormal){
                    self.updateFocusBlock(-1, -1, -1, -1, -1, -1, @"-1");
                }
                else{
                    tempString = [self.klineDataPack timeOfIndex: idx];
                    idx = self.klineDataPack.klineDataArr.count-1;
                    HXKlineCompDayData *dayData = [self.klineDataPack.klineDataArr objectAtIndex: idx];
                    HXKlineCompDayData * yData = idx > 0 ? [self.klineDataPack.klineDataArr objectAtIndex:idx - 1] : nil;
                    CGFloat percent = yData ? (CGFloat)(dayData.m_lClosePrice - yData.m_lClosePrice) / (CGFloat) yData.m_lClosePrice : 0;
                    
                    self.updateFocusBlock(dayData.m_lOpenPrice, dayData.m_lMaxPrice, dayData.m_lMinPrice, dayData.m_lClosePrice, percent, dayData.m_lTotal, tempString);
                }
            }
            else{
                tempString = [self.klineDataPack timeOfIndex: idx];
                HXKlineCompDayData *dayData = [self.klineDataPack.klineDataArr objectAtIndex: idx];
                HXKlineCompDayData * yData = idx > 0 ? [self.klineDataPack.klineDataArr objectAtIndex:idx - 1] : nil;
                CGFloat percent = yData ? (CGFloat)(dayData.m_lClosePrice - yData.m_lClosePrice) / (CGFloat) yData.m_lClosePrice : 0;
                
                self.updateFocusBlock(dayData.m_lOpenPrice, dayData.m_lMaxPrice, dayData.m_lMinPrice, dayData.m_lClosePrice, percent, dayData.m_lTotal, tempString);
            }
        }
        
    }
}

- (void) injected{
    NSLog(@"I've been injected   : %@", self);
    // self.view.backgroundColor = [UIColor grayColor];
    [self setNeedsDisplay];
}

- (void)drawFullHorizontalScreenRect:(CGRect)rect context:(CGContextRef)context
{
    if (self.klineDataPack.klineDataArr.count < 1) {
        return;
    }
    int xAxisNum = 4;
    int yAxisNum = 3;
    CGFloat toll = 8;
    CGFloat rightPriceWidth = MIN(MAX(45, rect.size.width * 0.15), 60);
    CGFloat focusHeight = 20;//顶部开高低收的下面一行内容
    EDLog(@"aaaaaa %lf", _maInfoH);
    CGFloat maInfoH = focusHeight;// _maInfoH为开高低收的高度
    CGFloat centerInfoHeight = _centerInfoHeight;
    BOOL showMainIndicator = _idxConfig.mainIdxType != KlineIdxTypeNone;
    BOOL showIndicator = _idxConfig.idxType != KlineIdxTypeNone;
    
    if (showMainIndicator) toll += 2;
    if (showIndicator) toll += 2;
    _mainIndicator = showMainIndicator ? (CGRectGetHeight(rect) * 2 / toll - centerInfoHeight) : 0;
    _volumnH = showIndicator ? (CGRectGetHeight(rect) * 2 / toll - centerInfoHeight) : 0;
    
    CGContextSetFillColorWithColor(context, _infoBlackColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, 15));
    
    CGFloat klineOriginX = 0;//_priceW + _margin;
    CGFloat klineWidth = self.width - 2*klineOriginX;
    
    CGRect timingRect = CGRectMake(klineOriginX, CGRectGetHeight(rect) - _timingH, klineWidth, _timingH);
    
    // 幅图2
    CGRect volumnRect = CGRectMake(klineOriginX, timingRect.origin.y - _volumnH, klineWidth+1, _volumnH);
    
    // 幅图2 说明
    CGRect centerInfoRect = CGRectMake(klineOriginX, volumnRect.origin.y - centerInfoHeight, klineWidth, centerInfoHeight);
    if (!showIndicator)
        centerInfoRect = CGRectMake(klineOriginX, volumnRect.origin.y, klineWidth, 0);
    _tapResponseBottomOriginY = centerInfoRect.origin.y;
    
    // 幅图1 rect
    CGRect mainIndicatorRect = CGRectMake(klineOriginX, centerInfoRect.origin.y  - _mainIndicator, klineWidth+1, _mainIndicator);
    
    // 幅图1 说明
    CGRect mainIndicatorCenterRect = CGRectMake(klineOriginX, mainIndicatorRect.origin.y - centerInfoHeight, klineWidth, centerInfoHeight);
    _tapResponseTopOriginY = CGRectGetMinY(mainIndicatorCenterRect);
    
    // 开高低收幅
    CGRect maInfoRect = CGRectMake(klineOriginX, 0, klineWidth, maInfoH);
    
    CGRect kLineBoundRect = CGRectMake(klineOriginX, CGRectGetMaxY(maInfoRect), klineWidth+1,(showMainIndicator ? mainIndicatorCenterRect : centerInfoRect).origin.y - CGRectGetMaxY(maInfoRect) + 1);
    
    CGFloat kLineSpace = 20;
    // k 线 rect
    CGRect kLineRect = CGRectMake(kLineBoundRect.origin.x,
                                  kLineBoundRect.origin.y + kLineSpace, kLineBoundRect.size.width, kLineBoundRect.size.height - kLineSpace * 2);
    // k 线说明
    CGRect candleDotRect = CGRectMake(maInfoRect.origin.x, CGRectGetMaxY(maInfoRect) - focusHeight, maInfoRect.size.width, focusHeight);
    
    _klineHeight = kLineRect.size.height;
    _klineWidth = kLineRect.size.width;
    self.klineDataPack.totalWidth = klineWidth;
    
    // 十字线和最后一条蜡烛的价格线
    CGFloat priceHeight = 14;
    CGRect priceLineRect = kLineRect;
    priceLineRect.size.height = rect.size.height - kLineRect.origin.y;
    
    if (self.klineDataPack && self.klineDataPack.baseIndex > -1) {
        [self.klineDataPack prepareDrawPrice];
        if (self.klineDataPack.pillarWidth > KLINE_PILLAR_MINWIDTH) {
            if (_idxConfig.priceIdxType == IDX_PriceIdx_BOLL)
                [self.klineDataPack prepareDrawBOLL];
            else if (_idxConfig.priceIdxType == IDX_PriceIdx_EMA)
                [self.klineDataPack prepareDrawEMA];
            
//            CGPoint currentCenter = [self.klineDataPack klineCenterIndex:self.klineDataPack.klineDataArr.count - 1 inRect:kLineRect klineHeight:_klineHeight];//当前价格
//            if (CGRectGetMinY(priceLineRect) < currentCenter.y && currentCenter.y < CGRectGetMaxY(priceLineRect))
//                [self.klineDataPack drawLastLine:self.klineDataPack.klineDataArr.count - 1 inRect:kLineRect context:context point:currentCenter];//最后一条蜡烛价格横线
            //右上角时间
            // [self.klineDataPack drawTopRightTime:kLineBoundRect context:context];
            
            CGRect infoRect = maInfoRect;
            infoRect.origin.x += 3;
            infoRect.size.height -= focusHeight + 2;
            //infoRect.size.width += priceRect.size.width - 5;
            
            /////////////////////////////////////
            // [self.klineDataPack drawCandleDotInRect:infoRect context:context];//开高低收涨幅
            
            // K线
            [self.klineDataPack drawDayDatasInRect:kLineRect context:context];
            [TradConfig drawGridInRect:kLineBoundRect
                             lineColor:_thinLineColor
                           boundsColor:_flatLineColor
                     horizontalLineNum:xAxisNum
                       verticalLineNum:yAxisNum+1
                               context:context];
            switch (_idxConfig.priceIdxType) {
                case KlinePriceIdxTypeNone:
                    break;
                case IDX_PriceIdx_MA:
                    //均线绘制
                    [self.klineDataPack drawMAInfoInRect:candleDotRect context:context screenIsPortrait:NO];
                    [self.klineDataPack drawMACurvesInRect:kLineRect context:context];
                    break;
                case IDX_PriceIdx_BOLL:
                    [self.klineDataPack drawBOLLCenterInfoInRect:candleDotRect context:context];
                    [self.klineDataPack drawBOLLDataInRect:kLineRect context:context];
                    break;
                case IDX_PriceIdx_EMA:
                    [self.klineDataPack drawEMAInfoInRect:candleDotRect context:context];
                    [self.klineDataPack drawEMAInRect:kLineRect context:context];
                    break;
            }
        } else {
            CGRect infoRect = maInfoRect;
            infoRect.size.height -= focusHeight;
            [self.klineDataPack drawCandleDotInRect:infoRect context:context];//最右边的开高低收涨幅
            [self.klineDataPack drawMinPillarDayDatasInRect:kLineRect context:context];
        }
        //价格刻度
        [self.klineDataPack drawPriceCalInRect:kLineBoundRect withRowNumber:yAxisNum space:kLineSpace context:context];
        
        // 最右边一条蜡烛
        NSInteger lastIndex = self.klineDataPack.klineDataArr.count - 1;//self.klineDataPack.baseIndex;
        CGPoint currentCenter = [self.klineDataPack klineCenterIndex:lastIndex inRect:kLineRect klineHeight:_klineHeight];//当前价格
        if (CGRectGetMinY(priceLineRect) < currentCenter.y && currentCenter.y < CGRectGetMaxY(priceLineRect)){
            [self.klineDataPack drawLastLine:lastIndex inRect:kLineRect context:context point:currentCenter];//最后一条蜡烛价格横线
            //最右边一条蜡烛价格
            CGFloat lastPrecent = [self.klineDataPack getPrecentInPriceOnIndex:lastIndex];
            CGRect lastPriceRect = CGRectMake(kLineRect.origin.x,
                                              kLineRect.origin.y + kLineRect.size.height * lastPrecent - priceHeight / 2,
                                              rightPriceWidth,
                                              priceHeight);
            [self.klineDataPack drawLastPrice:lastIndex inRect:lastPriceRect context:context];//价格标左边
        }
        
        //十字线
        self.klineDataPack.focusIndexY = MIN(MAX(CGRectGetMinY(kLineBoundRect), self.klineDataPack.focusIndexY), CGRectGetMaxY(kLineBoundRect));
        self.focusCenter = [self.klineDataPack focusLineCenterInRect:priceLineRect klineHeight:_klineHeight];
        CGRect focusPriceRect = CGRectMake(kLineRect.origin.x,
                                           self.klineDataPack.focusIndexY - priceHeight / 2,
                                           rightPriceWidth,
                                           priceHeight);
        double focusPrice = self.klineDataPack.upLimit - (self.klineDataPack.focusIndexY - CGRectGetMinY(kLineRect)) / (CGRectGetMaxY(kLineRect) - CGRectGetMinY(kLineRect)) * (self.klineDataPack.upLimit - self.klineDataPack.downLimit);
        //十字线
        [self.klineDataPack drawFocusPriceLineInRect:CGRectMake(priceLineRect.origin.x,
                                                                priceLineRect.origin.y - kLineSpace,
                                                                priceLineRect.size.width,
                                                                priceLineRect.size.height)
                                             context:context
                                               point:self.focusCenter];//线
        if (self.klineDataPack.focusIndex >= 0)
            [self.klineDataPack drawPrice:focusPrice inRect:focusPriceRect color:self.klineDataPack.compositeBackgroundColor context:context];
        //        [self.klineDataPack drawFocusTimeInRect: kLineBoundRect context:context];//顶部时间
        //        [self.klineDataPack drawFocusTimeInRect: timingRect context:context];//底部时间
        [self.klineDataPack drawFocusCandleDotInRect:candleDotRect context:context];//价格涨跌幅等内容
        
        //副图1指标
        if (showMainIndicator) {
            [self drawIdxType: _idxConfig.mainIdxType volumnRect:mainIndicatorRect centerInfoRect:mainIndicatorCenterRect context:context];
            [TradConfig drawGridInRect:mainIndicatorRect
                             lineColor:_thinLineColor
                           boundsColor:_flatLineColor
                     horizontalLineNum:xAxisNum
                       verticalLineNum:2
                               context:context];
        }
        
        //副图2指标
        if (showIndicator) {
            [self drawIdxType:_idxConfig.idxType volumnRect:volumnRect centerInfoRect:centerInfoRect context:context];
            [TradConfig drawGridInRect:volumnRect
                             lineColor:_thinLineColor
                           boundsColor:_flatLineColor
                     horizontalLineNum:xAxisNum
                       verticalLineNum:2
                               context:context];
        }
        
        
        // 底部日期绘制
        [self.klineDataPack drawTimeCalInRect:timingRect context:context];
        
        // [self.klineDataPack drawFocusTimeInRect:kLineBoundRect context:context];//顶部时间
        [self.klineDataPack drawFocusTimeInRect:timingRect context:context];//底部时间
    }
}

- (void)drawNormalRect:(CGRect)rect context:(CGContextRef)context
{
    if (self.klineDataPack.klineDataArr.count < 1) {
        return;
    }
    int xAxisNum = 4;
    int yAxisNum = 3;
    CGFloat toll = 8;
    CGFloat rightPriceWidth = MIN(MAX(45, rect.size.width * 0.15), 60);
    CGFloat focusHeight = 20;//顶部开高低收的下面一行内容
    CGFloat maInfoH = focusHeight;// _maInfoH为开高低收的高度
    CGFloat centerInfoHeight = _centerInfoHeight;
    BOOL showMainIndicator = _idxConfig.mainIdxType != KlineIdxTypeNone;
    BOOL showIndicator = _idxConfig.idxType != KlineIdxTypeNone;

    if (showMainIndicator) toll += 2;
    if (showIndicator) toll += 2;
    _mainIndicator = showMainIndicator ? (CGRectGetHeight(rect) * 2 / toll - centerInfoHeight) : 0;
    _volumnH = showIndicator ? (CGRectGetHeight(rect) * 2 / toll - centerInfoHeight) : 0;

    CGContextSetFillColorWithColor(context, _infoBlackColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, 15));

    CGFloat klineOriginX = _priceW + _margin;
    CGFloat klineWidth = self.width - 2*klineOriginX;

    CGRect timingRect = CGRectMake(klineOriginX, CGRectGetHeight(rect) - _timingH, klineWidth, _timingH);
    
    // 幅图2
    CGRect volumnRect = CGRectMake(klineOriginX, timingRect.origin.y - _volumnH, klineWidth, _volumnH);

    // 幅图2 说明
    CGRect centerInfoRect = CGRectMake(klineOriginX, volumnRect.origin.y - centerInfoHeight, klineWidth, centerInfoHeight);
    if (!showIndicator)
        centerInfoRect = CGRectMake(klineOriginX, volumnRect.origin.y, klineWidth, 0);
    _tapResponseBottomOriginY = centerInfoRect.origin.y;

    // 幅图1 rect
    CGRect mainIndicatorRect = CGRectMake(klineOriginX, centerInfoRect.origin.y  - _mainIndicator, klineWidth, _mainIndicator);

    // 幅图1 说明
    CGRect mainIndicatorCenterRect = CGRectMake(klineOriginX, mainIndicatorRect.origin.y - centerInfoHeight, klineWidth, centerInfoHeight);
    _tapResponseTopOriginY = CGRectGetMinY(mainIndicatorCenterRect);

    // 开高低收幅
    CGRect maInfoRect = CGRectMake(klineOriginX, 0, klineWidth, maInfoH);

    CGRect kLineBoundRect = CGRectMake(klineOriginX, CGRectGetMaxY(maInfoRect), klineWidth,(showMainIndicator ? mainIndicatorCenterRect : centerInfoRect).origin.y - CGRectGetMaxY(maInfoRect) + 1);

    CGFloat kLineSpace = 20;
    // k 线 rect
    CGRect kLineRect = CGRectMake(kLineBoundRect.origin.x,
                                  kLineBoundRect.origin.y + kLineSpace, kLineBoundRect.size.width, kLineBoundRect.size.height - kLineSpace * 2);
    // k 线说明
    CGRect candleDotRect = CGRectMake(maInfoRect.origin.x, CGRectGetMaxY(maInfoRect) - focusHeight, maInfoRect.size.width, focusHeight);

    _klineHeight = kLineRect.size.height;
    _klineWidth = kLineRect.size.width;
    self.klineDataPack.totalWidth = klineWidth;

    // 十字线和最后一条蜡烛的价格线
    CGFloat priceHeight = 14;
    CGRect priceLineRect = kLineRect;
    priceLineRect.size.height = rect.size.height - kLineRect.origin.y;

    if (self.klineDataPack && self.klineDataPack.baseIndex > -1) {
        [self.klineDataPack prepareDrawPrice];
        if (self.klineDataPack.pillarWidth > KLINE_PILLAR_MINWIDTH) {
            if (_idxConfig.priceIdxType == IDX_PriceIdx_BOLL)
                [self.klineDataPack prepareDrawBOLL];
            else if (_idxConfig.priceIdxType == IDX_PriceIdx_EMA)
                [self.klineDataPack prepareDrawEMA];

            CGRect infoRect = maInfoRect;
            infoRect.origin.x += 3;
            infoRect.size.height -= focusHeight + 2;
            //infoRect.size.width += priceRect.size.width - 5;
            // [self.klineDataPack drawCandleDotInRect:infoRect context:context];//开高低收涨幅
            // K线
            [self.klineDataPack drawDayDatasInRect:kLineRect context:context];
            [TradConfig drawGridInRect:kLineBoundRect
                             lineColor:_thinLineColor
                           boundsColor:_flatLineColor
                     horizontalLineNum:xAxisNum
                       verticalLineNum:yAxisNum+1
                               context:context];
            switch (_idxConfig.priceIdxType) {
                case KlinePriceIdxTypeNone:
                    break;
                case IDX_PriceIdx_MA:
                    //均线绘制
                    [self.klineDataPack drawMAInfoInRect:candleDotRect context:context screenIsPortrait:NO];
                    [self.klineDataPack drawMACurvesInRect:kLineRect context:context];
                    break;
                case IDX_PriceIdx_BOLL:
                    [self.klineDataPack drawBOLLCenterInfoInRect:candleDotRect context:context];
                    [self.klineDataPack drawBOLLDataInRect:kLineRect context:context];
                    break;
                case IDX_PriceIdx_EMA:
                    [self.klineDataPack drawEMAInfoInRect:candleDotRect context:context];
                    [self.klineDataPack drawEMAInRect:kLineRect context:context];
                    break;
            }
        } else {
            CGRect infoRect = maInfoRect;
            infoRect.size.height -= focusHeight;
            [self.klineDataPack drawCandleDotInRect:infoRect context:context];//最右边的开高低收涨幅
            [self.klineDataPack drawMinPillarDayDatasInRect:kLineRect context:context];
        }
        //价格刻度
        [self.klineDataPack drawPriceCalInRect:kLineBoundRect withRowNumber:yAxisNum space:kLineSpace context:context];

        //最右边一条蜡烛价格
        NSInteger lastIndex = self.klineDataPack.klineDataArr.count - 1;//self.klineDataPack.baseIndex;
        CGPoint currentCenter = [self.klineDataPack klineCenterIndex:lastIndex inRect:kLineRect klineHeight:_klineHeight];//当前价格
        if (CGRectGetMinY(priceLineRect) < currentCenter.y && currentCenter.y < CGRectGetMaxY(priceLineRect)){
            [self.klineDataPack drawLastLine:lastIndex inRect:kLineRect context:context point:currentCenter];//最后一条蜡烛价格横线
            //最右边一条蜡烛价格
            CGFloat lastPrecent = [self.klineDataPack getPrecentInPriceOnIndex:lastIndex];
            CGRect lastPriceRect = CGRectMake(kLineRect.origin.x,
                                              kLineRect.origin.y + kLineRect.size.height * lastPrecent - priceHeight / 2,
                                              rightPriceWidth,
                                              priceHeight);
            [self.klineDataPack drawLastPrice:lastIndex inRect:lastPriceRect context:context];//价格标左边
        }

        //十字线
        self.klineDataPack.focusIndexY = MIN(MAX(CGRectGetMinY(kLineBoundRect), self.klineDataPack.focusIndexY), CGRectGetMaxY(kLineBoundRect));
        self.focusCenter = [self.klineDataPack focusLineCenterInRect:priceLineRect klineHeight:_klineHeight];
        CGRect focusPriceRect = CGRectMake(kLineRect.origin.x,
                                           self.klineDataPack.focusIndexY - priceHeight / 2,
                                           rightPriceWidth,
                                           priceHeight);
        double focusPrice = self.klineDataPack.upLimit - (self.klineDataPack.focusIndexY - CGRectGetMinY(kLineRect)) / (CGRectGetMaxY(kLineRect) - CGRectGetMinY(kLineRect)) * (self.klineDataPack.upLimit - self.klineDataPack.downLimit);
        //十字线
        [self.klineDataPack drawFocusPriceLineInRect:CGRectMake(priceLineRect.origin.x,
                                                                priceLineRect.origin.y - kLineSpace,
                                                                priceLineRect.size.width,
                                                                priceLineRect.size.height)
                                             context:context
                                               point:self.focusCenter];//线
        if (self.klineDataPack.focusIndex >= 0)
            [self.klineDataPack drawPrice:focusPrice inRect:focusPriceRect color:self.klineDataPack.compositeBackgroundColor context:context];
//        [self.klineDataPack drawFocusTimeInRect: kLineBoundRect context:context];//顶部时间
//        [self.klineDataPack drawFocusTimeInRect: timingRect context:context];//底部时间
        [self.klineDataPack drawFocusCandleDotInRect:candleDotRect context:context];//价格涨跌幅等内容

        //副图1指标
        if (showMainIndicator) {
            [self drawIdxType: _idxConfig.mainIdxType volumnRect:mainIndicatorRect centerInfoRect:mainIndicatorCenterRect context:context];
            [TradConfig drawGridInRect:mainIndicatorRect
                             lineColor:_thinLineColor
                           boundsColor:_flatLineColor
                     horizontalLineNum:xAxisNum
                       verticalLineNum:2
                               context:context];
        }

        //副图2指标
        if (showIndicator) {
            [self drawIdxType:_idxConfig.idxType volumnRect:volumnRect centerInfoRect:centerInfoRect context:context];
            [TradConfig drawGridInRect:volumnRect
                             lineColor:_thinLineColor
                           boundsColor:_flatLineColor
                     horizontalLineNum:xAxisNum
                       verticalLineNum:2
                               context:context];
        }

        
        // 底部日期绘制
        [self.klineDataPack drawTimeCalInRect:timingRect context:context];
        
        //[self.klineDataPack drawFocusTimeInRect:kLineBoundRect context:context];//顶部时间
        [self.klineDataPack drawFocusTimeInRect:timingRect context:context];//底部时间
    }
}

- (void)drawIdxType:(KlineIdxType)idxType volumnRect:(CGRect)volumnRect centerInfoRect:(CGRect)centerInfoRect context:(CGContextRef)context
{
    centerInfoRect = CGRectMake(centerInfoRect.origin.x + 1,
               centerInfoRect.origin.y,
               centerInfoRect.size.width,
                                centerInfoRect.size.height);
    switch (idxType) {
        case KlineIdxTypeNone:
            break;
            
        case IDX_VOLUMN://成交量
            [self.klineDataPack prepareDrawVOLHS];
            ContentClipDraw(
            [self.klineDataPack drawVolumeChartInRect:volumnRect context:context];  //成交量柱子
            [self.klineDataPack drawVOLHSDataInRect:volumnRect context:context];    //画两根实线
                            )
            [self.klineDataPack drawCenterInfoInRect:centerInfoRect context:context]; //K线框和底部成交量中间信息区域
            break;
            
        case IDX_MACD:
            [self.klineDataPack prepareDrawMACD];
            [self.klineDataPack drawMACDDataInRect:volumnRect context:context];
            [self.klineDataPack drawMACDCenterInfoInRect:centerInfoRect context:context];
            break;
            
        case IDX_KDJ:
            [self.klineDataPack prepareDrawKDJ];
            [self.klineDataPack drawKDJDataInRect:volumnRect context:context];
            [self.klineDataPack drawKDJCenterInfoInRect:centerInfoRect context:context];
            break;
            
        case IDX_RSI:
            [self.klineDataPack prepareDrawRSI];
            [self.klineDataPack drawRSIDataInRect:volumnRect context:context];
            [self.klineDataPack drawRSICenterInfoInRect:centerInfoRect context:context];
            break;
            
        case IDX_BOLL:
            [self.klineDataPack prepareDrawPrice];
            [self.klineDataPack prepareDrawBOLL];
            [self.klineDataPack drawDayDatasInRect:volumnRect context:context];
            [self.klineDataPack drawBOLLDataInRect:volumnRect context:context];
            [self.klineDataPack drawBOLLCenterInfoInRect:centerInfoRect context:context];
            break;
            
        case IDX_PSY:
            [self.klineDataPack prepareDrawPSY];
            [self.klineDataPack drawPSYDataInRect:volumnRect context:context];
            [self.klineDataPack drawPSYCenterInfoInRect:centerInfoRect context:context];
            break;
            
        case IDX_DMI:
            [self.klineDataPack prepareDrawDMI];
            [self.klineDataPack drawDMIDataInRect:volumnRect context:context];
            [self.klineDataPack drawDMICenterInfoInRect:centerInfoRect context:context];
            break;
        case IDX_WR://目前绘画有问题
            [self.klineDataPack prepareDrawWR];
            [self.klineDataPack drawWRDataInRect:volumnRect context:context];
            [self.klineDataPack drawWRCenterInfoInRect:centerInfoRect context:context];
            break;
            
        case IDX_ASI:
            [self.klineDataPack prepareDrawASI];
            [self.klineDataPack drawASIDataInRect:volumnRect context:context];
            [self.klineDataPack drawASICenterInfoInRect:centerInfoRect context:context];
            break;
        case IDX_DMA:
            [self.klineDataPack prepareDrawDMA];
            [self.klineDataPack drawDMADataInRect:volumnRect context:context];
            [self.klineDataPack drawDMACenterInfoInRect:centerInfoRect context:context];
            break;
        case IDX_BIAS:
            [self.klineDataPack prepareDrawBIAS];
            [self.klineDataPack drawBIASDataInRect:volumnRect context:context];
            [self.klineDataPack drawBIASInfoInRect:centerInfoRect context:context];
            break;
        case IDX_VR:
            [self.klineDataPack prepareDrawVR];
            [self.klineDataPack drawVRDataInRect:volumnRect context:context];
            [self.klineDataPack drawVRInfoInRect:centerInfoRect context:context];
            break;
        case IDX_CCI:
            [self.klineDataPack prepareDrawCCI];
            [self.klineDataPack drawCCIDataInRect:volumnRect context:context];
            [self.klineDataPack drawCCICenterInfoInRect:centerInfoRect context:context];
            break;
        case IDX_TRIX:
            [self.klineDataPack prepareDrawTRIX];
            [self.klineDataPack drawTRIXInRect:volumnRect context:context];
            [self.klineDataPack drawTRIXInfoInRect:centerInfoRect context:context];
            break;
    }
}

@end
