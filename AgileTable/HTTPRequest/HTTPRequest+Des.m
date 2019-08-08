//
//  HTTPRequest+Des.m
//  BKQ
//
//  Created by meng yun on 2019/6/20.
//  Copyright © 2019 周峻觉. All rights reserved.
//

/*
 原来的请求：
 GET：     https://xxx.com/yyy?deviceNo=111@&src=ios&channel=222&version=2.0.1&a=a1
 
 现在的请求：
 GET：     https://xxx.com/yyy?version=2.0.1&src=ios&data=desdata
 将 deviceNo=111@&src=ios&channel=222&version=2.0.1&a=a1  使用des加密，得到 desdata
 
 
 原来的请求：
 POST:      https://xxx.com/yyy?deviceNo=111@&src=ios&channel=222&version=2.0.1
 Body:{x:x1}
 
 现在的请求：
 POST:      https://xxx.com/yyy?version=2.0.1&src=ios&data=desdata
 Body 无
 将 {deviceNo:111, src:ios, channel:222,version:2.0.1, body:{x:x1}} 使用des加密，得到 desdata
 */

#import <objc/runtime.h>
#import "HTTPHelper.h"
#import "HTTPRequest+Des.h"
#import "DES3Util.h"
#import "LXMethod.h"

@implementation HTTPRequest (Des)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(GETAndDetailData: parameters: success: failure:) withIMP:@selector(_GETAndDetailData: parameters: success: failure:)];
        [self swizzleSelector:@selector(POSTAndDetailData: parameters: success: failure:) withIMP:@selector(_POSTAndDetailData: parameters: success: failure:)];
        [self swizzleSelector:@selector(PostJsonDataWithHost: method: jsonDatas: success: failure:) withIMP:@selector(_PostJsonDataWithHost: method: jsonDatas: success: failure:)];
    });
}

+ (void)swizzleSelector:(SEL)origSelector withIMP:(SEL)newSelector
{
    Class class = [self class];
    
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    
    SEL originalSelector = origSelector;
    SEL swizzledSelector = newSelector;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

//method 为接口文档定义内容，非GET、POST
- (NSURLSessionDataTask *)_GETAndDetailData:(NSString *)URLString
                                parameters:(nullable id)parameters
                                   success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                                   failure:(void (^)(int code, NSString *error))failure
{
    // EDLog(@"hhhhhzzzzzzzz _GETAndDetailData");
    return [self GETData:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [HTTPHelper detaiDataReponseObject:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HTTPRequestCodeError *hand = [HTTPHelper handleErrorTaskResponse:task.response error:error];
        if (failure) {
            EDLog(@"_GETAndDetailData_GETAndDetailData %d %@", hand.code, hand.error);
            failure(hand.code, hand.error);
        }
    }];
}

//method 为接口文档定义内容，非GET、POST
- (NSURLSessionDataTask *)_POSTAndDetailData:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                                    failure:(void (^)(int code, NSString *error))failure
{
    return [self PostJsonDataWithHost: URLString
                               method: @"POST"
                            jsonDatas: parameters
                              success: success
                              failure: failure];
}

// 数据格式为 "application/json" 的 post 请求、以及其它 put、delete 请求
- (NSURLSessionDataTask *)_PostJsonDataWithHost: (NSString *)host
                                        method: (NSString *)method
                                     jsonDatas: (id)datas
                                       success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                                       failure:(void (^)(int code, NSString *error))failure{
    NSArray *p = datas==nil ? @[] : datas;
    NSString *urlStr = [self dodWithPath: host paramters: p];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod: method URLString:urlStr parameters:nil error:nil];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue: [HTTPRequest headOrig] forHTTPHeaderField:@"Origin"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    EDLog(@"-----123 %@", req);
    NSURLSessionDataTask *task = [session dataTaskWithRequest: req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
//        if ([host containsString: @"fav"]) // 判断自选有变更
//            [DMSelfStockGroupList sharedObjcet].isChanged = true;
        if (data==nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure)
                    failure(-1, @"网络错误");
            });
            return;
        }
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
}

// 加密加盐
- (NSString *) dodWithPath: (NSString *)path paramters: (id) paramters{
    if (!paramters) paramters = @[];
    NSMutableDictionary *newParamters = [@{} mutableCopy];
    if (!newParamters[@"deviceNo"]) {
        newParamters[@"deviceNo"] = [LXMethod deviceNo];
    }
    if (!newParamters[@"channel"]) {
        newParamters[@"channel"] = [LXMethod registerChannel];
    }
    NSData *jsonData0 = [NSJSONSerialization dataWithJSONObject:paramters options:0 error: nil];
    NSString *jsonString0 = [[NSString alloc] initWithData:jsonData0 encoding:NSUTF8StringEncoding];
    newParamters[@"body"] = jsonString0;
    newParamters[@"ts"] = @"zyxwvabcde";
    
    //NSMutableDictionary *resultParamters = [@{} mutableCopy];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: newParamters options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    // resultParamters[@"desdata"] = [HTTPHelper encryptUseDES2: jsonString];
    NSString *uurl = [NSString stringWithFormat:@"%@%@?src=ios&version=%@&data=%@", [HTTPRequest url], path, [LXMethod version], [DES3Util encryptUseDES: jsonString]];
    return uurl;
}

@end
