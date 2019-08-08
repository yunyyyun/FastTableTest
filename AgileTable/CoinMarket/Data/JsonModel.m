
//  JsonModel.m
//  AutoService
//
//  Created by 朱李宏 on 16/3/6.
//  Copyright © 2016年 AutoService. All rights reserved.
//

#import "JsonModel.h"
#import "DMData.h"
#import <objc/runtime.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const JsonModelTypeShort = @"s";
NSString *const JsonModelTypeLong = @"l";
NSString *const JsonModelTypeChar = @"c";
NSString *const JsonModelTypePointer = @"*";

NSString *const JsonModelTypeIvar = @"^{objc_ivar=}";
NSString *const JsonModelTypeMethod = @"^{objc_method=}";
NSString *const JsonModelTypeBlock = @"@?";
NSString *const JsonModelTypeClass = @"#";
NSString *const JsonModelTypeSEL = @":";


NSString *const JsonModelTypeInt = @"Ti";
NSString *const JsonModelTypeFloat = @"Tf";
NSString *const JsonModelTypeDouble = @"Td";
NSString *const JsonModelTypeLongLong = @"Tq";
NSString *const JsonModelTypeBOOL1 = @"Tc";
NSString *const JsonModelTypeBOOL2 = @"Tb";
NSString *const JsonModelTypeBOOL3 = @"TB";
NSString *const JsonModelTypeId = @"T@";

NSString *const JsonModelToTypeString = @"NSString";
NSString *const JsonModelToTypeId = @"id";
NSString *const JsonModelToTypeAssignNumber = @"assignNumber";
NSString *const JsonModelToTypeAssignBool = @"assignBool";

NSDictionary *collectMetadata(Class type);

@implementation NSObject (JsonModel)

- (void)setValueWithDictionary:(NSDictionary<NSString* ,id> *)dictioanry
{
    Class c = [self class];

    while (c != [NSObject class]) {
        [self setValueWithDictionary:dictioanry class:c];
        
        c = class_getSuperclass(c);
    }
}

+ (NSDictionary *)metadata
{
    static NSMutableDictionary<NSString *, NSDictionary *> *allClassMetadata = nil;
    if (!allClassMetadata) {
        allClassMetadata = [NSMutableDictionary dictionary];
    }
    
    NSString *className = NSStringFromClass(self);
    NSDictionary *metadata = [allClassMetadata objectForKey:className];
    if (!metadata) {
        metadata = collectMetadata(self);
        allClassMetadata[className] = metadata;
    }
    
    return metadata;
}

//熟悉key进行驼峰转换
+ (NSDictionary *)underlineMetadataKeyToKey
{
    static NSMutableDictionary<NSString *, NSDictionary *> *allClassMetadata = nil;
    if (!allClassMetadata) {
        allClassMetadata = [NSMutableDictionary dictionary];
    }
    
    NSString *className = NSStringFromClass(self);
    NSDictionary *underline = [allClassMetadata objectForKey:className];
    if (!underline) {
        NSMutableDictionary *newMetadata = [NSMutableDictionary dictionary];
        NSDictionary *metadata = [self metadata];
        [metadata enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            newMetadata[key] = [key underlineFromCamel];
        }];
        
        underline = newMetadata;
        allClassMetadata[className] = underline;
    }
    
    return underline;
}

- (void)setValueWithDictionary:(NSDictionary<NSString* ,id> *)dictioanry class:(Class)aClass
{
    NSDictionary *metadata = [aClass metadata];
    NSDictionary *underline = [aClass underlineMetadataKeyToKey];
    [metadata enumerateKeysAndObjectsUsingBlock:^(NSString  *key, id  _Nonnull valueType, BOOL * _Nonnull stop) {
        NSString *valueKey = underline[key];
        id  _Nonnull obj = [dictioanry objectForKey:valueKey];
        
        if ([valueType isEqualToString:JsonModelToTypeId]) {//id类型
            if (obj) [self setValue:obj forKey:key];
        } else if ([obj isKindOfClass:NSClassFromString(valueType)]) {//类型一致
            if (obj) [self setValue:obj forKey:key];
        } else if ([valueType isEqualToString:JsonModelToTypeString]) {//NSString类型
            if ([obj isKindOfClass:[NSNull class]]) {
                if (obj) [self setValue:nil forKey:key];
            } else {
                if (obj) [self setValue:[obj description] forKey:key];
            }
        } else if ([valueType isEqualToString:JsonModelToTypeAssignNumber]) {//基础类型类型
            NSNumber *value = @(0);
            if ([obj isKindOfClass:[NSString class]]) {
                static NSNumberFormatter *numberFormatter = nil;
                if (!numberFormatter) numberFormatter = [[NSNumberFormatter alloc] init];

                value = [numberFormatter numberFromString:obj];
                if ([value doubleValue] == 0) value = @([obj doubleValue]);
            } else if ([obj isKindOfClass:[NSNumber class]]) {
               value = obj;
            } else if ([obj isKindOfClass:[NSValue class]]) {
                value = [NSNumber numberWithDouble:[obj doubleValue]];
            }
            if (value) [self setValue:value forKey:key];
        } else if ([valueType isEqualToString:JsonModelToTypeAssignBool]) {//基础类型类型
            NSNumber *value = @(false);
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *lower = [obj lowercaseString];
                if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"] || [lower isEqualToString:@"1"]) {
                    value = @(true);
                } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"] || [lower isEqualToString:@"0"]) {
                    value = @(false);
                }
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                value = obj;
            }
            if (value) [self setValue:value forKey:key];
        } else if ([NSClassFromString(valueType) isSubclassOfClass:[DMData class]]) {//自定义类型
            if ([obj isKindOfClass:[NSDictionary class]]) {
                Class valueClass = NSClassFromString(valueType);
                [self setValue:[[valueClass alloc] initWithDictionary:obj] forKey:key];
            }
        }
    }];
}

- (void)setTEMPValueWithDictionary:(NSDictionary<NSString* ,id> *)dictioanry class:(Class)aClass
{
    if (![dictioanry isKindOfClass:[NSDictionary class]]) return;
    
    NSDictionary *metadata = [aClass metadata];
    [dictioanry enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull valueKey, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![valueKey isKindOfClass:[NSString class]])
            valueKey = [valueKey description];

        NSString *key = [valueKey camelFromUnderline];
        id valueType = [metadata objectForKey:key];
        if (!valueType) return;
        
        if ([valueType isEqualToString:JsonModelToTypeId]) {//id类型
            if (obj) [self setValue:obj forKey:key];
        } else if ([obj isKindOfClass:NSClassFromString(valueType)]) {//类型一致
            if (obj) [self setValue:obj forKey:key];
        } else if ([valueType isEqualToString:JsonModelToTypeString]) {//NSString类型
            if ([obj isKindOfClass:[NSNull class]]) {
                if (obj) [self setValue:nil forKey:key];
            } else {
                if (obj) [self setValue:[obj description] forKey:key];
            }
        } else if ([valueType isEqualToString:JsonModelToTypeAssignNumber]) {//基础类型类型
            NSNumber *value = @(0);
            if ([obj isKindOfClass:[NSString class]]) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                value = [numberFormatter numberFromString:obj];
                if ([value doubleValue] == 0) value = @([obj doubleValue]);
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                value = obj;
            } else if ([obj isKindOfClass:[NSValue class]]) {
                value = @([obj doubleValue]);
            }
            
            if (value) [self setValue:value forKey:key];
        } else if ([valueType isEqualToString:JsonModelToTypeAssignBool]) {//基础类型类型
            NSNumber *value = @(false);
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *lower = [obj lowercaseString];
                if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"] || [lower isEqualToString:@"1"]) {
                    value = @(true);
                } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"] || [lower isEqualToString:@"0"]) {
                    value = @(false);
                }
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                value = obj;
            }
            if (value) [self setValue:value forKey:key];
        } else if ([NSClassFromString(valueType) isSubclassOfClass:[DMData class]]) {//自定义类型
            if ([obj isKindOfClass:[NSDictionary class]]) {
                Class valueClass = NSClassFromString(valueType);
                [self setValue:[[valueClass alloc] initWithDictionary:obj] forKey:key];
            }
        }
    }];
}

@end

NSDictionary *collectMetadata(Class type) {
    NSMutableDictionary* propertyList = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *objcProperties = class_copyPropertyList(type, &outCount);
    if (!outCount | !objcProperties) {
        return propertyList;
    }
    
    for (i = 0; i <= (int)outCount - 1; i++) {
        if (objcProperties) {
            const char *propertyName = property_getName(objcProperties[i]);
            if(propertyName){
                NSString *propertyNameString = [NSString stringWithUTF8String:propertyName];
                NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(objcProperties[i])];
                NSArray *propertyArray = [propertyAttributes componentsSeparatedByString:@","];
                NSString *propertyType = propertyArray.firstObject;
                NSString *propertyStatus = nil;
                if (propertyArray.count > 1) {
                    propertyStatus = propertyArray[1];
                }
                if ([propertyStatus isEqualToString:@"R"]) {
                    continue;
                }
                if ([propertyType rangeOfString:JsonModelTypeId].location == 0) {
                    NSString* typeName = JsonModelToTypeId;
                    if (propertyType.length > 3) {
                        typeName = [propertyType substringWithRange:NSMakeRange(3, propertyType.length - 4)];
                    }
                    [propertyList setObject:typeName forKey:propertyNameString];
                } else if ([propertyAttributes rangeOfString:JsonModelTypeInt].location == 0) {
                    [propertyList setObject:JsonModelToTypeAssignNumber forKey:propertyNameString];
                } else if ([propertyAttributes rangeOfString:JsonModelTypeFloat].location == 0) {
                    [propertyList setObject:JsonModelToTypeAssignNumber forKey:propertyNameString];
                } else if ([propertyAttributes rangeOfString:JsonModelTypeDouble].location == 0) {
                    [propertyList setObject:JsonModelToTypeAssignNumber forKey:propertyNameString];
                } else if ([propertyAttributes rangeOfString:JsonModelTypeLongLong].location == 0) {
                    [propertyList setObject:JsonModelToTypeAssignNumber forKey:propertyNameString];
                } else if ([propertyAttributes rangeOfString:JsonModelTypeBOOL1].location == 0) {
                    [propertyList setObject:JsonModelToTypeAssignBool forKey:propertyNameString];
                } else if ([propertyAttributes rangeOfString:JsonModelTypeBOOL2].location == 0) {
                    [propertyList setObject:JsonModelToTypeAssignBool forKey:propertyNameString];
                } else if ([propertyAttributes rangeOfString:JsonModelTypeBOOL3].location == 0) {
                    [propertyList setObject:JsonModelToTypeAssignBool forKey:propertyNameString];
                }
            }
        }else {
            
        }
    }
    
    free(objcProperties);
    
    //不检查父类的内容
    return propertyList;
}


@implementation NSString (CamelUnderLine)

/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)underlineFromCamel
{
    // 将返回的数据里面的id转换成dataId存储到DMData里面
    if ([self isEqualToString:@"dataId"]) {
        return @"id";
    }
    if ([self isEqualToString:@"dataDescription"]) {
        return @"description";
    }
    
    if (self.length == 0) return self;
    NSMutableString *string = [NSMutableString string];
    for (NSUInteger i = 0; i<self.length; i++) {
        unichar c = [self characterAtIndex:i];
        NSString *cString = [NSString stringWithFormat:@"%c", c];
        NSString *cStringLower = [cString lowercaseString];
        if ([cString isEqualToString:cStringLower]) {
            [string appendString:cStringLower];
        } else {
            [string appendString:@"_"];
            [string appendString:cStringLower];
        }
    }
    return string;
}

/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)camelFromUnderline
{
	// 将返回的数据里面的id转换成dataId存储到DMData里面
	if ([self isEqualToString:@"id"]) {
		return @"dataId";
	}
	if ([self isEqualToString:@"description"]) {
		return @"dataDescription";
	}

    if (self.length == 0) return self;
    NSMutableString *string = [NSMutableString string];
    NSArray *cmps = [self componentsSeparatedByString:@"_"];
    for (NSUInteger i = 0; i<cmps.count; i++) {
        NSString *cmp = cmps[i];
        if (i && cmp.length) {
            unichar c = [cmp characterAtIndex:0];
            if (c >= 48 && c <= 57) {
                [string appendString:[NSString stringWithFormat:@"%c", c]];
            } else {
                [string appendString:[NSString stringWithFormat:@"%c", c].uppercaseString];
            }
            if (cmp.length >= 2) [string appendString:[cmp substringFromIndex:1]];
        } else {
            [string appendString:cmp];
        }
    }
    return string;
}

@end
