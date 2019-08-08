//
//  HXKlineCompDayData.m
//  GoIco
//
//  Created by Violet on 2017/12/28.
//  Copyright © 2017年 ico. All rights reserved.
//

#import "HXKlineCompDayData.h"

#define kHXKlineCompDayCopyAction(x) data.x = self.x;

@implementation HXKlineCompDayData

- (instancetype)copy
{
    HXKlineCompDayData *data = [HXKlineCompDayData new];
    kHXKlineCompDayCopyAction(m_openTime)
    kHXKlineCompDayCopyAction(m_closeTime)
    kHXKlineCompDayCopyAction(m_lOpenPrice)
    kHXKlineCompDayCopyAction(m_lMaxPrice)
    kHXKlineCompDayCopyAction(m_lMinPrice)
    kHXKlineCompDayCopyAction(m_lClosePrice)
    kHXKlineCompDayCopyAction(m_lMoney)
    kHXKlineCompDayCopyAction(m_lTotal)
    
    return data;
}

@end
