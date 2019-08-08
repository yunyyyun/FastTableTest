//
//  Config.h
//  AgileTable
//
//  Created by mengyun on 2019/5/24.
//  Copyright © 2019 mengyun. All rights reserved.
//

#ifndef Config_h
#define Config_h
#import <Foundation/Foundation.h>

#define WindowWidth CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds)
#define WindowHeight CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds)

#define minVailedPrice 0.0000000001
#define changeUpColor [UIColor colorWithRed: 235/255.0 green: 47/255.0 blue: 47/255.0 alpha: 0.9]
#define changeDownColor [UIColor colorWithRed: 0/255.0 green: 167/255.0 blue: 50/255.0 alpha: 0.9]
#define changeUpImage [UIImage imageNamed:@"going_up_red"]
#define changeDownImage [UIImage imageNamed:@"going_down_green"]

#define isInAnimation @1
#define isNotInAnimation @0
#define fpsEnabled false

// weakify strongify
#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#define EDLog NSLog
#define isNilString(x) ![x isKindOfClass:[NSString class]] //|| (!(x.length > 0))
#define SafeString(x) (isNilString(x) ? @"" : x)
#define commonPageSize 20

#endif /* Config_h */
