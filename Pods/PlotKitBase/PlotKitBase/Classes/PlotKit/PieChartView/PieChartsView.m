//
//  PieChartsView.m
//  GoIco
//
//  Created by zhulihong on 2017/10/24.
//  Copyright © 2017年 ico. All rights reserved.
//

#import "PieChartsView.h"

#define kPieChartsColors @[[UIColor redColor], [UIColor greenColor], [UIColor orangeColor], [UIColor yellowColor]]

#define kAnimationDuration 1.0f
#define kPieFillColor [UIColor clearColor].CGColor

#define kLabelLoctionRatio (1.2*bgRadius)


@interface PieChartsView ()

@property (nonatomic) CGFloat total;
@property (nonatomic) CAShapeLayer *bgCircleLayer;

@property (strong, nonatomic) NSArray *arcLayers;
@property (strong, nonatomic) NSArray *labels;

@end

@implementation PieChartsView

@synthesize colors = _colors;
@synthesize pies = _pies;

- (NSArray<UIColor *> *)colors
{
	if (!_colors) {
		_colors = kPieChartsColors;
	}

	return _colors;
}

- (void)setColors:(NSArray<UIColor *> *)colors
{
    if ([_colors isEqualToArray:colors]) return;
    
    _colors = colors;
    [self updateUI];
}

- (void)setPies:(NSArray *)pies
{
    if ([_pies isEqualToArray:pies]) return;

    _pies = pies;
    [self updateUI];
}

- (void)setLabelTitles:(NSArray<NSString *> *)labelTitles
{
    _labelTitles = labelTitles;
    [self updateUI];
}

- (void)updateUI
{
    self.layer.mask = nil;
    [self.arcLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];

    //1.pieView中心点
    CGFloat centerWidth = self.frame.size.width * 0.5f;
    CGFloat centerHeight = self.frame.size.height * 0.5f;
    CGFloat centerX = centerWidth;
    CGFloat centerY = centerHeight;
    CGPoint centerPoint = CGPointMake(centerX, centerY);
    CGFloat radiusBasic = MIN(centerWidth, centerHeight);
    
    //计算红绿蓝部分总和
    CGFloat total = 0.0f;
    for (int i = 0; i < self.pies.count; i++) {
        total += [self.pies[i] floatValue];
    }
    
    CGFloat hollow = self.isHollow ? 0.6 : 0;
    CGFloat offsetAngle = 0;
    //2.背景
    CGFloat bgRadius = radiusBasic / 2;
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                          radius:bgRadius * (1 + hollow)
                                                      startAngle:-M_PI_2 + offsetAngle
                                                        endAngle:M_PI_2 * 3 + offsetAngle
                                                       clockwise:YES];
    self.bgCircleLayer = [CAShapeLayer layer];
    self.bgCircleLayer.fillColor   = [UIColor clearColor].CGColor;
    self.bgCircleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    self.bgCircleLayer.strokeStart = 0.0f;
    self.bgCircleLayer.strokeEnd   = 1.0f;
    self.bgCircleLayer.zPosition   = 1;
    self.bgCircleLayer.lineWidth   = bgRadius * 2.0f * (1 - hollow);
    self.bgCircleLayer.path        = bgPath.CGPath;
    
    //3.扇区路径
    CGFloat otherRadius = radiusBasic * 0.5;
    UIBezierPath *otherPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                             radius:otherRadius
                                                         startAngle:-M_PI_2 + offsetAngle
                                                           endAngle:M_PI_2 * 3 + offsetAngle
                                                          clockwise:YES];
    NSMutableArray *arcLayers = [NSMutableArray array];
    NSMutableArray *labels = [NSMutableArray array];
    CGFloat start = 0.0f;
    CGFloat end = 0.0f;
    for (int i = 0; i < self.pies.count; i++) {
        //4.计算当前end位置 = 上一个结束位置 + 当前部分百分比
        end = [self.pies[i] floatValue] / (total == 0 ? 1 : total) + start;
        if (isnan(end)) end = start;
        //图层
        CAShapeLayer *pie = [CAShapeLayer layer];
        [self.layer addSublayer:pie];
        [arcLayers addObject:pie];
        pie.fillColor   = kPieFillColor;
        if (self.colors.count > 0) {
            pie.strokeColor = ((UIColor *)self.colors[i % self.colors.count]).CGColor;
        } else {
            pie.strokeColor = [UIColor grayColor].CGColor;
        }
        pie.strokeStart = start;
        pie.strokeEnd   = end;
        pie.lineWidth   = otherRadius * 2.0f;
        pie.zPosition   = 2;
        pie.path        = otherPath.CGPath;
        
        if (self.showLabel) {
            double moreSacle = 0.15;
            double sacle = MAX(MIN(1 + moreSacle - moreSacle * ((end - start - 0.05) / 0.1), 1 + moreSacle), 1);
            //计算百分比label的位置
            CGFloat centerAngle = M_PI * (start + end);
            CGFloat labelCenterX = kLabelLoctionRatio * (1 + hollow / 2) * sinf(centerAngle) * sacle + centerX;
            CGFloat labelCenterY = -kLabelLoctionRatio * (1 + hollow / 2) * cosf(centerAngle) * sacle + centerY;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 88, 88)];
            label.numberOfLines = 3;
            if (self.font) label.font = self.font;
            if (i < self.labelTitles.count) {
                CGFloat percent = 100 * [self.pies[i] doubleValue];
                label.text = [NSString stringWithFormat: @"%@\n%.2f%%", self.labelTitles[i], percent];
            } else {
//                label.text = [NSString stringWithFormat:@"%ld%%",(NSInteger)((end - start + 0.005) * 100)];
            }
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithWhite:222/255.0 alpha: 0.9];
            label.layer.zPosition = 3;
            [label sizeToFit];
            label.center = CGPointMake(labelCenterX, labelCenterY);
            [self addSubview:label];
            [labels addObject:label];
            
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            [self.layer addSublayer:lineLayer];
            [arcLayers addObject:lineLayer];
            // 线的路径
            UIBezierPath *linePath = [UIBezierPath bezierPath];
            [linePath moveToPoint:centerPoint];
            CGFloat startAngle = M_PI * start * 2;
            [linePath addLineToPoint:CGPointMake(centerX + bgRadius * 2 * sinf(startAngle), centerY - bgRadius * 2 * cosf(startAngle))];
            lineLayer.lineWidth = 1.5;
            lineLayer.zPosition   = 3;
            lineLayer.strokeColor = [UIColor whiteColor].CGColor;
            lineLayer.path = linePath.CGPath;
            lineLayer.fillColor = nil; // 默认为blackColor
        }
        
        //计算下一个start位置 = 当前end位置
        start = end;
    }
    self.arcLayers = arcLayers;
    self.labels = labels;
    self.layer.mask = self.bgCircleLayer;
}

- (void)strokeAnimation
{
    //画图动画
    self.hidden = NO;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration  = kAnimationDuration;
    animation.fromValue = @0.0f;
    animation.toValue   = @1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [self.bgCircleLayer addAnimation:animation forKey:@"circleAnimation"];
}

- (void)dealloc
{
    [self.layer removeAllAnimations];
}

@end
