//
//  NSString+PriceVolumeFormatter.m
//  InjectionIIITest
//
//  Created by mengyun on 2019/5/2.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "NSString+PriceVolumeFormatter.h"
#define MinNumber 0.0000000001

@implementation NSString (PriceVolumeFormatter)

// 量
+(NSString *)formatterVolumeWith: (double )volume{
    if (volume<0)
        return [NSString stringWithFormat: @"-%@", [NSString formatterVolumeWith: 0-volume]];
    if (ABS(volume) < MinNumber) { // 0.00000001
        return @"0";
    }
    if (volume < 10000) {
        return formaterPrice(volume, 2);
    }
    return formaterWan(volume);
}
// 额
+(NSString *)formatterAmountWith: (double )amount{
    return [NSString formatterVolumeWith: amount];
}

+(NSString *)formatterPriceWith: (double )price isPairs: (BOOL) isPairs{
    if (ABS(price) < MinNumber) { // 0.00000001
        return @"0";
    }
    if (price < 1) {
        return formaterPrice(price, isPairs? 10 : 6);
    }
    if (price < 100) {
        return formaterPrice(price, 4);
    }
    if (price < 1000000) {
        return formaterPrice(price, 2);
    }
    return formaterPrice(price, 0);
}

// 法币价格
+(NSString *)formatterPriceWith: (double )price{
    return [NSString formatterPriceWith: price isPairs: false];
}

+(NSString *)formatterPriceWithNumber: (NSNumber *)priceNumber{
    return [NSString formatterPriceWith: [priceNumber doubleValue]];
}

//
NSString *formaterPrice(double price, NSInteger dot) {
    return formaterPriceMode(price, dot, true, NSRoundPlain);
}

// dot:精度, comma:千分符, mode:四舍五入模式
NSString *formaterPriceMode(double price, NSInteger dot, BOOL comma,NSRoundingMode mode) {
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

//
NSString *formaterWan(double value)
{
    NSString *volumeString = nil;
    //BOOL isCny = true;
    //if (isCny) {
    if (value >= 100000000*10000.0) {  // 大于万亿
        double tmp = value / (100000000*10000.0);
        NSString *tmpStr = formaterPrice(tmp, 2);
        volumeString = [NSString stringWithFormat:@"%@万亿", tmpStr];
    }
    else if (value >= 100000000) {  // 大于一亿
        double tmp = value / 100000000.;
        NSString *tmpStr = formaterPrice(tmp, 2);
        volumeString = [NSString stringWithFormat:@"%@亿", tmpStr];
    } else if (value >= 10000) { // 一万到一亿
        double tmp = value / 10000.;
        NSString *tmpStr = formaterPrice(tmp, 2);
        volumeString = [NSString stringWithFormat:@"%@万", tmpStr];
    } else {
        volumeString = formaterLimitPrice(value);
    }
    //    } else {
    //        if (value >= 1000. * 1000 * 1000) {
    //            volumeString = [NSString stringWithFormat:@"%.2fb",value / (1000. * 1000 * 1000)];
    //        } else if (value >= 1000 * 1000) {
    //            volumeString = [NSString stringWithFormat:@"%.2fm",value / (1000. * 1000)];
    //        } else if (value >= 1000) {
    //            volumeString = [NSString stringWithFormat:@"%.2fk",value / 1000.];
    //        } else {
    //            volumeString = formaterLimitPrice(value);
    //        }
    //    }
    
    return volumeString;
}

NSString *formaterLimitPrice(double price ) {
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
        tail = formaterPrice(price, 8);
    }
    else if (ABS(price) < 1000) {
        tail = formaterPrice(price, 4);
    }
    else if(ABS(price) < 10000){
        tail = formaterPrice(price, 2);
    }
    else {
        tail = formaterPrice(price, 0);
    }
    return [NSString stringWithFormat:@"%@%@", head, tail];
}

+(NSString *)formatterWalletAmountWith: (double )amount{
   return [NSString formatterWalletAmountWith: amount dot: 8];
}

+(NSString *)formatterWalletAmountWith: (double )amount dot: (int)dot{
    if (amount <= 0 )
        return @"0";
//    NSString *format = [NSString stringWithFormat: @"%%.%dlf", dot];

    int div = 10;
    if (dot<=2){
        div=100;
    }
    else if (dot<=4){
        div=10000;
    }
    else if (dot<=8){
        div=100000000;
    }
    else{
        div=1000000000;
    }
    CGFloat floor_num = floor(amount * div) / div;
    NSString *format = [NSString stringWithFormat: @"%%.%dlf", dot];
    NSString *s = [NSString stringWithFormat: format, floor_num];
    EDLog(@"formatterWalletAmountWith %d %d: %.19lf  %@",dot,div, amount, s);
    return s;
}

@end
