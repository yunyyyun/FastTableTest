//
//  DES3Util.m
//  DES
//
//  Created by Toni on 12-12-27.
//  Copyright (c) 2012年 sinofreely. All rights reserved.
//

#import "DES3Util.h"
#define gkey            @"mh2_&@OddV54"  // @"amntfjjhjs"  // 
#define gIv             @"01234567"


@implementation DES3Util


 const Byte iv[] = {1,2,3,4,5,6,7,8};


//Des加密
 +(NSString *) encryptUseDES:(NSString *)plainText
 {
     NSString *key = [DES3Util keyAtVersion];
     NSString *ciphertext = nil;
     NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
     NSUInteger dataLength = [textData length];
     size_t bufferSize = dataLength + kCCBlockSizeDES;
     unsigned char buffer[bufferSize];
     memset(buffer, 0, sizeof(char));
     size_t numBytesEncrypted = 0;
     CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                           kCCAlgorithmDES,
                                           kCCOptionPKCS7Padding|kCCOptionECBMode,
                                           [key UTF8String],
                                           kCCKeySizeDES,
                                           iv,
                                           [textData bytes],
                                           dataLength,
                                           buffer,
                                           bufferSize,
                                           &numBytesEncrypted);
         if (cryptStatus == kCCSuccess) {
             NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
             ciphertext = [NSData hexStringWithData:data];
             ciphertext = [ciphertext uppercaseStringWithLocale:[NSLocale currentLocale]];
         }
         return ciphertext;
     }

-(NSString *) encryptUseDES2:(NSString *)plainText key:(NSString *)key{
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    size_t dataLength = [plainText length];
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (dataLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithm3DES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String], kCCKeySize3DES,
                                          NULL,
                                          textBytes, dataLength,
                                          (void *)bufferPtr, bufferPtrSize,
                                          &movedBytes);
    if (cryptStatus == kCCSuccess) {
        
        ciphertext= [self parseByte2HexString:bufferPtr :(int)movedBytes];
        
    }
    ciphertext=[ciphertext uppercaseString];//字符变大写
    
    return ciphertext ;
}

- (NSString *) parseByte2HexString:(Byte *) bytes  :(int)len{
    NSString *hexStr = @"";
    if(bytes)
    {
        for(int i=0;i<len;i++)
        {
            NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff]; ///16进制数
            if([newHexStr length]==1)
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            else
            {
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
            }
            
            NSLog(@"%@",hexStr);
        }
    }
    return hexStr;
}

//Des解密
 +(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key
 {
         NSString *plaintext = nil;
         NSData *cipherdata = [GTMBase64 decodeString:cipherText];
         unsigned char buffer[1024];
         memset(buffer, 0, sizeof(char));
         size_t numBytesDecrypted = 0;
         CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                                           kCCOptionPKCS7Padding,
                                                           [key UTF8String], kCCKeySizeDES,
                                                           iv,
                                                           [cipherdata bytes], [cipherdata length],
                                                           buffer, 1024,
                                                           &numBytesDecrypted);
         if(cryptStatus == kCCSuccess)
         {
                NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
                 plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
         }
     return plaintext;
}

+ (NSString *)keyAtVersion {
    return @"N8b%M89$H2Tr";
////#if DEBUG
////    return @"mq2P&@YdrV55";
////#endif
//    NSString *version = [LXMethod version];
//    if ([version isEqualToString:@"2.0.2"]) {
//        return @"amntfjjhjs";
//    } else if ([version isEqualToString:@"2.1.0"]) {
//        return @"mh2_&@OddV54";
//    } else if ([version isEqualToString:@"2.2.0"]) {
//#if DEBUG
//        // 生产 or 预生产
//        if (SH_TEST_URL == 0 || SH_TEST_URL == 1) {
//            return @"m56R*_(4&HWeio2";
//        } else {
//            return @"lopvbfkid";
//        }
//#else
//        return @"m56R*_(4&HWeio2";
//#endif
//    } else if ([version isEqualToString:@"2.2.2"]) {
//#if DEBUG
//        // 生产 or 预生产
//        if (SH_TEST_URL == 0 || SH_TEST_URL == 1) {
//            return @"H*j17$L15&Op";
//        } else {
//            return @"H*j17$L15&Op";
//        }
//#else
//        return @"H*j17$L15&Op";
//#endif
//    } else if ([version isEqualToString:@"2.2.4"]) {
//#if DEBUG
//        // 生产 or 预生产
//        if (SH_TEST_URL == 0 || SH_TEST_URL == 1) {
//            return @"N8b%M89$H2Tr";
//        } else {
//            return @"lopvbfkid";
//        }
//#else
//        return @"N8b%M89$H2Tr";
//#endif
//    } else if ([version isEqualToString:@"2.2.5"]) {
//#if DEBUG
//        // 生产 or 预生产
//        if (SH_TEST_URL == 0 || SH_TEST_URL == 1) {
//            return @"N8b%M89$H2Tr";
//        } else {
//            return @"lopvbfkid";
//        }
//#else
//        return @"N8b%M89$H2Tr";
//#endif
//    } else {
//        return @"";
//    }
}


@end
