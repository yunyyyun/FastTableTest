//
//  NumberKit.m
//  TZYJ_IPhone
//
//  Created by Mernushine on 17/4/19.
//
//

#import "NumberKit.h"

@implementation NumberKit

#pragma mark - 与0比较，考虑精度
BOOL lowerThanOrEqualToZero(double value)
{
    return (value < -FLOAT_ZERO_ERROR) || zeroValue(value);
}

BOOL zeroValue(double value)
{
    return value > -FLOAT_ZERO_ERROR && value < FLOAT_ZERO_ERROR;
}

/**
 *  将numberValue类型的数据，按照保留decimals个小数后，返回格式化的字符串\n
 规则：四舍五入
 numberValue类型可以是：NSString, NSNumber
 */
NSString *formatNumberWithNumberValueAndDecimals(id numberValue ,NSInteger decimals){
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    if(decimals == 1) {
        [numberFormatter setPositiveFormat:@"#####0.0;"];
    }
    else if(decimals == 2) {
        [numberFormatter setPositiveFormat:@"#####0.00;"];
    }
    else if(decimals == 3) {
        [numberFormatter setPositiveFormat:@"#####0.000;"];
    }
    else if(decimals == 4) {
        [numberFormatter setPositiveFormat:@"#####0.0000;"];
    }
    else {
        [numberFormatter setPositiveFormat:@"#####0;"];
    }
    
    NSNumber *number = [NSNumber numberWithFloat:0.0f];
    if ([numberValue isKindOfClass:[NSNumber class]]) {
        number = numberValue;
    }
    else if ([numberValue isKindOfClass:[NSString class]]) {
        number = [NSNumber numberWithDouble:[numberValue doubleValue]];
    }
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:number];
    return formattedNumberString;
    
}

/**
 *  将double类型的数据，按照保留decimals个小数后，返回格式化的字符串
 *  规则：四舍五入
 */
NSString *formatNumberWithDoubleAndDecimals(double doubleValue ,NSInteger decimals){
    return formatNumberWithNumberValueAndDecimals([NSNumber numberWithDouble:doubleValue + FLOAT_ZERO_ERROR], decimals);
}

#pragma mark - ********* format price money
/**
 *  大额资产数据转换成千亿、亿、万等，还是参考恒生的做法
 *
 *  @param priceValue 一般是大额资产数据
 *  @param digits     小数位数
 */
NSString *formatBigPriceValueWithDigits(long double priceValue, NSInteger digits) {
    if (priceValue < FLOAT_ZERO_ERROR && priceValue > FLOAT_ZERO_ERROR * -1) {
        return @"0.00";
    }
    
    priceValue += FLOAT_ZERO_ERROR;
    
    
    NSMutableString *formatString = [NSMutableString string];
    
    if (fabsl(priceValue) > 1000000000000) { //****万亿
        [formatString appendString:@"%."];
        //千万亿级别去掉小数
        if (fabsl(priceValue) > 1000000000000000) {
            [formatString appendFormat:@"%dLf", 0];
        }
        //百万亿级别比10万亿级别少保留一位小数
        else if (fabsl(priceValue) > 100000000000000) {
            if (digits >= 2) {
                [formatString appendFormat:@"%zdLf", digits - 1];
            }
            else {
                [formatString appendFormat:@"%dLf", 0];
            }
        }
        else {
            //10万亿、个万亿保留小数
            [formatString appendFormat:@"%zdLf", digits];
        }
        
        [formatString appendString:@"万亿"];
        
        return [NSString stringWithFormat:formatString, priceValue / 1000000000000];
        
    }
    else if (fabsl(priceValue) > 100000000) { //****亿
        [formatString appendString:@"%."];
        
        //千亿级别去掉小数
        if (fabsl(priceValue) > 100000000000) {
            [formatString appendFormat:@"%dLf", 0];
        }
        //百亿级别比10亿级别少保留一位小数
        else if (fabsl(priceValue) > 10000000000) {
            if (digits >= 2) {
				[formatString appendFormat:@"%ldLf", digits - 1];
            }
            else {
                [formatString appendFormat:@"%dLf", 0];
            }
        }
        else {
            //10亿、个亿保留小数
			[formatString appendFormat:@"%ldLf", (long)digits];
        }
        
        [formatString appendString:@"亿"];
        
        return [NSString stringWithFormat:formatString, priceValue / 100000000];
        
    }
    else if (fabsl(priceValue) > 99999) { //****万
        [formatString appendString:@"%."];
        //千万级别去掉小数
        if (fabsl(priceValue) > 10000000) {
            [formatString appendFormat:@"%dLf", 0];
        }
        //百万级别比10万级别少保留一位小数
        else if (fabsl(priceValue) > 1000000) {
            if (digits >= 2) {
				[formatString appendFormat:@"%ldLf", digits - 1];
            }
            else {
                [formatString appendFormat:@"%dLf", 0];
            }
        }
        else {
            //10万、个万保留小数
			[formatString appendFormat:@"%ldLf", (long)digits];
        }
        
        [formatString appendString:@"万"];
        
        return [NSString stringWithFormat:formatString, priceValue / 10000];
    }
    else {
        return [NSString stringWithFormat:@"%.0Lf", priceValue];
    }
}

@end

