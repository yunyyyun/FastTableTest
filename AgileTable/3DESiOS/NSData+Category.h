//
//  NSData+Category.h
//  EncryptTest
//
//  Created by 周峻觉 on 2019/6/20.
//  Copyright © 2019 周峻觉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Category)

+(NSData*)dataWithHexString:(NSString*)str;

+(NSString*)hexStringWithData:(NSData*)data;

+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key;

+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key;

+ (NSData *)threeDESDecrypt:(NSData *)data WithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
