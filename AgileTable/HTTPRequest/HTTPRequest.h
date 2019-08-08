//
//  HTTPRequest.h
//  building
//
//  Created by Andy on 16/9/15.
//  Copyright © 2016年 building. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN
@interface HTTPRequest : AFHTTPSessionManager

+ (HTTPRequest *)shareObject;
+ (NSString *)url;
+ (NSString *)headOrig;
//+ (NSString *)bkbUrl;

- (NSURLSessionDataTask *)GETData:(NSString *)URLString
                       parameters:(nullable id)parameters
                          success:(void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
//method 为接口文档定义内容，非GET、POST
- (NSURLSessionDataTask *)POSTData:(NSString *)URLString
                        parameters:(nullable id)parameters
                           success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable responseObject))success
                           failure:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;

/*! 处理了错误，没有弹tost
 */
- (NSURLSessionDataTask *)GETAndDetailData:(NSString *)URLString
                                parameters:(nullable id)parameters
                                   success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                                   failure:(void (^)(int code, NSString *error))failure;
- (NSURLSessionDataTask *)POSTAndDetailData:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                                    failure:(void (^)(int code, NSString *error))failure;

- (NSURLSessionDataTask *)PostJsonDataWithHost: (NSString *)host
                                        method: (NSString *)method
                                     jsonDatas: (id)datas
                                       success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                                       failure:(void (^)(int code, NSString *error))failure;
@end

@interface AFHTTPSessionManager ()
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
@end

NS_ASSUME_NONNULL_END


