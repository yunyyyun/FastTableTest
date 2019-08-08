//
//  HTTPRequest.m
//  building
//
//  Created by Andy on 16/9/15.
//  Copyright © 2016年 building. All rights reserved.
//

#import "HTTPRequest.h"
#import "HTTPHelper.h"
#import "LXMethod.h"

#define API(path) [NSString stringWithFormat:@"%@%@?deviceNo=%@&src=ios&channel=%@&version=%@", [HTTPRequest url], path, [LXMethod deviceNo], [LXMethod registerChannel], [LXMethod version]]

static NSInteger request_index = 0;

@interface HTTPRequest ()

@property (nonatomic, assign) NSInteger failCount;

@end

@implementation HTTPRequest

+ (HTTPRequest *)shareObject {
    static NSMutableArray *managers = nil;
    if (!managers) {
        managers = [NSMutableArray array];
        [managers addObject: [self createRequest: [self url]]];
    }
    if (managers.count < 1) return nil;
    if (request_index >= managers.count) request_index = 0;

    HTTPRequest *request = [managers objectAtIndex:request_index];
    
    return request;
}

// 获取原生与服务端请求的 url
+ (NSString *)url
{
    return @"https://papi.bikachu.com";
}

// 获取原生与服务端请求的 head 里需要填入的标记
+ (NSString *)headOrig{
    return @"https://www.bikachu.com";
}
//
//// 比卡比的 url
//+ (NSString *)bkbUrl
//{
//    NSString *pdUrl = SERVER_H5_URL;
//#if DEBUG
//    NSString *url = [groupDefaults() objectForKey: BKQConfigDebugBKBUrlType];
//    if (!isNilString(url)) return url;
//#else
//#endif
//    return pdUrl;
//}

+ (HTTPRequest *)createRequest:(NSString *)urlString {
    NSURLSessionConfiguration *configuration =  [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    HTTPRequest *manager = [[HTTPRequest alloc] initWithBaseURL:[NSURL URLWithString:urlString] sessionConfiguration:configuration];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer new];
    requestSerializer.timeoutInterval = 10;
    [requestSerializer setValue: [self headOrig] forHTTPHeaderField:@"Origin"];
    manager.requestSerializer = requestSerializer;
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer new];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/javascript", nil];
    manager.responseSerializer = responseSerializer;

    return manager;
}
//
#pragma mark publick
//method 为接口文档定义内容，非GET、POST
- (NSURLSessionDataTask *)GETData:(NSString *)URLString
                       parameters:(nullable id)parameters
                          success:(void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{

	return [self GET:URLString parameters:[HTTPHelper detailParamters:parameters] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
		if (success) success(task, responseObject);
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.failCount ++;
        if (self.failCount >= 3) {
            self.failCount = 0;
            request_index += 1;
        }
        if (failure) failure(task, error);
	}];
}

//method 为接口文档定义内容，非GET、POST
- (NSURLSessionDataTask *)POSTData:(NSString *)URLString
                    parameters:(nullable id)parameters
                       success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable responseObject))success
                       failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
	return [super POST:URLString parameters:[HTTPHelper detailParamters:parameters] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
		if (success) success(task, responseObject);
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.failCount ++;
        if (self.failCount >= 3) {
            self.failCount = 0;
            request_index += 1;
        }
        if (failure) failure(task, error);
	}];
}

// POST GET detail error
//method 为接口文档定义内容，非GET、POST
- (NSURLSessionDataTask *)GETAndDetailData:(NSString *)URLString
                                parameters:(nullable id)parameters
                                   success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                                   failure:(void (^)(int code, NSString *error))failure
{
    return [self GETData:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [HTTPHelper detaiDataReponseObject:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HTTPRequestCodeError *hand = [HTTPHelper handleErrorTaskResponse:task.response error:error];
        if (failure) {
            failure(hand.code, hand.error);
        }
    }];
}

//method 为接口文档定义内容，非GET、POST
- (NSURLSessionDataTask *)POSTAndDetailData:(NSString *)URLString
                    parameters:(nullable id)parameters
                       success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                       failure:(void (^)(int code, NSString *error))failure
{
    return [self POSTData:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [HTTPHelper detaiDataReponseObject:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HTTPRequestCodeError *hand = [HTTPHelper handleErrorTaskResponse:task.response error:error];
        if (failure) {
            failure(hand.code, hand.error);
        }
    }];
}

// 数据格式为 "application/json" 的post请求、以及其它put、delete请求
- (NSURLSessionDataTask *) PostJsonDataWithHost: (NSString *)host
                                        method: (NSString *)method
                                         jsonDatas: (id)datas
                                       success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                                       failure:(void (^)(int code, NSString *error))failure{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:datas options:0 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *urlStr = API(host);
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod: method URLString:urlStr parameters:nil error:nil];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue: [HTTPRequest headOrig] forHTTPHeaderField:@"Origin"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
//        if ([host containsString: @"fav"]) // 判断自选有变更
//            [DMSelfStockGroupList sharedObjcet].isChanged = true;
        
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error: nil];
        [HTTPHelper detaiDataReponseObject:responseObject success:^(NSDictionary<NSString *,id> *responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)
                    success(responseObject);
            });
        } failure:^(int code, NSString *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure)
                    failure(code, error);
            });
        }];
        
    }];
    [task resume];
    return task;
    //[task resume];
}

////内容统计
//- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
//                                       URLString:(NSString *)URLString
//                                      parameters:(id)parameters
//                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
//                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
//                                         success:(void (^)(NSURLSessionDataTask *, id))success
//                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
//{
//
//    BOOL isRecod = ![URLString isEqualToString:@"/currency/refreshprice"];
//    return [super dataTaskWithHTTPMethod:method
//                               URLString:URLString
//                              parameters:parameters
//                          uploadProgress:uploadProgress
//                        downloadProgress:downloadProgress
//                                 success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject) {
//                                     if (success) success(task, responseObject);
//
//                                     if (isRecod) {
//                                         NSString *response = [NSString jsonString:responseObject];
//                                         if (response.length > 2000) {
//                                             response = [response substringToIndex:2000];
//                                         }
//                                         // [[LogRecord sharedObject] addNetDataWithHTTPMethod:method URLString:url parameters:param code:200 response:response error:@""];
//                                     }
//                                 } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//                                     if (failure) failure(task, error);
//
//                                     if (isRecod) {
//                                         // [[LogRecord sharedObject] addNetDataWithHTTPMethod:method URLString:url parameters:param code:(int)error.code response:[NSString jsonString:error.userInfo] error:error.localizedDescription];
//                                     }
//                                 }];
//}

@end

