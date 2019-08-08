//
//  CurrencyData.m
//  AgileTable
//
//  Created by mengyun on 2019/5/20.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "CurrencyData.h"
#import "HTTPRequest.h"

@implementation CurrencyData

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{@"dataId":@"id"}];
}

- (void)animation:(NSTimeInterval)duration//进行动画
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isAnimated = isInAnimation;
        self.lastChange = @0;
    });
}

- (void)setIsAnimated:(NSNumber *)isAnimated
{
    _isAnimated = isAnimated;
}

@end

@implementation CurrencyDataList

+ (NSURLSessionDataTask *)getDatasSuccess:(void (^)(CurrencyDataList* data))success failure:(void (^)(int code, NSString *error))failure{
    
    NSDictionary *params = @{@"pageNum": @(1),
                             @"pageSize": @(99),
                             @"sort": @"",
                             };
    return [[HTTPRequest shareObject] PostJsonDataWithHost: @"/market/front/currencys/" method: @"GET" jsonDatas: params success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        CurrencyDataList* model = [[CurrencyDataList alloc] initWithDictionary:data error: nil];
        if (success)
            success(model);
    } failure:^(int code, NSString * _Nonnull error) {
        if (failure)
            failure(0, error);
    }];
}

////价格刷新
+ (NSURLSessionDataTask *)refresh:(NSArray<CurrencyData *> *)currencies success:(void (^)(NSArray *responseList))success failure:(void (^)(int code, NSString *error))failure {
    // NSMutableDictionary *keyCurrenies = [NSMutableDictionary dictionary];
    NSMutableString *string = [NSMutableString string];
    [currencies enumerateObjectsUsingBlock:^(CurrencyData * _Nonnull currency, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx<100){
            if (idx != 0)
                [string appendString:@"|"];
            NSString *key = [NSString stringWithFormat:@"%@,%@", currency.sourceType, currency.dataId];
            [string appendString: key];
        }
    }];
    NSLog(@"refreshrefresh : %@",string );
    return nil;
}

//+ (NSURLSessionDataTask *)requestDataWithHost: (NSString *)host
//                                        method: (NSString *)method
//                                      bodyData: (id)datas
//                                        params: (NSDictionary *)params
//                                       success: (void (^)(NSDictionary<NSString *, id> *responseObject))success
//                                       failure: (void (^)(int code, NSString *error))failure{
//
//    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SERVER_BASE_URL_BKQ, host];
//
//    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod: @"get" URLString:urlStr parameters: params error:nil];
//    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [req setValue:headOrigin forHTTPHeaderField:@"Origin"];
//    [req setValue: token forHTTPHeaderField:@"Bearer"];
//    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//
//    // [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
//
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//
//    NSURLSessionDataTask *task = [session dataTaskWithRequest: req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//        if (!error && httpResponse.statusCode == 200) {
//            NSError *err;
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
//
//            if (!err) {
//                NSString *statusCode = [dict objectForKey:@"status"];
//                NSString *message = [dict objectForKey:@"message"];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if ([statusCode intValue] == 200){
//                        if (success)
//                            success(dict);
////                        NSDictionary *data = [dict objectForKey:@"data"];
////                        CurrencyDataList* list = [[CurrencyDataList alloc] initWithDictionary:data error: nil];
////                        if (success)
////                            success(list);
//                    }
//                    else{
//                        failure(-999, message);
//                    }
//                });
//            }
//            else{
//                NSString *errorMsg = [dict objectForKey:@"message"];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    failure(0, errorMsg);
//                });
//            }
//        }
//    }];
//    [task resume];
//    return task;
//}

@end
