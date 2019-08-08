//
//  NSString+Size.m
//  PlotKitTest
//
//  Created by DFG on 2019/3/27.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "NSString+Size.h"
#define MinNumber 0.0000000001

NSString *removeLastZero_pkb(NSString *dStr) {
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:dStr];
    return [dn stringValue];
}

// dot:精度, comma:千分符, mode:四舍五入模式
NSString *formarterPrice_pkbMode_pkb(double price, NSInteger dot, BOOL comma,NSRoundingMode mode) {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithDecimal:@(price).decimalValue];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:mode
                                                                                                      scale:dot
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    NSString *tempStr =[[number decimalNumberByRoundingAccordingToBehavior:roundingBehavior] stringValue];
    if (!comma)
        return tempStr;
    
    NSArray *stringArr = [tempStr componentsSeparatedByString:@"."];
    NSMutableString *stringDot = [NSMutableString string];
    NSString *string = stringArr.firstObject;
    NSString *prefix = @"";
    if ([string hasPrefix:@"-"]) {
        string = [string substringFromIndex:1];
        prefix = @"-";
    }
    for (int idx = 1; 3 < string.length; idx ++) {
        [stringDot insertString:[NSString stringWithFormat:@",%@", [string substringFromIndex:string.length - 3]] atIndex:0];
        string = [string substringToIndex:string.length - 3];
    }
    [stringDot insertString:string atIndex:0];
    if (stringArr.count > 1) {
        [stringDot appendFormat:@".%@", stringArr.lastObject];
    }
    [stringDot insertString:prefix atIndex:0];
    
    return stringDot;
}

NSString *formarterPrice_pkb(double price, NSInteger dot) {
    return formarterPrice_pkbMode_pkb(price, dot, true, NSRoundPlain);
}

NSString *formarterLimitPrice_pkb(double price ) {
    NSString *head = @"";
    NSString *tail = @"";
    if (price<0){
        head = @"-";
        price = 0-price;
    }
    if (ABS(price) < 0.00000001) {
        return @"0";
    }
    
    if (ABS(price) < 1) {
        tail = formarterPrice_pkb(price, 8);
    }
    else if (ABS(price) < 1000) {
        tail = formarterPrice_pkb(price, 4);
    }
    else if(ABS(price) < 10000){
        tail = formarterPrice_pkb(price, 2);
    }
    else {
        tail = formarterPrice_pkb(price, 0);
    }
    return [NSString stringWithFormat:@"%@%@", head, tail];
}

NSString *formatterWan_pkb(double value)
{
    NSString *volumeString = nil;
    
    BOOL ISCNY = true;
    if (ISCNY) {
        if (value >= 100000000) {
            volumeString = [NSString stringWithFormat:@"%.2f亿",value / 100000000.];
        } else if (value >= 10000) {
            volumeString = [NSString stringWithFormat:@"%.2f万",value / 10000.];
        } else {
            volumeString = formarterLimitPrice_pkb(value);
        }
    } else {
        if (value >= 1000. * 1000 * 1000) {
            volumeString = [NSString stringWithFormat:@"%.2fb",value / (1000. * 1000 * 1000)];
        } else if (value >= 1000 * 1000) {
            volumeString = [NSString stringWithFormat:@"%.2fm",value / (1000. * 1000)];
        } else if (value >= 1000) {
            volumeString = [NSString stringWithFormat:@"%.2fk",value / 1000.];
        } else {
            volumeString = formarterLimitPrice_pkb(value);
        }
    }
    
    return volumeString;
}

NSString *formatterKlinePrice_pkb(double price) {
    if (ABS(price) < 0.0000000001) { // 0.00000001
        return @"0";
    }
    if (price < 0.00000001) {
        return formarterPrice_pkb(price, 10);
    }
    if (price < 0.001) {
        return formarterPrice_pkb(price, 8);
    }
    if (price < 1) {
        return formarterPrice_pkb(price, 6);
    }
    if (price < 100) {
        return formarterPrice_pkb(price, 4);
    }
    if (price > 1000000) {
        return formatterWan_pkb(price);
    }
    
    return formarterPrice_pkb(price, 2);
}

@implementation NSString (Size)

- (CGFloat)widthWithFont:(UIFont *)font
{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentLeft;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, paragraph, NSParagraphStyleAttributeName, nil];
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    
    return ceilf(rect.size.width);
}

+(NSString *)formatterVolumeWith: (double )volume{
    if (volume<0)
        return [NSString stringWithFormat: @"-%@", [NSString formatterVolumeWith: 0-volume]];
    if (ABS(volume) < MinNumber) { // 0.00000001
        return @"0";
    }
    if (volume < 10000) {
        return formaterPrice_pkb(volume, 2);
    }
    return formaterWan_pkb(volume);
}

NSString *formaterWan_pkb(double value)
{
    NSString *volumeString = nil;
    //BOOL isCny = true;
    //if (isCny) {
    if (value >= 100000000*10000.0) {  // 大于万亿
        double tmp = value / (100000000*10000.0);
        NSString *tmpStr = formaterPrice_pkb(tmp, 2);
        volumeString = [NSString stringWithFormat:@"%@万亿", tmpStr];
    }
    else if (value >= 100000000) {  // 大于一亿
        double tmp = value / 100000000.;
        NSString *tmpStr = formaterPrice_pkb(tmp, 2);
        volumeString = [NSString stringWithFormat:@"%@亿", tmpStr];
    } else if (value >= 10000) { // 一万到一亿
        double tmp = value / 10000.;
        NSString *tmpStr = formaterPrice_pkb(tmp, 2);
        volumeString = [NSString stringWithFormat:@"%@万", tmpStr];
    } else {
        volumeString = formaterLimitPrice_pkb(value);
    }
    //    } else {
    //        if (value >= 1000. * 1000 * 1000) {
    //            volumeString = [NSString stringWithFormat:@"%.2fb",value / (1000. * 1000 * 1000)];
    //        } else if (value >= 1000 * 1000) {
    //            volumeString = [NSString stringWithFormat:@"%.2fm",value / (1000. * 1000)];
    //        } else if (value >= 1000) {
    //            volumeString = [NSString stringWithFormat:@"%.2fk",value / 1000.];
    //        } else {
    //            volumeString = formaterLimitPrice_pkb(value);
    //        }
    //    }
    
    return volumeString;
}

NSString *formaterPrice_pkb(double price, NSInteger dot) {
    return formaterPrice_pkbMode_pkb(price, dot, true, NSRoundPlain);
}

// dot:精度, comma:千分符, mode:四舍五入模式
NSString *formaterPrice_pkbMode_pkb(double price, NSInteger dot, BOOL comma,NSRoundingMode mode) {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithDecimal:@(price).decimalValue];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:mode
                                                                                                      scale:dot
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    NSString *tempStr =[[number decimalNumberByRoundingAccordingToBehavior:roundingBehavior] stringValue];
    if (!comma)
        return tempStr;
    
    NSArray *stringArr = [tempStr componentsSeparatedByString:@"."];
    NSMutableString *stringDot = [NSMutableString string];
    NSString *string = stringArr.firstObject;
    NSString *prefix = @"";
    if ([string hasPrefix:@"-"]) {
        string = [string substringFromIndex:1];
        prefix = @"-";
    }
    for (int idx = 1; 3 < string.length; idx ++) {
        [stringDot insertString:[NSString stringWithFormat:@",%@", [string substringFromIndex:string.length - 3]] atIndex:0];
        string = [string substringToIndex:string.length - 3];
    }
    [stringDot insertString:string atIndex:0];
    if (stringArr.count > 1) {
        [stringDot appendFormat:@".%@", stringArr.lastObject];
    }
    [stringDot insertString:prefix atIndex:0];
    
    return stringDot;
}

NSString *formaterLimitPrice_pkb(double price ) {
    NSString *head = @"";
    NSString *tail = @"";
    if (price<0){
        head = @"-";
        price = 0-price;
    }
    if (ABS(price) < 0.00000001) {
        return @"0";
    }
    
    if (ABS(price) < 1) {
        tail = formaterPrice_pkb(price, 8);
    }
    else if (ABS(price) < 1000) {
        tail = formaterPrice_pkb(price, 4);
    }
    else if(ABS(price) < 10000){
        tail = formaterPrice_pkb(price, 2);
    }
    else {
        tail = formaterPrice_pkb(price, 0);
    }
    return [NSString stringWithFormat:@"%@%@", head, tail];
}

@end
