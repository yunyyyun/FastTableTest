//
//  NSDate+String.m
//  PlotKitTest
//
//  Created by DFG on 2019/3/27.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "NSDate+String.h"

@implementation NSDate (String)

/*!转换为format(yyyy-MM-dd HH:mm)格式
 */
- (NSString *)toTimeStringWithFormat:(NSString *)format
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
    
    return [formatter stringFromDate:self];
}

@end
