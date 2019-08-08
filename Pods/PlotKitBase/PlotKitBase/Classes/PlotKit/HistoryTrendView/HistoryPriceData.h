//
//  HistoryPriceData.h
//  PlotKitTest
//
//  Created by DFG on 2019/3/27.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryPriceData : NSObject

@property (assign, nonatomic) double price;
@property (assign, nonatomic) NSTimeInterval timestmp;
@property (assign, nonatomic) double volume;

+ (HistoryPriceData *)dataWithPrice: (double)price time:(NSTimeInterval)time volume: (double)volume;

@end
