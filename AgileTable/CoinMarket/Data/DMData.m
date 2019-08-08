//
//  DMData.m
//  AiQiangGou
//
//  Created by 朱李宏 on 15/7/9.
//  Copyright (c) 2015年 Doweidu. All rights reserved.
//

#import "DMData.h"

@implementation DMData

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        [self setValueWithDictionary:dictionary];
    }
    
    return self;
}

+ (NSArray *)datasWithArray:(NSArray *)array
{
    if (![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray *datas = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if ([obj isKindOfClass:[NSDictionary class]]) {
			[datas addObject:[[self alloc] initWithDictionary:obj]];
		}
    }];
    
    return datas;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

- (id)valueForUndefinedKey:(NSString *)key { return nil; }

+ (instancetype)modelWithJSON:(id)json {
    return [self yy_modelWithJSON:json];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    return [self yy_modelWithDictionary:dict];
}

@end

