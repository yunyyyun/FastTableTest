//
//  DES3Util.h
//  DES
//
//  Created by Toni on 12-12-27.
//  Copyright (c) 2012年 sinofreely. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMBase64.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSString+NSReplace.h"
#import "NSData+Category.h"
@interface DES3Util : NSObject

//加密方法
+(NSString *) encryptUseDES:(NSString *)plainText;
//解密方法
+(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;

-(NSString *) encryptUseDES2:(NSString *)plainText key:(NSString *)key;
+ (NSString *)keyAtVersion;
@end
