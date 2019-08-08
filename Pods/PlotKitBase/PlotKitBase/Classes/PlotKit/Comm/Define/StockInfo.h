//
//  StockInfo.h
//  KLine
//
//  Created by Violet on 2017/10/7.
//  Copyright © 2017年 Violet. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class Quote;
@interface StockInfo : NSObject

- (NSString *_Nullable)stringOfAmount:(double)amount; //格式化输出成交额
//格式化输出成交量，withUnit:YES，附加单位 “股”， "手"等
- (NSString *_Nullable)stringOfVolume:(double)volume withUnit:(BOOL)withUnit; //格式化输出成交量
- (NSString *_Nullable)stringOfPrice:(double)price; //格式化输出价格，价格是0时默认显示--

@end
