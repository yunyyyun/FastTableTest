//
//  TradConfig.h
//  TrdingView
//
//  Created by Violet on 2017/10/6.
//  Copyright © 2017年 Violet. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

@interface TradConfig : NSObject

+ (CGSize)sizeForString:(NSString *)sourceStr
               withFont:(UIFont *)font
            minFontSize:(CGFloat)minFontSize
         actualFontSize:(CGFloat *)actualFontSize
               forWidth:(CGFloat)width
          lineBreakMode:(NSLineBreakMode)lineBreakMode;

+ (CGSize)drawString:(NSString *)sourceStr
             atPoint:(CGPoint)point
            forWidth:(CGFloat)width
            withFont:(UIFont *)font
         minFontSize:(CGFloat)minFontSize
      actualFontSize:(CGFloat *)actualFontSize
       lineBreakMode:(NSLineBreakMode)lineBreakMode
  baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment;

+ (CGSize)drawString:(NSString *)sourceStr
              inRect:(CGRect)rect
            withFont:(UIFont *)font
       lineBreakMode:(NSLineBreakMode)lineBreakMode
           alignment:(NSTextAlignment)alignment;

+ (CGSize)sizeForString:(NSString *)sourceStr withFont:(UIFont *)theFont;

+ (CGSize)drawString:(NSString *)sourceStr atPoint:(CGPoint)point withFont:(UIFont *)font;

//画文本
+ (CGFloat)drawLeftString:(NSString *)string atPoint:(CGPoint)point inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor context:(CGContextRef)context;
+ (CGFloat)drawRightString:(NSString *)string atPoint:(CGPoint)point inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor context:(CGContextRef)context;
+ (CGFloat)drawCenterString:(NSString *)string atPoint:(CGPoint)point inRect:(CGRect)rect font:(UIFont *)font  color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor context:(CGContextRef)context;

#pragma mark - 给View边框划线（分时图、K线图）

+ (void)drawBoundsInRect:(CGRect)rect color:(UIColor *)color innerLine:(NSInteger)lineNum context:(CGContextRef)context;

+ (void)drawBoundsInRect:(CGRect)rect
                   color:(UIColor *)color
               innerLine:(NSInteger)lineNum
               offsetTop:(CGFloat)top
                 context:(CGContextRef)context;

+ (void)drawBoundsInRect:(CGRect)rect
                colorHor:(UIColor *)colorHor
                colorVer:(UIColor *)colorVer
               innerLine:(NSInteger)lineNum
               offsetTop:(CGFloat)top
                 context:(CGContextRef)context;


//画线
+ (void)drawLinesInRect:(CGRect)rect color:(UIColor *)color number:(NSInteger)number context:(CGContextRef)context;
+ (void)drawLinesInRect:(CGRect)rect
                  color:(UIColor *)color
                  boundColor:(UIColor *)color
                 number:(NSInteger)number
                context:(CGContextRef)context;

+ (void)drawLineInRect:(CGPoint)start end:(CGPoint)end color:(UIColor *)color context:(CGContextRef)context;

+ (void)drawGridInRect:(CGRect)rect
             lineColor:(UIColor *)lineColor
           boundsColor:(UIColor *)boundsColor
     horizontalLineNum:(NSInteger)hNum
       verticalLineNum:(NSInteger)vNum  //竖线条数
               context:(CGContextRef)context;

@end
