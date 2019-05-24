//
//  CurrencyData.h
//  AgileTable
//
//  Created by mengyun on 2019/5/20.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import <JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CurrencyData;
@interface CurrencyData : JSONModel

@property (nonatomic) NSString<Optional> *logo;
@property (nonatomic) NSString<Optional> *symbol;
@property (nonatomic) NSString<Optional> *alias;
@property (nonatomic) NSString<Optional> *marketCapCnyDisplay;
@property (nonatomic) NSNumber<Optional> *rank;
@property (nonatomic) NSString<Optional> *priceUsdDisplay;
@property (nonatomic) NSString<Optional> *priceCnyDisplay;
@property (nonatomic) NSNumber<Optional> *percentChange24h;

@end

@interface CurrencyDataList : JSONModel

@property (nonatomic) NSArray<CurrencyData, Optional> *list;

+ (NSURLSessionDataTask *)getDatasSuccess:(void (^)(CurrencyDataList* data))success failure:(void (^)(int code, NSString *error))failure;

@end

NS_ASSUME_NONNULL_END
