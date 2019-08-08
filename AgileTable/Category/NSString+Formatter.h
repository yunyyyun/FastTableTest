//
//  NSString+Formatter.h
//  GoIco
//
//  Created by Andy on 2017/8/12.
//  Copyright © 2017年 ico. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOUBLE_ZERO_ERROR       0.00000001   //浮点0值误差

// 转换法币价格
NSString *formarterPriceForLegalCurrency(double price);
// 转换交易对价格
NSString *formarterPriceForPairs(double price);

//正负号
NSString *dotChange(double change);

//只用该方法
NSString *removeLastZero(NSString *dStr);
NSString *formarterLimitPrice(double price);
NSString *formarterLimitPriceWithScale(double price, int scale);
double priceFromString(NSString *string);
// dot:精度, comma:千分符, mode:四舍五入模式
NSString *formarterPriceMode(double price, NSInteger dot, BOOL comma,NSRoundingMode mode);
NSString *formarterPrice(double price, NSInteger dot);//价格,取dot位小数
NSString *formarterPriceNoDot(double price, NSInteger dot);//价格,取dot位小数 无千分符
double getPriceLetterDot(double price);//获取最小位数数值

//kline
NSString *formatterKlinePrice(double price);

@interface NSString (Formatter)

+ (NSString *)spaceNumber:(long long)number;
+ (NSString *)spaceNumber:(long long)number dot:(int)dot;

- (NSDictionary *)getUrlParamters;
+ (NSString *)timeWithMonthDayTimeIntervalString:(NSTimeInterval)timeString;
+ (NSString *)timeWithHourMinTimeIntervalString:(NSTimeInterval)timeString;
+ (NSString *)timeWithTimeIntervalString:(NSTimeInterval)timeString;
+ (NSString *)timeymdhsWithTimeIntervalString:(NSTimeInterval)timeString;
+ (NSString *)timeymdhsWithTimeIntervalString:(NSTimeInterval)timeString formatter:(NSString *)formater;

- (NSString *)URLDecode;
- (NSString *)URLEncode;
- (NSString *)addPrefixWithPercent:(double)percent;

- (NSString *)md5;
- (NSString *)sha;
- (NSData *)dataHmacSHA256WithKey:(NSString *)key;
- (NSString *)hmacSHA256WithKey:(NSString *)key;
- (NSString *)hmacMD5WithKey:(NSString *)keyStr;

+ (NSString *)randomChar:(NSInteger)count;
//返回大小写字母和数字
+ (NSString *)randomLetterAndNumber:(int)count;

// 3->3%
+ (NSString *)formatPercentFromChange:(id)change;

@end
