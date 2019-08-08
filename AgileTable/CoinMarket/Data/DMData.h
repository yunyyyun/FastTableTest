//
//  DMData.h
//  AiQiangGou
//
//  Created by 朱李宏 on 15/7/9.
//  Copyright (c) 2015年 Doweidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonModel.h"
#import "YYModel.h"

@interface DMData : NSObject <YYModel>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)datasWithArray:(NSArray *)array;

+ (instancetype)modelWithJSON:(id)json;

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

