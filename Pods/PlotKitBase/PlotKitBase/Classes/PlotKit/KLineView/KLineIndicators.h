//
//  KLineIndicators.h
//  GoIco
//
//  Created by zhulihong on 2017/10/25.
//  Copyright © 2017年 ico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLineIndicators : NSObject

//指标参数
@property (nonatomic, assign) int MA1Param;
@property (nonatomic, assign) int MA2Param;
@property (nonatomic, assign) int MA3Param;
@property (nonatomic, assign) int MA4Param;
@property (nonatomic, assign) int MA5Param;
@property (nonatomic, assign) int MA6Param;
@property (nonatomic, assign) int MA7Param;
@property (nonatomic, assign) int MA8Param;

@property (nonatomic, assign) int MACDsParam;
@property (nonatomic, assign) int MACDlParam;
@property (nonatomic, assign) int MACDaParam;

@property (nonatomic, assign) int RSI1Param;
@property (nonatomic, assign) int RSI2Param;
@property (nonatomic, assign) int RSI3Param;

@property (nonatomic, assign) int WR1Param;
@property (nonatomic, assign) int WR2Param;

@property (nonatomic, assign) int KDJrParam;
@property (nonatomic, assign) int KDJkParam;
@property (nonatomic, assign) int KDJdParam;

@property (nonatomic, assign) int PSYnParam;
@property (nonatomic, assign) int PSYmParam;

@property (nonatomic, assign) int CCINParam;

@property (nonatomic, assign) int BIAS1Param;
@property (nonatomic, assign) int BIAS2Param;
@property (nonatomic, assign) int BIAS3Param;

@property (nonatomic, assign) int VRParam;

@property (nonatomic, assign) int BOLLmaParam;
@property (nonatomic, assign) int BOLLwParam;

@property (nonatomic, assign) int DMAshortMaParam;
@property (nonatomic, assign) int DMAlongMaParam;
@property (nonatomic, assign) int DMAdddMaParam;

@property (nonatomic, assign) int DMInParam;
@property (nonatomic, assign) int DMImParam;

@property (nonatomic, assign) int VOLMA1Param;
@property (nonatomic, assign) int VOLMA2Param;
@property (nonatomic, assign) int VOLMA3Param;
@property (nonatomic, assign) int VOLMA4Param;
@property (nonatomic, assign) int VOLMA5Param;
@property (nonatomic, assign) int VOLMA6Param;
@property (nonatomic, assign) int VOLMA7Param;
@property (nonatomic, assign) int VOLMA8Param;

@property (nonatomic, assign) int EMA1Param;
@property (nonatomic, assign) int EMA2Param;
@property (nonatomic, assign) int EMA3Param;

@property (nonatomic, assign) int TRIXParam;

//是否显示
@property (nonatomic, assign) BOOL MA1Show;
@property (nonatomic, assign) BOOL MA2Show;
@property (nonatomic, assign) BOOL MA3Show;
@property (nonatomic, assign) BOOL MA4Show;
@property (nonatomic, assign) BOOL MA5Show;
@property (nonatomic, assign) BOOL MA6Show;
@property (nonatomic, assign) BOOL MA7Show;
@property (nonatomic, assign) BOOL MA8Show;

//是否显示
@property (nonatomic, assign) BOOL VOLMA1Show;
@property (nonatomic, assign) BOOL VOLMA2Show;
@property (nonatomic, assign) BOOL VOLMA3Show;
@property (nonatomic, assign) BOOL VOLMA4Show;
@property (nonatomic, assign) BOOL VOLMA5Show;
@property (nonatomic, assign) BOOL VOLMA6Show;
@property (nonatomic, assign) BOOL VOLMA7Show;
@property (nonatomic, assign) BOOL VOLMA8Show;

+ (instancetype)shareObject;
+ (instancetype)sysObject;

//读取默认配置
- (void)readSysConfig;
//保存配置
- (void)saveCopy:(KLineIndicators *)indicators;

@end
