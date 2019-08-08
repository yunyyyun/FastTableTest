//
//  HTTPHelper.h
//  GoIco
//
//  Created by Andy on 2017/8/26.
//  Copyright © 2017年 ico. All rights reserved.
//

#import <Foundation/Foundation.h>

#define defError  @"网络错误"
#define CodeSucess      200
#define CodeUnKnowErr   2001

@interface HTTPRequestCodeError : NSObject
@property (nonatomic, assign) int code;
@property (nonatomic, strong) NSString *error;
@end

@interface HTTPHelper : NSObject

+ (void)detaiDataReponseObject:(NSDictionary<NSString *, id> *)reponseObject
                       success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                       failure:(void (^)(int code, NSString *error))failure;
/*! 失败时处理错误问题
 */
+ (HTTPRequestCodeError *)handleErrorTaskResponse:(NSURLResponse *)response error:(NSError *)error;
/*! 处理请求参数
 */
+ (id)detailParamters:(id)paramters;

+ (NSTimeInterval)timestamp;

@end

