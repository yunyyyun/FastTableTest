//
//  PriceHistoryView.m
//  GoIco
//
//  Created by Violet on 2018/1/8.
//  Copyright © 2018年 ico. All rights reserved.
//

#import "PriceHistoryView.h"
#import "TradConfig.h"
#import "NSString+Size.h"
#import "NSDate+String.h"

//#pragma mark - PriceHistoryDrawView
//
#define kPriceHistoryViewVolumePer 0.2
#define kPriceHistoryViewTimeHeight 18.
#define kPriceHistoryViewPriceWidth 50.
#define kPriceHistoryViewMinWidth 0.//(0.5 / (2. / 3))
#define kPriceHistoryViewMaxWidth 20.
#define kPriceVolumInfoHeight 24.
#define kPriceVolumInfoSpace 8

@interface PriceHistoryView () <UIGestureRecognizerDelegate>

//绘画时临时
@property (assign, nonatomic, readonly) CGFloat maxPrice;
@property (assign, nonatomic, readonly) CGFloat minPrice;
@property (assign, nonatomic, readonly) CGFloat maxVolume;
@property (assign, nonatomic) int timeStartIdx;
@property (assign, nonatomic) int timeEndIdx;
@property (assign, nonatomic, readonly) CGFloat contentOffset;//x
@property (assign, nonatomic, readonly) CGFloat contentSize;//width
@property (assign, nonatomic) CGRect drawRect;//价格趋势图绘画区域
@property (assign, nonatomic) CGRect touchAnhorRect;//

@property (assign, nonatomic) BOOL isPanBacking;
@property (assign, nonatomic) BOOL isFocusPaning;//拖动十字线
@property (assign, nonatomic) int focusIndex;
@property (assign, nonatomic) CGFloat focusPointY;

@property (assign, nonatomic) CGPoint panTranslationPoint;
@property (assign, nonatomic) CGFloat pinchScale;

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation PriceHistoryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _themeBlueColor = [UIColor colorWithRed: 72/255.0 green: 98/255.0  blue: 227/255.0  alpha: 1];
    _themeYellowColor = [UIColor colorWithRed: 252/255.0 green: 145/255.0  blue: 58/255.0  alpha: 1];
    _thinLineColor = [UIColor colorWithWhite: 153/255.0 alpha: 0.15];
    _flatLineColor = [UIColor colorWithWhite: 153/255.0 alpha: 0.15];
    _volumeColor = _themeBlueColor;
    _crossLineColor = _themeBlueColor;
    _lableColor = [UIColor colorWithWhite: 153/255.0 alpha: 1];;
    _lableBgColor = _themeBlueColor;
    
    self.font = [UIFont systemFontOfSize:10];
    self.focusIndex = -1;
    _numberOfPrice = 5;
    _numberOfTime = 2;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongGesture:)];
    self.longPressGesture.delegate = self;
    [self addGestureRecognizer:self.longPressGesture];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    self.pinchGesture.delegate = self;
    [self addGestureRecognizer:self.pinchGesture];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    self.tapGesture.delegate = self;
    [self addGestureRecognizer:self.tapGesture];
}

- (void)setType:(PriceHistoryViewType)type{
    _type = type;
    switch (self.type) {
        case PriceHistoryViewTypeNormal:
            _numberOfPrice = 5;
            _numberOfTime = 2;
            break;
        
        case PriceHistoryViewTypeFullHorizontalScreen:
            _numberOfPrice = 5;
            _numberOfTime = 0;
            break;
        case PriceHistoryViewTypeAsset:
            _numberOfPrice = 3;
            _numberOfTime = 0;
            _crossLineColor = _themeYellowColor;
            
            break;
            
        default:
            break;
    }
}

- (void)setShowVolume:(BOOL)showVolume{
    _showVolume = showVolume;
    _contentOffset = 1;//为1的时候会在绘画的时候计算
    self.focusIndex = -1;
    [self setNeedsDisplay];
}

- (void)setDatas:(NSArray<HistoryPriceData *> *)datas
{
    if ([self.datas isEqualToArray:datas]) {
        return;
    }
    _datas = datas;
    //    _contentSize = datas.count * kPriceHistoryViewMinWidth;
    //    _contentSize = MAX(_contentSize, self.datas.count * kPriceHistoryViewMinWidth);
    //    _contentSize = MIN(_contentSize, self.datas.count * kPriceHistoryViewMaxWidth);
    
    //_numberOfTime = datas.count+1;
    
    _contentOffset = 1;//为1的时候会在绘画的时候计算
    self.focusIndex = -1;
    [self setNeedsDisplay];
}

- (void)setPriceInfo:(NSString *)priceInfo
{
    if ([_priceInfo isEqualToString:priceInfo]) return;
    
    _priceInfo = priceInfo;
    [self setNeedsDisplay];
}

- (void)setVolumeInfo:(NSString *)volumeInfo
{
    if ([_volumeInfo isEqualToString:volumeInfo]) return;
    
    _volumeInfo = volumeInfo;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.backgroundColor.CGColor);
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    if (self.datas.count < 1) return;
    
    switch (self.type) {
        case PriceHistoryViewTypeNormal:
            [self normalDrawRect:rect context:context];
            break;
            
        case PriceHistoryViewTypeAsset:
            [self assetDrawRect:rect context:context];
            break;
            
        case PriceHistoryViewTypeFullHorizontalScreen:
            [self normalDrawRect:rect context:context];
            break;
            
        default:
            break;
    }
    
    
    if (self.updateFocusBlock) {
        if (self.focusIndex < 0 || self.focusIndex >= self.datas.count) {
            self.updateFocusBlock(CGPointZero, @"", @"");
        }
        else{
            HistoryPriceData *data = [self.datas objectAtIndex:self.focusIndex];
            NSString *time = [self getFocusTimeString:data];
            CGPoint point = [self getPoint:data inRect:rect idx:self.focusIndex];
            NSString *price = formatterKlinePrice_pkb(data.price);
            self.updateFocusBlock(point, price, time);
        }
    }
}

- (void) injected{
    NSLog(@"I've been injected  : %@", self);
    [self setNeedsDisplay];
}

- (void)assetDrawRect:(CGRect)rect context:(CGContextRef)context
{
    CGFloat edgeSpace = 0.0; // 左右间隙
    CGRect drawRect = rect;
    // 显示时间坐标
    if (self.showTime)
        drawRect.size.height -= kPriceHistoryViewTimeHeight;
    
    self.drawRect = drawRect;
    [self prepareParam:drawRect padding:true];
    
    // 趋势图实际绘制区域
    CGRect drawContextRect = CGRectMake(drawRect.origin.x + edgeSpace,
                                        drawRect.origin.y,
                                        drawRect.size.width - edgeSpace*2,
                                        drawRect.size.height);
    [TradConfig drawGridInRect:drawContextRect
                     lineColor:_thinLineColor
                   boundsColor:_flatLineColor
             horizontalLineNum:_numberOfTime
               verticalLineNum:_numberOfPrice
                       context:context];
    // 显示价格刻度
    if (self.showPrice) {
        [self drawPriceCalInRect:CGRectMake(drawContextRect.origin.x, drawContextRect.origin.y, kPriceHistoryViewPriceWidth, drawContextRect.size.height) withRowNumber:self.numberOfPrice context:context];
    }
    
    CGFloat drawY = CGRectGetMaxY(drawRect);
    
    // 绘制时间坐标
    CGRect timeRect = CGRectZero;
    if (self.showTime) {
        timeRect = CGRectMake(drawRect.origin.x, drawY, drawRect.size.width, kPriceHistoryViewTimeHeight);
        [self drawTimeCallInRect:timeRect context:context];
        drawY += kPriceHistoryViewTimeHeight;
    }
    
    [self drawPriceLineInRect: drawContextRect context:context];
    
    // 十字线
    if (self.focusIndex >= 0 && self.focusIndex < self.datas.count) {
        [self drawFocusInRect:drawContextRect
                    volumRect:drawContextRect
                     timeRect:timeRect
                      context:context];
    }
}

- (void)normalDrawRect:(CGRect)rect context:(CGContextRef)context
{
    CGFloat edgeSpace = 5.0; // 左右间隙
    CGRect drawRect = rect;
    
    // 显示时间坐标
    if (self.showTime)
        drawRect.size.height -= kPriceHistoryViewTimeHeight;
    
    // 显示量图
    CGFloat volumeHeight = drawRect.size.height * kPriceHistoryViewVolumePer;
    if (self.showVolume){
        drawRect.size.height -= (volumeHeight + kPriceVolumInfoSpace);
    }
    self.drawRect = drawRect;
    [self prepareParam:drawRect padding:true];
    
    // 趋势图实际绘制区域
    CGRect drawContextRect = CGRectMake(drawRect.origin.x + edgeSpace,
                                        drawRect.origin.y,
                                        drawRect.size.width - edgeSpace*2,
                                        drawRect.size.height);
    [TradConfig drawGridInRect:drawContextRect
                     lineColor:_thinLineColor
                   boundsColor:_flatLineColor
             horizontalLineNum:_numberOfTime
               verticalLineNum:_numberOfPrice
                       context:context];
    // 显示价格刻度
    if (self.showPrice) {
        [self drawPriceCalInRect:CGRectMake(drawContextRect.origin.x, drawContextRect.origin.y, kPriceHistoryViewPriceWidth, drawContextRect.size.height) withRowNumber:self.numberOfPrice context:context];
    }
    
    CGFloat drawY = CGRectGetMaxY(drawRect);
    
    // 绘制时间坐标
    CGRect timeRect = CGRectZero;
    if (self.showTime) {
        timeRect = CGRectMake(drawRect.origin.x, drawY, drawRect.size.width, kPriceHistoryViewTimeHeight);
        [self drawTimeCallInRect:timeRect context:context];
        drawY += kPriceHistoryViewTimeHeight;
    }
    
    // 绘制量图
    CGRect volumRect = CGRectZero;
    if (self.showVolume) {
        drawY += kPriceVolumInfoSpace*0.2;
        volumRect = CGRectMake(drawRect.origin.x + edgeSpace,
                               drawY,
                               drawRect.size.width - 2*edgeSpace,
                               volumeHeight);
        self.volumeInfo = @"量图 USD";
        if (self.volumeInfo) {
            UIFont *font = [UIFont systemFontOfSize: 11];
            [TradConfig drawRightString:self.volumeInfo atPoint:CGPointMake(volumRect.origin.x,
                                                                            volumRect.origin.y + edgeSpace) inRect:volumRect font:font color:_lableColor backgroundColor:nil context:context];
        }
        
        [self drawVolumeInRect:volumRect context:context];
        [TradConfig drawGridInRect:volumRect
                         lineColor:_thinLineColor
                       boundsColor:_flatLineColor
                 horizontalLineNum:_numberOfTime
                   verticalLineNum:2
                           context:context];
    }
    [self drawPriceLineInRect: drawContextRect context:context];
    
    // 十字线
    if (self.focusIndex >= 0 && self.focusIndex < self.datas.count) {
        [self drawFocusInRect:drawContextRect
                    volumRect:volumRect
                     timeRect:timeRect
                      context:context];
    }
}

- (void)prepareParam:(CGRect)drawRect padding:(BOOL)padding
{
    // 绘画区域
    if (self.contentSize < drawRect.size.width)
        _contentSize = drawRect.size.width;
    if (self.contentOffset == 1)
        _contentOffset = MIN(drawRect.size.width - self.contentSize, 0);
    self.timeStartIdx = MAX([self getIdxWithX:drawRect.origin.x], 0);
    self.timeEndIdx = MIN([self getIdxWithX:CGRectGetMaxX(drawRect)], (int)self.datas.count - 1);
    
    // price
    int idx = MAX(0, self.timeStartIdx - 1);
    HistoryPriceData *startData = [self.datas objectAtIndex:idx];
    _maxPrice = startData.price;
    _minPrice = startData.price;
    _maxVolume = startData.volume;
    for (; idx < MIN(self.datas.count, self.timeEndIdx + 2); idx ++)  {
        HistoryPriceData *data = [self.datas objectAtIndex:idx];
        if (data.price > _maxPrice) _maxPrice = data.price;
        if (data.price < _minPrice) _minPrice = data.price;
        if (data.volume > self.maxVolume) _maxVolume = data.volume;
    }
    if (padding) {
        double topPer = 0.1;//顶部占10%
        double bottomPer = 0.1;//底部占10%
        double volumePer = 0.2;//量顶部空余占10%
        double dPrice = _maxPrice - _minPrice;
        _maxPrice += dPrice * (topPer / (1 - topPer - bottomPer));
        _minPrice -= dPrice * (bottomPer / (1 - topPer - bottomPer));
        if (self.type != PriceHistoryViewTypeAsset)
            _minPrice = MAX(_minPrice, 0);
        _maxVolume *= (volumePer + 1);
    }
    if (_maxPrice == _minPrice){
        _maxPrice = _maxPrice+0.01;
        _minPrice = _minPrice-0.01;
    }
}

- (void)drawPriceCalInRect:(CGRect)rect
             withRowNumber:(NSInteger)row
                   context:(CGContextRef)context
{
    CGRect tmpRect = rect;
    //    tmpRect.origin.y -= 4;
    //    tmpRect.size.height += 8;
    double dPrice = (self.maxPrice - self.minPrice) / (row - 1);
    double dHeight = rect.size.height / (row - 1);
    
    for (int i = 0; i < row; i++) {
        //double price = self.minPrice + dPrice / (row - 1) * i;
        double price = self.maxPrice - dPrice * i;
        CGFloat y = tmpRect.origin.y + dHeight * i - 8;
        
        NSString *priceStr = @"";
        if (self.type == PriceHistoryViewTypeAsset){
            priceStr = [NSString formatterVolumeWith: price];
        }
        else{
            priceStr = formatterKlinePrice_pkb(price);
        }
        [TradConfig drawRightString: priceStr
                            atPoint:CGPointMake(tmpRect.origin.x + 5, y)
                             inRect:tmpRect
                               font:self.font
                              color:_lableColor
                    backgroundColor:nil
                            context:context];
    }
}

// 趋势图
- (void)drawPriceLineInRect:(CGRect)rect context:(CGContextRef)context
{
    UIColor *themeColor = self.type==PriceHistoryViewTypeAsset? _themeYellowColor : _themeBlueColor;
    CGContextSaveGState(context);
    CGContextClipToRect(context, CGRectMake(rect.origin.x, rect.origin.y - 1, rect.size.width, rect.size.height + 2));
    rect.origin.y += 1;
    rect.size.height -= 2;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1.0;
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineJoinRound; //终点处理
    [themeColor set]; //设置线条颜色
    
    CGPoint firstPoint = CGPointMake(self.contentOffset + rect.origin.x , [self getYWithPrice:[self.datas objectAtIndex:MAX(self.timeStartIdx - 1, 0)].price inRect:rect]);
    //[self getPoint:[self.datas objectAtIndex:MAX(self.timeStartIdx - 1, 0)] inRect:rect idx:0];
    //CGPoint lastPoint;
    [path moveToPoint:firstPoint];
    
    for (int idx = self.timeStartIdx; idx <= self.timeEndIdx; idx ++) {
        [path addLineToPoint:[self getPoint:[self.datas objectAtIndex:idx] inRect:rect idx:idx]];
    }
    [path stroke];
    
    [path addLineToPoint:CGPointMake([self getPoint:[self.datas objectAtIndex:self.timeEndIdx] inRect:rect idx:self.timeEndIdx].x, CGRectGetMaxY(rect))];
    [path addLineToPoint:CGPointMake(firstPoint.x, CGRectGetMaxY(rect))];
    [path closePath];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) [themeColor colorWithAlphaComponent:0.2].CGColor,
                        (__bridge id) [themeColor colorWithAlphaComponent:0.02].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), rect.origin.y + rect.size.height);
    //画渐变
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRestoreGState(context);
}

//成交量
- (void)drawVolumeInRect:(CGRect)rect context:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGFloat height = rect.size.height;
    
    CGFloat cellWidth = rect.size.width / self.datas.count;
    CGFloat edgeWidth = cellWidth*1./4;
    edgeWidth = MIN(10, edgeWidth);
    edgeWidth = MAX(1, edgeWidth);
    CGFloat rWidth = cellWidth-edgeWidth;
    [self.datas enumerateObjectsUsingBlock:^(HistoryPriceData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [self getPoint:obj inRect:rect idx:(int)idx];
        CGFloat rHeight = height * obj.volume / self.maxVolume *0.8; // *0.8， 防止量图太高
        CGContextSetFillColorWithColor(context, self.themeBlueColor.CGColor);//实心柱子
        CGContextFillRect(context, CGRectMake(point.x - rWidth / 2,
                                              CGRectGetMaxY(rect) - rHeight-2, rWidth, rHeight));
    }];
    CGContextRestoreGState(context);
}

// 焦点和十字线
- (void)drawFocusInRect:(CGRect)rect volumRect:(CGRect)volumRect timeRect:(CGRect)timeRect context:(CGContextRef)context
{
    HistoryPriceData *data = [self.datas objectAtIndex:self.focusIndex];
    CGPoint point = [self getPoint:data inRect:rect idx:self.focusIndex];
    // point.y = _focusPointY;
    if (!CGRectContainsPoint(CGRectMake(rect.origin.x - 2, rect.origin.y - 2, rect.size.width + 4, rect.size.height + 4), point)) return;
    
    CGContextSetLineWidth(context, 1);
    //竖线
    CGContextMoveToPoint(context, point.x, rect.origin.y);
    if (_type == PriceHistoryViewTypeFullHorizontalScreen)
        CGContextAddLineToPoint(context, point.x, MAX(CGRectGetMaxY(volumRect)-4, CGRectGetMaxY(timeRect)));
    else
        CGContextAddLineToPoint(context, point.x, MAX(CGRectGetMaxY(volumRect)-4, timeRect.origin.y));

    //颜色
    CGContextSetStrokeColorWithColor(context, _crossLineColor.CGColor);
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, _crossLineColor.CGColor);
    
    CGFloat focusRadius = 3;
    CGFloat focusRadius2 = 4;
    CGFloat focusRadius3 = 8;
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    const CGFloat *components = CGColorGetComponents(_crossLineColor.CGColor);
    CGFloat colors[] =
    {
        components[0], components[1], components[2], 0.6,
        //components[0], components[1], components[2], 0.8,
        components[0], components[1], components[2], 0.4,
        //components[0], components[1], components[2], 0.6,
        components[0], components[1], components[2], 0.2,
        //components[0], components[1], components[2], 0.4,
        components[0], components[1], components[2], 0.05,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb,
                                                                 colors,
                                                                 NULL,
                                                                 sizeof(colors)/(sizeof(colors[0])*4));//形成梯形，渐变的效果
    CGColorSpaceRelease(rgb);
    CGContextDrawRadialGradient(context,
                                gradient,  // 渐变色
                                point,  // 开始的中心点
                                focusRadius2,  // 开始的半径
                                point,  // 结束的中心点
                                focusRadius3,  // 结束的半径
                                kCGGradientDrawsBeforeStartLocation);
    
    //画空心圆
    
    CGRect bigRect = CGRectMake(point.x - focusRadius, point.y - focusRadius, focusRadius*2, focusRadius*2);
    CGContextSetLineWidth(context, focusRadius);
    CGContextAddEllipseInRect(context, bigRect);
    [_crossLineColor set];
    //CGContextStrokePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    CGRect bigRect2 = CGRectMake(point.x - focusRadius2, point.y - focusRadius2, focusRadius2*2, focusRadius2*2);
    CGContextSetLineWidth(context, focusRadius2-2);
    CGContextAddEllipseInRect(context, bigRect2);
    [[UIColor whiteColor] set];
    //CGContextStrokePath(context);
    CGContextDrawPath(context, kCGPathStroke);
    
    if (self.type == PriceHistoryViewTypeAsset){
        CGFloat hh = 22;
        CGFloat ww = [formatterKlinePrice_pkb(data.price) widthWithFont: self.font];
        CGFloat xx = 0;
        CGFloat yy = 0;
        if (point.x>CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds)*0.5){
            xx = point.x - ww -10;
        }
        else{
            xx = point.x + 10;
        }
        yy = point.y - hh/2;
        if (yy < rect.origin.y)
            yy = rect.origin.y;
        else if (yy > CGRectGetMaxY(rect)-hh)
            yy = CGRectGetMaxY(rect)-hh;
        CGRect focusRect = CGRectMake(xx, yy, ww, hh);

        [TradConfig drawCenterString: [NSString formatterVolumeWith: data.price]
                               atPoint:point
                                inRect:focusRect
                                  font:self.font
                                 color:[UIColor darkTextColor]
                       backgroundColor:nil
                               context:context];
    }
}

// 时间坐标标签
- (void)drawTimeCallInRect:(CGRect)rect context:(CGContextRef)context
{
    NSMutableArray<NSString *> *timeString = [NSMutableArray array];
    [timeString addObject:[self getTimeString:[self.datas objectAtIndex:self.timeStartIdx]]];
    [timeString addObject:[self getTimeString:[self.datas objectAtIndex:self.timeEndIdx]]];
    
    CGFloat originX = rect.origin.x;
    CGFloat originY = CGRectGetMidY(rect);
    CGFloat space = rect.size.width / (timeString.count - 1);
    [timeString enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            [TradConfig drawRightString:string atPoint:CGPointMake(originX, originY) inRect:rect font:self.font color: self.lableColor backgroundColor:nil context:context];
        } else if (idx == timeString.count - 1) {
            [TradConfig drawLeftString:string atPoint:CGPointMake(CGRectGetMaxX(rect), originY) inRect:rect font:self.font color:self.lableColor backgroundColor:nil context:context];
        } else {
            [TradConfig drawLeftString:string atPoint:CGPointMake(originX + space * idx, originY) inRect:rect font:self.font color:self.lableColor backgroundColor:nil context:context];
        }
    }];
}

- (NSString *)getTimeString:(HistoryPriceData *)data
{
    //    NSTimeInterval time = [self.datas objectAtIndex:self.timeEndIdx].timestmp - [self.datas objectAtIndex:self.timeStartIdx].timestmp;
    //    if (time > 60 * 60 * 24 * 30 * 6) {
    //        return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"yyyy-MM"];
    //    } else if (time > 60 * 60 * 24 * 2) {
    //        return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"MM-dd"];
    //    } else {
    //        return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"MM-dd HH:mm"];
    //    }
    if (self.type == PriceHistoryViewTypeAsset){
        return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"MM-dd HH:mm"];
    }
    else{
        return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"yyyy-MM-dd HH:mm"];
    }
}

- (NSString *)getFocusTimeString:(HistoryPriceData *)data
{
    //   NSTimeInterval time = [self.datas objectAtIndex:self.timeEndIdx].timestmp - [self.datas objectAtIndex:self.timeStartIdx].timestmp;
    //    if (time > 60 * 60 * 24 * 30 * 6) {
    //        return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"yyyy-MM"];
    //    } else if (time > 60 * 60 * 24 * 2) {
    //        return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"MM-dd"];
    //    } else {
    //        return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"MM-dd HH:mm"];
    //    }
    return [[NSDate dateWithTimeIntervalSince1970:data.timestmp] toTimeStringWithFormat:@"yyyy-MM-dd HH:mm"];
}

- (CGPoint)getPoint:(HistoryPriceData *)data inRect:(CGRect)rect idx:(int)idx
{
    CGFloat contentSize = rect.size.width;
    if (self.showVolume) {
        CGFloat widthPer = contentSize / self.datas.count;
        return CGPointMake(self.contentOffset + rect.origin.x + widthPer * (idx + 0.5), [self getYWithPrice:data.price inRect:rect]);
    } else {
        CGFloat widthPer = contentSize / (self.datas.count - 1);
        return CGPointMake(self.contentOffset + rect.origin.x + widthPer * idx, [self getYWithPrice:data.price inRect:rect]);
    }
}

- (CGFloat)getYWithPrice:(double)price inRect:(CGRect)rect
{
    return rect.origin.y + (self.maxPrice - price) / (self.maxPrice - self.minPrice) * rect.size.height;
}

- (CGFloat)getXWithIdex:(int)idx
{
    return self.drawRect.origin.x + self.contentOffset + self.contentSize * idx / self.datas.count;
}

- (int)getIdxWithX:(CGFloat)x
{
    int idx = (x - self.contentOffset - self.drawRect.origin.x) / self.contentSize * (self.datas.count - 1) + 0.5;
    return idx;
}

- (void)onLongGesture:(UILongPressGestureRecognizer *)gesture
{
    //NSLog(@"---- %s", __func__);
    CGPoint location = [gesture locationInView:self];
    _focusPointY = location.y;
    UIGestureRecognizerState state = gesture.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:{
            self.focusIndex = [self getIdxWithX: location.x];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.focusIndex = [self getIdxWithX:location.x];
        }
            break;
        default:{
            //self.focusIndex = -1;
        }
            break;
    }
    [self setNeedsDisplay];
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
    NSLog(@"---- %s", __func__);
    if (self.isPanBacking) {
        if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
            self.isPanBacking = false;
        return;
    }
    
    CGPoint translationPoint = [panGesture translationInView:self];
    //NSLog(@"---- %lf", _focusPointY);
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.panTranslationPoint = translationPoint;
            CGPoint location = [panGesture locationInView:self];
            _focusPointY = location.y;
            if (self.focusIndex >= 0 && ABS([self getXWithIdex:self.focusIndex] - location.x) < 25) {
                self.isFocusPaning = true;
                self.focusIndex = [self getIdxWithX:location.x];
            }
        } break;
        case UIGestureRecognizerStateChanged:{
            if (self.isFocusPaning) {
                CGPoint location = [panGesture locationInView:self];
                _focusPointY = location.y;
                self.focusIndex = [self getIdxWithX:location.x];
            } else {
                self.focusIndex = -1;
                _contentOffset += (translationPoint.x - self.panTranslationPoint.x);
                _contentOffset = MAX(_contentOffset, self.drawRect.size.width - self.contentSize);
                _contentOffset = MIN(_contentOffset, 0);
            }
            self.panTranslationPoint = translationPoint;
            [self setNeedsDisplay];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.isFocusPaning = false;
            break;
            
        default:
            break;
    }
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinchGesture
{
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.pinchScale = pinchGesture.scale;
        } break;
        case UIGestureRecognizerStateChanged: {
            // 禁止缩放
            //            self.focusIndex = -1;
            //
            //            CGFloat scale = (- self.contentOffset + self.drawRect.size.width / 2) / self.contentSize;
            //            _contentSize = self.contentSize * pinchGesture.scale / self.pinchScale;
            //            _contentSize = MAX(self.contentSize, self.datas.count * kPriceHistoryViewMinWidth);
            //            _contentSize = MIN(self.contentSize, self.datas.count * kPriceHistoryViewMaxWidth);
            //            _contentOffset = - (self.contentSize * scale - self.drawRect.size.width / 2);
            //            _contentOffset = MAX(self.contentOffset, self.drawRect.size.width - self.contentSize);
            //            _contentOffset = MIN(self.contentOffset, 0);
            //            [self setNeedsDisplay];
            //            self.pinchScale = pinchGesture.scale;
        }
            break;
        default:
            break;
    }
}

- (void)onTap:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:self];
    _focusPointY = location.y;
    if (CGRectContainsPoint(self.touchAnhorRect, location)) {
        if (self.didSelectAnchor) self.didSelectAnchor(self.touchAnhorRect);
        self.focusIndex = -1;
    } else {
        if (self.focusIndex >= 0) {
            self.focusIndex = -1;
        } else {
            self.focusIndex = [self getIdxWithX:location.x];
        }
    }
    [self setNeedsDisplay];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.panGesture || gestureRecognizer == self.pinchGesture || gestureRecognizer == self.tapGesture) {
        return self.scrollable;
    }
    
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (id)gestureRecognizer;
        CGPoint point = [panGesture locationInView:self];
        CGPoint windowPoint = [self convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
        
        //CGFloat ViewPanBackLeftSpace = 30;
        if (windowPoint.x < 30) {
            self.isPanBacking = true;
            return true;
        }
        
        if (self.focusIndex != -1) return false;
        CGPoint translation = [panGesture translationInView:self];
        if (translation.x > 0) {
            return self.contentOffset == 0;
        } else {
            return (self.contentSize + self.contentOffset) <= self.drawRect.size.width;
        }
    }
    
    return false;
}

@end



