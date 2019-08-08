//
//  HistoryPriceData.m
//  PlotKitTest
//
//  Created by DFG on 2019/3/27.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "HistoryPriceData.h"

@implementation HistoryPriceData

+ (HistoryPriceData *)dataWithPrice: (double)price time:(NSTimeInterval)time volume: (double)volume{
    HistoryPriceData *data = [[HistoryPriceData alloc] init];
    data.price = price;
    data.timestmp = time;
    data.volume = volume;
    return data;
}

@end
