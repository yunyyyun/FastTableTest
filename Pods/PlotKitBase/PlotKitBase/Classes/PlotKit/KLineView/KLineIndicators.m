//
//  KLineIndicators.m
//  GoIco
//
//  Created by zhulihong on 2017/10/25.
//  Copyright © 2017年 ico. All rights reserved.
//

#import "KLineIndicators.h"

//指标参数
#define KLineIndicatorsAllParamsDefine(define) \
define(MA1Param) \
define(MA2Param) \
define(MA3Param) \
define(MA4Param) \
define(MA5Param) \
define(MA6Param) \
define(MA7Param) \
define(MA8Param) \
\
define(MACDsParam) \
define(MACDlParam) \
define(MACDaParam) \
\
define(RSI1Param) \
define(RSI2Param) \
define(RSI3Param) \
\
define(WR1Param) \
define(WR2Param) \
\
define(KDJrParam) \
define(KDJkParam) \
define(KDJdParam) \
\
define(PSYnParam) \
define(PSYmParam) \
\
define(CCINParam) \
\
define(BIAS1Param) \
define(BIAS2Param) \
define(BIAS3Param) \
\
define(VRParam) \
\
define(BOLLmaParam) \
define(BOLLwParam) \
\
define(DMAshortMaParam) \
define(DMAlongMaParam) \
define(DMAdddMaParam) \
\
define(DMInParam) \
define(DMImParam) \
\
define(VOLMA1Param) \
define(VOLMA2Param) \
define(VOLMA3Param) \
define(VOLMA4Param) \
define(VOLMA5Param) \
define(VOLMA6Param) \
define(VOLMA7Param) \
define(VOLMA8Param) \
\
define(EMA1Param) \
define(EMA2Param) \
define(EMA3Param) \
\
define(TRIXParam) \

#define KLineIndicatorsKey(x) @"KLineIndicatorsKey_"#x

#define KLineIndicatorsAllShowsDefine(define) \
define(MA1Show) \
define(MA2Show) \
define(MA3Show) \
define(MA4Show) \
define(MA5Show) \
define(MA6Show) \
define(MA7Show) \
define(MA8Show) \
\
define(VOLMA1Show) \
define(VOLMA2Show) \
define(VOLMA3Show) \
define(VOLMA4Show) \
define(VOLMA5Show) \
define(VOLMA6Show) \
define(VOLMA7Show) \
define(VOLMA8Show) \


@interface KLineIndicators ()

@end

@implementation KLineIndicators

+ (instancetype)shareObject
{
	static KLineIndicators *indicators = nil;
	if (!indicators) {
		indicators = [KLineIndicators new];
		if (indicators.readLocalConfig) {
			[indicators readLocal];
		} else {
			[indicators readSysConfig];
		}
	}

	return indicators;
}

+ (instancetype)sysObject
{
	static KLineIndicators *indicators = nil;
	if (!indicators) {
		indicators = [KLineIndicators new];
		[indicators readSysConfig];
	}

	return indicators;
}

- (BOOL)readLocalConfig
{
	return [[[NSUserDefaults standardUserDefaults] valueForKey:KLineIndicatorsKey(readLocalConfig)] boolValue];
}

- (void)setReadLocalConfig:(BOOL)readLocalConfig
{
	[[NSUserDefaults standardUserDefaults] setObject:@(readLocalConfig) forKey:KLineIndicatorsKey(readLocalConfig)];
}

#define KLineIndicatorsSave(x) self.x = indicators.x;\
[[NSUserDefaults standardUserDefaults] setObject:@(self.x) forKey:KLineIndicatorsKey(x)];\
[[NSUserDefaults standardUserDefaults] synchronize];
- (void)saveCopy:(KLineIndicators *)indicators
{
	self.readLocalConfig = true;
	KLineIndicatorsAllParamsDefine(KLineIndicatorsSave)
    KLineIndicatorsAllShowsDefine(KLineIndicatorsSave)
}

#define KLineIndicatorsReadLocal(x) self.x = [[[NSUserDefaults standardUserDefaults] valueForKey:KLineIndicatorsKey(x)] intValue];
#define KLineIndicatorsReadLocalShow(x) self.x = [[[NSUserDefaults standardUserDefaults] valueForKey:KLineIndicatorsKey(x)] boolValue];
- (void)readLocal
{
    KLineIndicatorsAllParamsDefine(KLineIndicatorsReadLocal)
    KLineIndicatorsAllShowsDefine(KLineIndicatorsReadLocalShow)
    if (self.MA4Param == 0) {
        [self readMAconfig];
    }
    if (self.EMA1Param == 0) {
        [self readEMAconfig];
    }
    if (self.TRIXParam == 0) {
        [self readTRIXconfig];
    }
}

#define KLineIndicatorsCopy(x) indicators.x = self.x;
- (instancetype)copy
{
	KLineIndicators *indicators = [KLineIndicators new];

	KLineIndicatorsAllParamsDefine(KLineIndicatorsCopy)
    KLineIndicatorsAllShowsDefine(KLineIndicatorsCopy)

	return indicators;
}

#define KLineIndicatorsEqual(x) if (self.x != object.x) return false;
- (BOOL)isEqual:(KLineIndicators *)object
{
	KLineIndicatorsAllParamsDefine(KLineIndicatorsEqual)
    KLineIndicatorsAllShowsDefine(KLineIndicatorsEqual)

	return true;
}

- (void)readSysConfig
{
	[self readMAconfig];
	[self readMACDconfig];
	[self readRSIconfig];
	[self readWRconfig];
	[self readKDJconfig];
	[self readPSYconfig];
	[self readBIASconfig];
	[self readVRconfig];
	[self readBOLLconfig];
	[self readDMAconfig];
	[self readDMIconfig];
    [self readCCIconfig];
    [self readEMAconfig];
    [self readTRIXconfig];
}

- (void)readMAconfig
{
	_MA1Param = _VOLMA1Param = 7;
	_MA2Param = _VOLMA2Param = 15;
    _MA3Param = _VOLMA3Param = 30;
    _MA4Param = _VOLMA4Param = 5;
    _MA5Param = _VOLMA5Param = 20;
    _MA6Param = _VOLMA6Param = 60;
    _MA7Param = _VOLMA7Param = 120;
    _MA8Param = _VOLMA8Param = 250;
    _MA1Show = _MA2Show = _MA3Show = true;
    _MA4Show = _MA5Show = _MA6Show = _MA7Show = _MA8Show = false;

    _VOLMA1Show = _VOLMA2Show = _VOLMA3Show = true;
    _VOLMA4Show = _VOLMA5Show = _VOLMA6Show = _VOLMA7Show = _VOLMA8Show = false;
}

- (void)readMACDconfig
{
	_MACDsParam = 12;
	_MACDlParam = 26;
	_MACDaParam = 9;
}

- (void)readRSIconfig
{
	_RSI1Param = 6;
	_RSI2Param = 12;
	_RSI3Param = 24;
}

- (void)readWRconfig
{
	_WR1Param = 14;
	_WR2Param = 28;
}

- (void)readKDJconfig
{
	_KDJkParam = 9;
	_KDJdParam = 3;
    _KDJrParam = 3;
}

- (void)readPSYconfig
{
	_PSYnParam = 12;
	_PSYmParam = 6;
}

- (void)readBIASconfig
{
	_BIAS1Param = 6;
	_BIAS2Param = 12;
	_BIAS3Param = 24;
}

- (void)readVRconfig
{
	_VRParam = 26;
}

- (void)readBOLLconfig
{
	_BOLLmaParam = 20;
	_BOLLwParam = 2;
}

- (void)readDMAconfig
{
	_DMAshortMaParam = 10;
	_DMAlongMaParam = 50;
	_DMAdddMaParam = 10;
}

- (void)readDMIconfig
{
	_DMInParam = 14;
	_DMImParam = 6;
}

- (void)readCCIconfig
{
	_CCINParam = 14;
}

- (void)readEMAconfig
{
    _EMA1Param = 7;
    _EMA2Param = 25;
    _EMA3Param = 99;
}

- (void)readTRIXconfig
{
    _TRIXParam = 9;
}

@end
