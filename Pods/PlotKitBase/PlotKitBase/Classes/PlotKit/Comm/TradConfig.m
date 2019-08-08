//
//  TradConfig.m
//  TrdingView
//
//  Created by Violet on 2017/10/6.
//  Copyright © 2017年 Violet. All rights reserved.
//

#import "TradConfig.h"
#import "ColorKit.h"
#import "KlinePrams.h"

@implementation TradConfig

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (CGSize)sizeForString:(NSString *)sourceStr
               withFont:(UIFont *)font
            minFontSize:(CGFloat)minFontSize
         actualFontSize:(CGFloat *)actualFontSize
               forWidth:(CGFloat)width
          lineBreakMode:(NSLineBreakMode)lineBreakMode
{
#if TARGET_OS_IPHONE || TARGET_OS_TV
    return [sourceStr sizeWithFont:(UIFont *)font
                       minFontSize:minFontSize
                    actualFontSize:actualFontSize
                          forWidth:width
                     lineBreakMode:lineBreakMode];

#else
    NSDictionary *attributes = @{NSFontAttributeName: font};
    return [sourceStr sizeWithAttributes:attributes];
#endif
}

+ (CGSize)drawString:(NSString *)sourceStr
              inRect:(CGRect)rect
            withFont:(UIFont *)font
       lineBreakMode:(NSLineBreakMode)lineBreakMode
           alignment:(NSTextAlignment)alignment
{
#if TARGET_OS_IPHONE || TARGET_OS_TV
    return [sourceStr drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
#else
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [sourceStr drawInRect:rect withAttributes:attributes];
    return CGSizeZero;
#endif
}

+ (CGSize)drawString:(NSString *)sourceStr
             atPoint:(CGPoint)point
            forWidth:(CGFloat)width
            withFont:(UIFont *)font
         minFontSize:(CGFloat)minFontSize
      actualFontSize:(CGFloat *)actualFontSize
       lineBreakMode:(NSLineBreakMode)lineBreakMode
  baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
#if TARGET_OS_IPHONE || TARGET_OS_TV
    return [sourceStr drawAtPoint:point
                         forWidth:width
                         withFont:font
                      minFontSize:minFontSize
                   actualFontSize:actualFontSize
                    lineBreakMode:lineBreakMode
               baselineAdjustment:baselineAdjustment];
#else
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [sourceStr drawAtPoint:point withAttributes:attributes];
    return CGSizeZero;
#endif
}

+ (CGSize)sizeForString:(NSString *)sourceStr withFont:(UIFont *)theFont
{
    if (sourceStr && theFont) {
        return [sourceStr sizeWithAttributes:@{NSFontAttributeName:theFont}];
    }
    
    return CGSizeZero;
}

+ (CGSize)drawString:(NSString *)sourceStr atPoint:(CGPoint)point withFont:(UIFont *)font
{
#if TARGET_OS_IPHONE || TARGET_OS_TV
    [sourceStr drawAtPoint:point withFont:font];
#else
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [sourceStr drawAtPoint:point withAttributes:attributes];
#endif

    return CGSizeZero;
}

//画文本
+ (CGFloat)drawLeftString:(NSString *)string atPoint:(CGPoint)point inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor context:(CGContextRef)context
{
    return [self drawString:string direction:1 atPoint:point inRect:rect font:font color:color backgroundColor:backgroundColor context:context];
}
+ (CGFloat)drawRightString:(NSString *)string atPoint:(CGPoint)point inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor context:(CGContextRef)context
{
    return [self drawString:string direction:2 atPoint:point inRect:rect font:font color:color backgroundColor:backgroundColor context:context];
}
+ (CGFloat)drawCenterString:(NSString *)string atPoint:(CGPoint)point inRect:(CGRect)rect font:(UIFont *)font  color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor context:(CGContextRef)context
{
    return [self drawString:string direction:3 atPoint:point inRect:rect font:font color:color backgroundColor:backgroundColor context:context];
}

//direction 1:left、 2:right、 3:center
+ (CGFloat)drawString:(NSString *)string direction:(int)direction atPoint:(CGPoint)point inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor context:(CGContextRef)context
{
    CGFloat width = 1000;
    CGSize drawSize = [TradConfig sizeForString:string
                                       withFont:font
                                    minFontSize:2
                                 actualFontSize:nil
                                       forWidth:width
                                  lineBreakMode:NSLineBreakByTruncatingHead];
    
    CGFloat offsetX = 0;
    CGFloat space = 0;
    if (backgroundColor) {
        space = 1;
        offsetX = 1;
    }
    CGFloat drawX = 0;
    switch (direction) {
        case 1:
            drawX = point.x - 2 * offsetX - drawSize.width;
            break;
        case 2:
            drawX = point.x + 2 * offsetX;
            break;
        case 3: {
            drawX = point.x - offsetX - drawSize.width / 2;
            drawX = MAX(rect.origin.x, drawX);
            drawX = MIN(drawX, CGRectGetMaxX(rect) - drawSize.width - 2 * offsetX);
        }
            break;

        default:
            break;
    }
    CGFloat drawY = MIN(MAX(point.y - drawSize.height / 2, space + rect.origin.y), CGRectGetMaxY(rect) - drawSize.height - space);
    if (backgroundColor) {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, CGRectMake(drawX - offsetX, drawY - space, drawSize.width + offsetX * 2, drawSize.height + space * 2));
    }
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    [TradConfig drawString:string
                   atPoint:CGPointMake(drawX, drawY)
                  forWidth:width
                  withFont:font
               minFontSize:2
            actualFontSize:nil
             lineBreakMode:NSLineBreakByTruncatingHead
        baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    return drawSize.width;
}

#pragma mark - 给View边框划线（分时图、K线图）
+ (void)drawBoundsInRect:(CGRect)rect color:(UIColor *)color innerLine:(NSInteger)lineNum context:(CGContextRef)context
{
    //[self drawBoundsInRect:rect color:color innerLine:lineNum offsetTop:0 context:context];
    [self drawBoundsInRect:rect colorHor:color colorVer:color innerLine:lineNum offsetTop: 0 context: context];
}

+ (void)drawBoundsInRect:(CGRect)rect color:(UIColor *)color innerLine:(NSInteger)lineNum offsetTop:(CGFloat)top context:(CGContextRef)context;
{
    [self drawBoundsInRect:rect colorHor:color colorVer:color innerLine:lineNum offsetTop:0 context:context];
}

+ (void)drawBoundsInRect:(CGRect)rect  colorHor:(UIColor *)colorHor colorVer:(UIColor *)colorVer innerLine:(NSInteger)lineNum offsetTop:(CGFloat)top context:(CGContextRef)context
{
    CGContextSaveGState(context);
    NSInteger drawX, drawY;
//    CGFloat   dash[2] = {1.0, 2.0};
    CGFloat outWidth = 3.0;
    CGContextSetLineWidth(context, 0.6);

    // 横轴线
    for (int i = 0; i < lineNum; i++) {
        drawX = rect.origin.x;
        drawY = rect.origin.y + (rect.size.height - 1) / (lineNum + 1) * (i + 1);
        
        CGContextSetStrokeColorWithColor(context, colorHor.CGColor);
//        CGContextSetLineDash(context, 0, dash, 1);//虚线
        CGContextSetLineDash(context, 0, NULL, 0);

        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        drawX = rect.origin.x + rect.size.width;
        
        CGContextAddLineToPoint(context, drawX, drawY + 0.5);
        CGContextStrokePath(context);
    }
    //刻度线
    for (int i = 0; i < lineNum; i++) {
        drawX = rect.origin.x + rect.size.width;
        drawY = rect.origin.y + (rect.size.height - 1) / (lineNum + 1) * (i + 1);
        
        CGContextSetStrokeColorWithColor(context, colorVer.CGColor);
        CGContextSetLineDash(context, 0, NULL, 0);
        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        CGContextAddLineToPoint(context, drawX + outWidth, drawY + 0.5);
        CGContextStrokePath(context);
    }
    
    rect.origin.y += top;
    rect.size.height -= top;
    // 边框
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetStrokeColorWithColor(context, colorHor.CGColor);
    for (int i = 0; i < 2; i++) {//上下2条线
        drawX = rect.origin.x;
        drawY = rect.origin.y + (rect.size.height - 1) * i;
        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        drawX = rect.origin.x + rect.size.width;
        CGContextAddLineToPoint(context, drawX, drawY + 0.5);
        CGContextStrokePath(context);
    }
    CGContextSetStrokeColorWithColor(context, colorVer.CGColor);
    for (int i = 0; i < 2; i++) { //上下2条刻度线
        drawX = rect.origin.x + rect.size.width;
        drawY = rect.origin.y + (rect.size.height - 1) * i;
        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        CGContextAddLineToPoint(context, drawX + outWidth, drawY + 0.5);
        CGContextStrokePath(context);
    }
    
//    CGContextSetStrokeColorWithColor(context, colorVer.CGColor);
//    for (int i = 1; i < 2; i++) {//右线
//        drawX = rect.origin.x + (rect.size.width - 1) * i;
//        drawY = rect.origin.y;
//        CGContextMoveToPoint(context, drawX + 0.5, drawY);
//        drawY = rect.origin.y + rect.size.height;
//        CGContextAddLineToPoint(context, drawX + 0.5, drawY);
//        CGContextStrokePath(context);
//    }

    CGContextRestoreGState(context);
}

+ (void)drawLinesInRect:(CGRect)rect color:(UIColor *)color number:(NSInteger)number context:(CGContextRef)context{
    [self drawLinesInRect:rect
                    color:color
               boundColor:color
                   number:number
                  context:context];
}

+ (void)drawLinesInRect:(CGRect)rect color:(UIColor *)color boundColor:(UIColor *)boundColor number:(NSInteger)number context:(CGContextRef)context
{
    CGContextSaveGState(context);
    NSInteger drawX, drawY;
    CGFloat   dash[2] = {1.0, 2.0};
    
    CGContextSetLineWidth(context, 0.6);
    for (int i = 0; i < number; i++) {
        drawX = rect.origin.x;
        drawY = rect.origin.y + (rect.size.height - 1) / (number - 1) * i;
        
        CGContextSetStrokeColorWithColor(context, color.CGColor);
//        if (i == number - 1) {
//            CGContextSetLineDash(context, 0, dash, 0);
//            drawY += 1;
//        } else {
//            CGContextSetLineDash(context, 0, dash, 0);
//        }
        CGContextSetLineDash(context, 0, dash, 0);
        
        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        drawX = rect.origin.x + rect.size.width;
        
        CGContextAddLineToPoint(context, drawX, drawY + 0.5);
        CGContextStrokePath(context);
    }
    
    CGContextSetLineWidth(context, 1);
    for (int i = 0; i < number; i++) {
        drawX = rect.origin.x + rect.size.width;
        drawY = rect.origin.y + (rect.size.height - 1) / (number - 1) * i;
        
        CGContextSetStrokeColorWithColor(context, boundColor.CGColor);
        
        CGContextMoveToPoint(context, drawX, drawY + 0.5);
        drawX = rect.origin.x + rect.size.width;
        
        CGContextAddLineToPoint(context, drawX+3, drawY + 0.5);
        CGContextStrokePath(context);
    }
    CGContextSetStrokeColorWithColor(context, boundColor.CGColor);
    
//    // 补充右边竖线
//    CGContextMoveToPoint(context, rect.origin.x + rect.size.width, rect.origin.y - 0.5);
//    drawX = rect.origin.x + rect.size.width;
//    
//    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
//    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

+ (void)drawLineInRect:(CGPoint)start end:(CGPoint)end color:(UIColor *)color context:(CGContextRef)context;
{
    CGContextSetLineWidth(context, 0.6);
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddLineToPoint(context, end.x, end.y);
    CGContextStrokePath(context);
}

//
+ (void)drawGridInRect:(CGRect)rect
             lineColor:(UIColor *)lineColor
           boundsColor:(UIColor *)boundsColor
     horizontalLineNum:(NSInteger)hNum
       verticalLineNum:(NSInteger)vNum  //竖线条数
               context:(CGContextRef)context{
    
    CGContextSaveGState(context);
    NSInteger drawX, drawY;
    
    // 画横线
    CGFloat deltaY = (rect.size.height - 1) / (vNum - 1);
    CGContextSetLineWidth(context, 0.5);
    for (int i = 0; i < vNum; i++) {
        drawX = rect.origin.x;
        drawY = rect.origin.y + deltaY * i;
        CGContextMoveToPoint(context, drawX, drawY);
        
        if (i==0 || i==vNum-1)
            CGContextSetStrokeColorWithColor(context, boundsColor.CGColor);
        else
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        drawX = rect.origin.x + rect.size.width;
        CGContextAddLineToPoint(context, drawX, drawY);
        CGContextStrokePath(context);
    }
    
    // 画竖线
    CGFloat deltaX = (rect.size.width - 1) / (hNum - 1);
    CGContextSetLineWidth(context, 0.5);
    for (int i = 0; i < hNum; i++) {
        drawX = rect.origin.x + deltaX * i;
        drawY = rect.origin.y;
        CGContextMoveToPoint(context, drawX, drawY);
        
        if (i==0 || i==hNum-1)
            CGContextSetStrokeColorWithColor(context, boundsColor.CGColor);
        else
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        drawY = rect.origin.y + rect.size.height;
        CGContextAddLineToPoint(context, drawX, drawY);
        CGContextStrokePath(context);
    }
    
    CGContextRestoreGState(context);
    
}

#pragma clang diagnostic pop


@end
