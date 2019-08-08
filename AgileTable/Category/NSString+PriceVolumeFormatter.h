//
//  NSString+PriceVolumeFormatter.h
//  InjectionIIITest
//
//  Created by mengyun on 2019/5/2.
//  Copyright © 2019 mengyun. All rights reserved.
//
//  新的价格、额、量formater  区别于 NSString+Formatter.m

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PriceVolumeFormatter)

+(NSString *)formatterVolumeWith: (double )volume;
+(NSString *)formatterAmountWith: (double )amount;
+(NSString *)formatterPriceWith: (double )price isPairs: (BOOL) isPairs;
+(NSString *)formatterPriceWith: (double )price;
+(NSString *)formatterPriceWithNumber: (NSNumber *)priceNumber;
//+(NSString *)formatterPairsPriceWith: (double )price;
+(NSString *)formatterWalletAmountWith: (double )amount;
+(NSString *)formatterWalletAmountWith: (double )amount dot: (int)dot;

@end

NS_ASSUME_NONNULL_END
