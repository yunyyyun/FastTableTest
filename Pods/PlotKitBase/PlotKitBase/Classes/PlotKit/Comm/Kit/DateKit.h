//
//  DateKit.h
//  TZYJ_IPhone
//
//  Created by Mernushine on 17/4/19.
//
// 日期相关

#import <Foundation/Foundation.h>

@interface DateKit : NSObject

/**
 *
 * @param time 行情时间time格式是：YYYYMMDDHHmmSS12345
 * @return YYYYMMDDHHmm
 */
long long dateHourMinuteByMarketTime(long long time);

/**
 *
 * @param time 行情时间time格式是：YYYYMMDDHHmmSS12345
 * @return YYYYMMDD
 */
long long dateByMarketTime (long long time);

/**
 *
 * @param time 行情时间time格式是：YYYYMMDDHHmmSS12345
 * @return YYYY-MM-DD
 */
NSString *dateStringByMarketTime(long long time);

/**
 *
 * @param time 行情时间time格式是：YYYYMMDDHHmmSS12345
 * @return MM-DD HH:mm
 */
NSString *monthMinuteStringByMarketTime(long long time);

/**
 * @return YYYY-MM-dd HH:00
 */
NSString *monthHourStringByMarketTime(long long time);

/**
 * @return YYYY-MM-dd HH:mm
 */
NSString *dateHourMinuteStringByMarketTime(long long time);

@end
