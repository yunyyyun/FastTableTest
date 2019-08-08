//
//  HXKlineCompDayData.h
//  GoIco
//
//  Created by Violet on 2017/12/28.
//  Copyright © 2017年 ico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXKlineCompDayData : NSObject

@property (nonatomic, assign) long long m_openTime;  //K线周期开始时间
@property (nonatomic, assign) long long m_closeTime; //K线周期结束时间
@property (nonatomic, assign) double    m_lOpenPrice;
@property (nonatomic, assign) double    m_lMaxPrice;
@property (nonatomic, assign) double    m_lMinPrice;
@property (nonatomic, assign) double    m_lClosePrice;
@property (nonatomic, assign) double    m_lMoney; //成交金额 turnover
@property (nonatomic, assign) double    m_lTotal; //成交量 vol

@end
