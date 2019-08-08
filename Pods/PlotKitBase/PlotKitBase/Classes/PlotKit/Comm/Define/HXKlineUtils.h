//
//  HXKlineUtils.h
//  TZYJ_IPhone
//
//  Created by 邓莹莹 on 17/4/16.
//
//

#import <Foundation/Foundation.h>
#import "KlinePrams.h"

@interface HXKlineUtils : NSObject

/**
 根据K线柱宽获取滑动尺寸
 */
+ (NSInteger)panRangeWithPillarWidth:(NSInteger)pillarWidth;

@end
