//
//  DateKit.m
//  TZYJ_IPhone
//
//  Created by Mernushine on 17/4/19.
//
//

#import "DateKit.h"

@implementation DateKit

/*!转换为format(yyyy-MM-dd HH:mm)格式
 */
+ (NSString *)toTimeString:(NSTimeInterval)timestemp format:(NSString *)format
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = threadDictionary[@"mydateformatter"];
    @synchronized(self) {
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setLocale:[NSLocale currentLocale]];
            threadDictionary[@"mydateformatter"] = formatter;
        }
    }
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestemp]];
}


/**
 * @return YYYYMMddHHmm
 */
long long dateHourMinuteByMarketTime(long long time)
{
    return [[DateKit toTimeString:time format:@"YYYYMMddHHmm"] longLongValue];
}

/**
 * @return YYYYMMdd
 */
long long dateByMarketTime (long long time)
{
    return [[DateKit toTimeString:time format:@"YYYYMMdd"] longLongValue];
}

/**
 * @return YYYY-MM-dd
 */
NSString *dateStringByMarketTime(long long time)
{
    return [DateKit toTimeString:time format:@"YYYY-MM-dd"];
}

/**
 * @return MM-dd HH:mm
 */
NSString *monthMinuteStringByMarketTime(long long time)
{
    return [DateKit toTimeString:time format:@"MM-dd HH:mm"];
}

/**
 * @return YYYY-MM-dd HH:00
 */
NSString *monthHourStringByMarketTime(long long time)
{
    return [DateKit toTimeString:time format:@"YYYY-MM-dd HH:00"];
}

/**
 * @return YYYY-MM-dd HH:mm
 */
NSString *dateHourMinuteStringByMarketTime(long long time)
{
    return [DateKit toTimeString:time format:@"YYYY-MM-dd HH:mm"];
}

@end
