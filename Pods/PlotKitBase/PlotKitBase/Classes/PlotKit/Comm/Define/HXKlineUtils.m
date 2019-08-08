//
//  HXKlineUtils.m
//  TZYJ_IPhone
//
//  Created by 邓莹莹 on 17/4/16.
//
//

#import "HXKlineUtils.h"

@implementation HXKlineUtils

+ (NSInteger)panRangeWithPillarWidth:(NSInteger)pillarWidth
{
    NSInteger criterionWidth = 4;
    NSInteger criterionRange = 7;
    //    double ratio = sqrt(criterionWidth*1.0/_klineDataPack.pillarWidth);
    double ratio = pow(criterionWidth * 1.0 / pillarWidth, 2.0 / 3);

    return ceil(criterionRange * ratio);
}

@end
