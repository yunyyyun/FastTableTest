//
//  CurrencyData.m
//  AgileTable
//
//  Created by mengyun on 2019/5/20.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "CurrencyData.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>

#define SERVER_BASE_URL_BKQ       @"https://napi.coincash.com"
#define headOrigin                @"https://www.coincash.com"

@implementation CurrencyData

@end

@implementation CurrencyDataList

+ (NSURLSessionDataTask *)getDatasSuccess:(void (^)(CurrencyDataList* data))success failure:(void (^)(int code, NSString *error))failure{
    
    NSDictionary *params = @{@"pageNum": @(1),
                             @"pageSize": @(999),
                             @"sort": @"",
                             };
    
    NSArray *datas = @[];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:datas options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/market/front/currencys/", SERVER_BASE_URL_BKQ];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod: @"get" URLString:urlStr parameters: params error:nil];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:headOrigin forHTTPHeaderField:@"Origin"];
    [req setValue: @"asdddddasdasdsdddsw" forHTTPHeaderField:@"Bearer"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest: req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (!error && httpResponse.statusCode == 200) {
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
            
            if (!err) {
                NSString *statusCode = [dict objectForKey:@"status"];
                NSString *message = [dict objectForKey:@"message"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([statusCode intValue] == 200){
                        NSDictionary *data = [dict objectForKey:@"data"];
                        CurrencyDataList* list = [[CurrencyDataList alloc] initWithDictionary:data error: nil];
                        if (success)
                            success(list);
                    }
                    else{
                        failure(-999, message);
                    }
                });
            }
            else{
                NSString *errorMsg = [dict objectForKey:@"message"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(0, errorMsg);
                });
            }
        }
    }];
    [task resume];
    return task;
}

@end
