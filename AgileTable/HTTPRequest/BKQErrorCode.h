//
//  BKQErrorCode.h
//  BKQ
//
//  Created by 周峻觉 on 2019/6/21.
//  Copyright © 2019 周峻觉. All rights reserved.
//

#ifndef BKQErrorCode_h
#define BKQErrorCode_h

// 后端系统错误码
#define BKQSuccessCode                  200         // 成功
#define BKQUnauthorizedCode             401         // 未授权
#define BKQNoPermissionCode             402         // 没有权限
#define BKQServerErrorCode              500         // 服务器内部错误
#define BKQDatabaseErrorCode            651         // 数据库错误
#define BKQRedisErrorCode               652         // Redis错误
#define BKQKafakaErrorCode              653         // Kafaka错误
#define BKQRPCFailureCode               654         // 远程调用失败
#define BKQCallTimeoutCode              655         // 调用超时
#define BKQRepeatRequestCode            656         // 重复请求
#define BKQParameterIllegalCode         700         // 参数不合法
#define BKQEmptySetCode                 701         // 空结果集

#define BKQAccountFrozenCode            605         // 此账号已被冻结，请联系客服解除

#endif /* BKQErrorCode_h */
