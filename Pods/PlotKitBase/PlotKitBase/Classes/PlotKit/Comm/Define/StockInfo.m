//
//  StockInfo.m
//  KLine
//
//  Created by Violet on 2017/10/7.
//  Copyright © 2017年 Violet. All rights reserved.
//

#import "StockInfo.h"
#import "NumberKit.h"
#import "KlinePrams.h"
#import "NSString+Size.h"

@implementation StockInfo

- (NSString *)stringOfAmount:(double)amount; //格式化输出成交额
{
    if (dequalzero(amount)) {
        return NoneInfoText;
    }
    else if (amount < 0) {
        return NoneInfoText;
    }
    
    return formatBigPriceValueWithDigits(amount ,TradeAmountDigitsNum);
}
//格式化输出成交量，withUnit:YES，附加单位 “股”， "手"等
- (NSString *)stringOfVolume:(double)volume withUnit:(BOOL)withUnit; //格式化输出成交量
{
    return [self stringOfPrice:volume];
}
- (NSString *)stringOfPrice:(double)price; //格式化输出价格，价格是0时默认显示--
{
    if (ABS(price) < 0.00000001) {
        return @"0";
    }
    if (ABS(price) < 1) {
        return [NSString stringWithFormat:@"%.8f",price];// removeLastZero_pkb([NSString stringWithFormat:@"%.8f",price]);
    }
    if (ABS(price) < 1000) {
        return [NSString stringWithFormat:@"%.4f",price];//removeLastZero_pkb([NSString stringWithFormat:@"%.4f",price]);
    }
    
    return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:((long long)(price * 100)) / 100.] numberStyle:NSNumberFormatterDecimalStyle];
}

@end


