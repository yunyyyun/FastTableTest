//
//  JsonModel.h
//  AutoService
//
//  Created by 朱李宏 on 16/3/6.
//  Copyright © 2016年 AutoService. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JsonModel)

/**
 设置内部所以数据，当dictioanry内没有时设置为nil、0、false
 */
- (void)setValueWithDictionary:(NSDictionary<NSString* ,id> *)dictioanry;

@end

@interface NSString (CamelUnderLine)

/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)camelFromUnderline;

@end

