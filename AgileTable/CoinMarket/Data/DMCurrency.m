//
//  DMCurrency.m
//  GoIco
//
//  Created by Andy on 2017/8/12.
//  Copyright © 2017年 ico. All rights reserved.
//

#import "DMCurrency.h"
//#import "DMData+Cache.h"
#import "Config.h"
#import "HTTPRequest.h"
#import "NSDate+String.h"
#import "NSString+PriceVolumeFormatter.h"
#ifdef INAPP
#import "DMTag.h"
#endif

#define RGB(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha: a]
#define titleColor RGB(0,0,0,1)
#define detailColor RGB(136,136,136,1)
#define sectionColor RGB(102,102,102,1)

@implementation DMCurrency

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self) {
        
        // bool isUsd = [MIUser sharedUser].accountMoney == 20;
        self.base = [dictionary objectForKey:@"base"];
        self.quote = [dictionary objectForKey:@"quote"];
        
        self.name = [dictionary objectForKey:@"name"];
        self.alias = [dictionary objectForKey:@"alias"];
        self.symbol = [dictionary objectForKey:@"symbol"];
        
        self.priceQuote = [dictionary objectForKey:@"priceQuote"];
        self.priceUsd = [dictionary objectForKey: @"priceUsd"];
        self.priceCny = [dictionary objectForKey: @"priceCny"];
        
        //self.convertPrice = [dictionary objectForKey: @"priceCny"];
        self.change = [dictionary objectForKey:@"change"];
        self.changePercent = [dictionary objectForKey:@"percentChangeH24"];
        if (self.changePercent == nil){
            self.changePercent = [dictionary objectForKey:@"percentChange24h"];
        }
        //if (self.change)
        //self.amount = [dictionary objectForKey: (isUsd ? @"amountUsdH24Str" : @"amountCnyH24Str")];
        self.amountCny = [dictionary objectForKey: @"amountCnyH24"];
        self.amountUsd = [dictionary objectForKey: @"amountUsdH24"];
        
        self.volume = [dictionary objectForKey:@"volumeBaseH24"];
        self.changeType = DMCurrencyPriceChangeDown;
        if ([self.change doubleValue]>0.000000001){
            self.changeType = DMCurrencyPriceChangeUp;
        }
        self.sourceType = [dictionary objectForKey:@"sourceType"];
        if (self.sourceType==nil){
            self.sourceType = [dictionary objectForKey:@"type"];
        }
        
        self.dataId = [dictionary objectForKey:@"id"];
        self.exchangeId = [dictionary objectForKey:@"exchangeId"];
        
        self.deliveryTime = [dictionary objectForKey:@"deliveryTime"];
        self.exchangeName = [dictionary objectForKey:@"exchangeName"];
        if (isNilString(self.exchangeName)){
            self.exchangeName = [dictionary objectForKey:@"exchange"];
        }
        NSString *exchangeAlias = [dictionary objectForKey:@"exchangeAlias"];
        if (!isNilString(exchangeAlias)){
            self.exchangeName = exchangeAlias;
        }
        if (isNilString(self.exchangeName)){
            self.exchangeName = @"";
        }
        if ([self.sourceType intValue] == 1){
            self.marketCapUsd = [dictionary objectForKey: @"marketCapUsd"];
            self.marketCapCny = [dictionary objectForKey: @"marketCapCny"];
            self.currencyId = [dictionary objectForKey:@"currencyId"];
            if (self.currencyId == nil){
                self.currencyId = [dictionary objectForKey:@"id"];
            }
        }
        else if ([self.sourceType intValue] == 2){
            self.tickerId = [dictionary objectForKey:@"tickerId"];
            if (self.tickerId == nil){
                self.tickerId = [dictionary objectForKey:@"id"];
            }
        }
        else if ([self.sourceType intValue] == 3){
            self.contractDisplay = [dictionary objectForKey:@"contractDisplay"];
            if (self.volume == nil)
                self.volume = [dictionary objectForKey:@"volumeUsd24h"];
            self.futureId = [dictionary objectForKey:@"futureId"];
        }
        else if ([self.sourceType intValue] == 4){
        }
        
        NSDictionary *favor =[dictionary objectForKey:@"favor"];
        if ([favor isKindOfClass: [NSDictionary class]]){
            self.favorId = [favor objectForKey:@"id"];
        }
        self.kLineEnabled = [[dictionary objectForKey:@"kLineEnabled"] boolValue];
        self.isFavorite = [[dictionary objectForKey:@"favorExist"] boolValue];
        self.curTickerId = [dictionary objectForKey:@"curTickerId"];
        self.statType = [dictionary objectForKey:@"statType"];
        
#ifdef INAPP
        NSArray *tags = [dictionary objectForKey:@"tags"];
        self.tags = [DMTag datasWithArray:tags];
        self.isAnimated = true;
#endif
    }
    
    return self;
}

- (void)updatePrice:(DMCurrencyRefresh *)obj
{
    double oldPrice = [self.priceCny doubleValue];
    double newPrice = [obj.priceCny doubleValue];
    if (newPrice <= 0) return;
    self.isAnimated = false;
    if (oldPrice < newPrice) {
        self.lastChange = DMCurrencyPriceChangeUp;
    } else if (oldPrice > newPrice ) {
        self.lastChange = DMCurrencyPriceChangeDown;
    } else {
        self.lastChange = DMCurrencyPriceChangeNone;
    }
    // self.lastChange = DMCurrencyPriceChangeUp; // todo, test
    // EDLog(@"initWithDictionaryinitWithDictionaryyyy123  %@  %@",[obj.change class] , obj.change);
    if ([obj.priceCny isKindOfClass: [NSNumber class]])
        self.priceCny = obj.priceCny;
    if ([obj.priceUsd isKindOfClass: [NSNumber class]])
        self.priceUsd = obj.priceUsd;
    if ([obj.priceQuote isKindOfClass: [NSNumber class]])
        self.priceQuote = obj.priceQuote;
    if ([obj.change isKindOfClass: [NSNumber class]])
        self.change = obj.change;
    else if ([obj.change isKindOfClass: [NSString class]])
        self.change = @([obj.change doubleValue]);
    if ([obj.changePercent isKindOfClass: [NSNumber class]])
        self.changePercent = obj.changePercent;
    
    if ([obj.volume isKindOfClass: [NSNumber class]])
        self.volume = obj.volume;
    if ([obj.marketCapUsd isKindOfClass: [NSNumber class]])
        self.marketCapUsd = obj.marketCapUsd;
    if ([obj.marketCapCny isKindOfClass: [NSNumber class]])
        self.marketCapCny = obj.marketCapCny;
    if ([obj.amountCny isKindOfClass: [NSNumber class]])
        self.amountCny = obj.amountCny;
    if ([obj.amountUsd isKindOfClass: [NSNumber class]])
        self.amountUsd = obj.amountUsd;
}

- (NSString *)display_rank{
    return [NSString stringWithFormat:@"%d", _rank];
}
- (NSString *)display_market{
    return @"";
}
- (NSAttributedString *)display_name{
    if ([self.sourceType intValue] == 1){
        if (isNilString(_symbol))
            _symbol = _base;
        if (isNilString(_symbol))
            _symbol = @"";
        if (isNilString(_alias))
            _alias = _name;
        if (isNilString(_alias))
            _alias = @"";
        
        // EDLog(@"display_namedisplay_name   %@  %@", _symbol, _alias);
        NSMutableAttributedString *fontAttributeNameStr = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@"%@ %@",_symbol, _alias]];
        NSInteger start = 0;
        [fontAttributeNameStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight: UIFontWeightSemibold] range:NSMakeRange(start, _symbol.length)];
        [fontAttributeNameStr addAttribute:NSForegroundColorAttributeName value: titleColor range: NSMakeRange(start, _symbol.length)];
        start += _symbol.length;
        
        [fontAttributeNameStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(start, _alias.length+1)];
        [fontAttributeNameStr addAttribute:NSForegroundColorAttributeName value: sectionColor range: NSMakeRange(start, _alias.length+1)];
        start += _alias.length+1;
        return fontAttributeNameStr;
    }
    else if ([self.sourceType intValue] == 2){
        if (isNilString(_base))
            _base = @"";
        if (isNilString(_quote))
            _quote = @"";
        NSMutableAttributedString *fontAttributeNameStr = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@"%@ %@",_base, _quote]];
        NSInteger start = 0;
        [fontAttributeNameStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight: UIFontWeightSemibold] range:NSMakeRange(start, _base.length)];
        [fontAttributeNameStr addAttribute:NSForegroundColorAttributeName value: titleColor range: NSMakeRange(start, _base.length)];
        start += _base.length;
        
        [fontAttributeNameStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(start, _quote.length+1)];
        [fontAttributeNameStr addAttribute:NSForegroundColorAttributeName value: sectionColor range: NSMakeRange(start, _quote.length+1)];
        start += _quote.length+1;
        return fontAttributeNameStr;
    }
    else{
        if (isNilString(_base))
            _base = @"";
        if (isNilString(_contractDisplay))
            _contractDisplay = @"";
        NSMutableAttributedString *fontAttributeNameStr = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@"%@ %@",_base, _contractDisplay]];
        NSInteger start = 0;
        [fontAttributeNameStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight: UIFontWeightSemibold] range:NSMakeRange(start, _base.length)];
        [fontAttributeNameStr addAttribute:NSForegroundColorAttributeName value: titleColor range: NSMakeRange(start, _base.length)];
        start += _base.length;
        
        [fontAttributeNameStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(start, _contractDisplay.length+1)];
        [fontAttributeNameStr addAttribute:NSForegroundColorAttributeName value: sectionColor range: NSMakeRange(start, _contractDisplay.length+1)];
        start += _contractDisplay.length+1;
        return fontAttributeNameStr;
    }
    
}
- (NSString *)display_volume{
    bool isUsd = false;
    NSString *fbFlag = isUsd? @"$": @"¥";
    if (_typeDetail>0){
        double volume = [_volume doubleValue];
        NSString *volumeStr = [NSString formatterAmountWith: volume];
        NSNumber *amountNumber = isUsd? _amountUsd: _amountCny;
        double amount = [amountNumber doubleValue];
        NSString *amountStr = [NSString formatterAmountWith: amount];
        return [NSString stringWithFormat:@"量/额 %@/%@%@", volumeStr, fbFlag, amountStr];
    }
    
    if ([self.sourceType intValue] == 1){  // 币显示市值
        NSNumber *marketCapNumber = isUsd? _marketCapUsd: _marketCapCny;
        if (![marketCapNumber isKindOfClass: [NSNumber class]]){
            return @"-";
        }
        
        double marketCap = [marketCapNumber doubleValue];
        NSString *marketCapStr = [NSString formatterAmountWith: marketCap];
        return [NSString stringWithFormat: @"市值 %@%@",fbFlag, marketCapStr];
    }
    else{
        if (![_volume isKindOfClass: [NSNumber class]]){
            return @"-";
        }
        double volume = [_volume doubleValue];
        NSString *volumeStr = [NSString formatterAmountWith: volume];
        return [NSString stringWithFormat:@"量 %@", volumeStr];
    }
}
- (NSString *)display_price{
    if (self.isBIKA){
        double price = [_priceCny doubleValue];
        NSString *priceStr = [NSString formatterPriceWith: price];
        return [NSString stringWithFormat: @"¥%@", priceStr];
    }
    NSNumber *priceNumber;
    BOOL isPairs = false;
    if ([self.sourceType intValue] == 1){
        priceNumber = _priceUsd;
    }
    else{
        priceNumber = _priceQuote;
        isPairs = true;
    }
    if (![priceNumber isKindOfClass: [NSNumber class]]){
        return @"-";
    }
    double price = [priceNumber doubleValue];
    NSString *priceStr = [NSString formatterPriceWith: price isPairs: isPairs];
    if ([self.sourceType intValue] == 1){
        priceStr = [NSString stringWithFormat: @"$%@", priceStr];
    }
    return priceStr;
}
- (NSString *)display_convertprice{
    if (self.isBIKA){
        double price = [_priceUsd doubleValue];
        NSString *priceStr = [NSString formatterPriceWith: price];
        return [NSString stringWithFormat:@"≈$%@", priceStr];
    }
    
    bool isUsd = false;
    if ([self.sourceType intValue] == 1){
        if (isUsd)
            return @"";
    }
    NSNumber *priceNumber = isUsd? _priceUsd: _priceCny;
    if (![priceNumber isKindOfClass: [NSNumber class]]){
        return @"-";
    }
    // EDLog(@"[MIUser sharedUser].accountMoney is : %ld", [MIUser sharedUser].accountMoney);
    NSString *fbFlag = isUsd? @"$": @"¥";
    double price = [priceNumber doubleValue];
    NSString *priceStr = [NSString formatterPriceWith: price];
    return [NSString stringWithFormat:@"≈%@%@",fbFlag, priceStr];
}
- (NSString *)display_changepercent{
    if (![_changePercent isKindOfClass: [NSNumber class]]
        && ![_changePercent isKindOfClass: [NSString class]]){
        return @"-";
    }
    return [NSString formatPercentFromChange: self.changePercent];
}
- (NSString *)display_change{
    if (![_change isKindOfClass: [NSNumber class]]){
        return @"-";
    }
    double change = [_change doubleValue];
    NSString *changeStr = [NSString formatterPriceWith: change isPairs: ([_sourceType intValue] != 1)];
    // NSString *changeStr = [NSString stringWithFormat:@"%.2f", [self.change doubleValue]];
    if (![changeStr containsString: @"-"] && ![changeStr containsString: @"+"] )
        changeStr = [NSString stringWithFormat: @"+%@", changeStr];
    return changeStr;
}

- (NSString *)self_alias{
    if ([self.sourceType intValue] == 1){
        NSString *alias = self.alias;
        if (isNilString(alias))
            alias = self.name;
        return [NSString stringWithFormat: @"%@ %@", @"全网价格", alias];
    }
    NSString *exchangeName = self.exchangeName;
    if (isNilString(exchangeName))
        exchangeName = self.name;
    return [NSString stringWithFormat: @"%@ %@", exchangeName, self.alias];
}
- (NSAttributedString *)self_name{
    NSString *frist = @"";
    NSString *second = @"";
    if ([self.sourceType intValue] == 1){
        frist = self.symbol;
    }
    else if ([self.sourceType intValue] == 2){
        NSArray *array = [self.symbol componentsSeparatedByString:@"-"];
        frist = [array firstObject];
        if (array.count>1){
            second = array[1];
        }
    }
    else if ([self.sourceType intValue] == 3){
        frist = self.symbol;
        second = self.contractDisplay;
    }
    NSMutableAttributedString *fontAttributeNameStr = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@"%@ %@",frist, second]];
    NSInteger start = 0;
    [fontAttributeNameStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight: UIFontWeightSemibold] range:NSMakeRange(start, frist.length)];
    [fontAttributeNameStr addAttribute:NSForegroundColorAttributeName value: titleColor range: NSMakeRange(start, frist.length)];
    start += frist.length;
    
    [fontAttributeNameStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(start, second.length+1)];
    [fontAttributeNameStr addAttribute:NSForegroundColorAttributeName value: detailColor range: NSMakeRange(start, second.length+1)];
    start += second.length+1;
    return fontAttributeNameStr;
}
- (NSString *)self_volume{
    double amount = [_volume doubleValue];
    NSString *volumeStr = [NSString formatterAmountWith: amount];
    return [NSString stringWithFormat:@"量 %@", volumeStr];
}
- (NSString *)self_price{
    //    if (![_price isKindOfClass: [NSNumber class]]){
    //        return @"-";
    //    }
    //    double price = [self.price doubleValue];
    //    NSString *priceStr = [NSString formatterPriceWith: price];
    //    if ([self.sourceType intValue] == 1){
    //        priceStr = [NSString stringWithFormat: @"$%@", priceStr];
    //    }
    //    return priceStr;
    NSNumber *priceNumber;
    if ([self.sourceType intValue] == 1){
        priceNumber = _priceUsd;
    }
    else{
        priceNumber = _priceQuote;
    }
    if (![priceNumber isKindOfClass: [NSNumber class]]){
        return @"-";
    }
    double price = [priceNumber doubleValue];
    NSString *priceStr = [NSString formatterPriceWith: price isPairs: ([_sourceType intValue] != 1)];
    if ([self.sourceType intValue] == 1){
        priceStr = [NSString stringWithFormat: @"$%@", priceStr];
    }
    return priceStr;
}
- (NSString *)self_convertPrice{
    bool isUsd = false;
    if ([self.sourceType intValue] == 1){
        if (isUsd)
            return @"";
    }
    NSNumber *priceNumber = isUsd? _priceUsd: _priceCny;
    if (![priceNumber isKindOfClass: [NSNumber class]]){
        return @"-";
    }
    // EDLog(@"[MIUser sharedUser].accountMoney is : %ld", [MIUser sharedUser].accountMoney);
    NSString *fbFlag = isUsd? @"$": @"¥";
    double price = [priceNumber doubleValue];
    NSString *priceStr = [NSString formatterPriceWith: price];
    return [NSString stringWithFormat:@"≈%@%@",fbFlag, priceStr];
}

- (BOOL)matchKey:(NSString *)key{
    if (isNilString(key))
        return true;
    
    NSString *name = [self.base lowercaseString];
    //NSString *quote = [self.quote lowercaseString];
    NSString *lowercaseKey = [key lowercaseString];
    EDLog(@" %@   -%@", name, lowercaseKey);
    return [name containsString: lowercaseKey];
}

- (void)animation:(NSTimeInterval)duration//进行动画
{
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        self.isAnimated = true;
        self.lastChange = DMCurrencyPriceChangeNone;
    });
}

- (void)setIsAnimated:(BOOL)isAnimated
{
    _isAnimated = isAnimated;
}


//- (BOOL)isMarketFrom
//{
//    return ![self.marketName isEqualToString:@"cmc"];
//}

- (NSString *)detailViewControllerTitle {
    //NSString *marketName = [NSString stringWithFormat:@"%@, ",self.marketNameDisplay];
    NSString *anchor = (self.isCMC || isNilString(self.anchor)) ? @"" :[NSString stringWithFormat:@"/%@",self.anchor];
    return [NSString stringWithFormat:@"%@%@" , self.symbol, anchor];
}

- (NSString *)pricedotDetail:(float)price
{
    if (price < 1) {
        return [NSString stringWithFormat:@"%f", price];
    } else {
        return [NSString stringWithFormat:@"%.2f", price];
    }
}

- (NSString *)hashKey
{
    NSNumber *dataId = self.dataId;
    //    if (![dataId isKindOfClass: [NSNumber class]])
    //        dataId = self.currencyId;
    //    if (![dataId isKindOfClass: [NSNumber class]])
    //        dataId = self.tickerId;
    //    if (![dataId isKindOfClass: [NSNumber class]])
    //        dataId = self.constractId;
    //    if (![dataId isKindOfClass: [NSNumber class]])
    //        dataId = self.exchangeId;
    // EDLog(@"hashKey   %@,  %@",self.sourceType, dataId );
    return [NSString stringWithFormat:@"%@,%@", self.sourceType, dataId];
}

#define kDMCurrencyKey(x, y) [NSString stringWithFormat:@"favorite_%ld_%@", x, SafeString(y)]

//备注里面包含的币
+ (NSURLSessionDataTask *)getMemorandumCurrencies:(void (^)(NSArray<DMCurrency *> *currencies))success failure:(void (^)(int code, NSString *error))failure
{
    return [[HTTPRequest shareObject] GETAndDetailData:@"/usercurrencynote/currencylist" parameters:nil success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSArray *list = [[responseObject valueForKey:@"data"] valueForKey:@"list"];
        NSArray<DMCurrency *> *currencies = [self datasWithArray:list];
        if (success) {
            success(currencies);
        }
    } failure:failure];
}

+ (NSURLSessionDataTask *)searchSymbol:(NSString *)symbol page:(int)page groupId:(NSString *)groupId success:(void (^)(NSArray<DMCurrency *> *currencies, BOOL isMore))success failure:(void (^)(int code, NSString *error))failure
{
    NSDictionary *params = @{@"keyword":SafeString(symbol),
                             @"need_favorite":@(true),
                             @"user_currency_group_id" :SafeString(groupId),
                             @"page" :@(page),
                             @"size" :@(20),
                             };
    return [[HTTPRequest shareObject] GETAndDetailData:@"/search/pairlist" parameters: params success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSArray *list = [[responseObject valueForKey:@"data"] valueForKey:@"list"];
        NSArray<DMCurrency *> *currencies = [self datasWithArray:list];
        BOOL isMore = currencies.count >= 20;
        EDLog(@"searchSymbolsearchSymbol %ld", currencies.count);
        if (success) {
            success(currencies, isMore);
        }
    } failure:failure];
}


+ (BOOL)isEqual:(NSArray<DMCurrency *> *)currencies to:(NSArray<DMCurrency *> *)newCurrencies
{
    if (currencies.count != newCurrencies.count)
        return false;
    
    for (int i = 0; i < currencies.count; i ++) {
        DMCurrency *currency = [currencies objectAtIndex:i];
        DMCurrency *newCurrency = [newCurrencies objectAtIndex:i];
        if (![currency.comId isEqualToString:newCurrency.comId] || ![currency.marketId isEqualToString:newCurrency.marketId] || currency.isFavorite != newCurrency.isFavorite) {
            return false;
        }
    }
    
    return true;
}

// 币详情
+ (NSURLSessionDataTask *)getCurrenctDetailWith: (DMCurrency *)currency
                                         sucess:(void (^)(DMCurrency *currencyDetail))success failure:(void (^)(int code, NSString *error))failure{
    
    NSDictionary *param = nil;
    if (currency.searchNumber){
        param = @{
                  @"searchNo" : currency.searchNumber,
                  };
    }
    
    NSNumber *dataId = currency.currencyId;
    if (dataId == nil){
        dataId = currency.dataId;
    }
    NSString *type = @"";
    if ([currency.sourceType intValue]==1){
        type = @"currency";
    }
    if ([currency.sourceType intValue]==2){
        type = @"ticker";
    }
    //    if ([currency.sourceType intValue]==3){
    //        type = @"future";
    //    }
    NSString *urlHost = [NSString stringWithFormat:@"/market/front/%@/%@",type, dataId];
    if (currency.isBIKA){
        urlHost = @"/burse/front/bika_info";
    }
    EDLog(@"test0701 -01 %@ %@", type, dataId);
    return [[HTTPRequest shareObject] GETAndDetailData: urlHost parameters: param success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSDictionary *data = [responseObject valueForKey:@"data"];
        
        bool isUsd = false;
        NSString *fbFlag = isUsd? @"$": @"¥";
        NSString *marketDisplay = [self getDataFromDic:data
                                               withKey: isUsd? @"marketCapUsd": @"marketCapCny"
                                                  type:2
                                               isPairs: [currency.sourceType intValue] != 1];
        marketDisplay = [NSString stringWithFormat: @"%@%@", fbFlag, marketDisplay];
        
        NSString *volumeDisplay = [self getDataFromDic:data
                                               withKey: @"volumeUsd24h"
                                                  type:2
                                               isPairs: [currency.sourceType intValue] != 1];
        
        NSString *amountDisplay = [self getDataFromDic:data
                                               withKey: isUsd? @"amountUsd24h": @"amountCny24h"
                                                  type:2
                                               isPairs: [currency.sourceType intValue] != 1];
        amountDisplay = [NSString stringWithFormat: @"%@%@", fbFlag, amountDisplay];
        NSString *max24 = [self getDataFromDic:data
                                       withKey: @"priceHigh24h"
                                          type:1
                                       isPairs: [currency.sourceType intValue] != 1];
        NSString *min24 = [self getDataFromDic:data
                                       withKey: @"priceLow24h"
                                          type:1
                                       isPairs: [currency.sourceType intValue] != 1];
        
        if (currency.change == nil){
            currency.change = [data objectForKey:@"numChange24h"];
        }
        if (currency.dataId == nil)
            currency.dataId = [data objectForKey:@"id"];
        if (currency.baseId == nil)
            currency.baseId = [data objectForKey:@"baseId"];
        if ([currency.sourceType intValue]==2){ // 交易对
            currency.headDatas = @[
                                   @{@"k":@"24h量",
                                     @"v": volumeDisplay},
                                   @{@"k":@"24h最高",
                                     @"v": max24},
                                   @{@"k":@"24h额",
                                     @"v": amountDisplay},
                                   @{@"k":@"24h最低",
                                     @"v": min24},
                                   @{@"k":@"总市值",
                                     @"v": marketDisplay},
                                   ];
        }
        else{   // 默认是币
            currency.headDatas = @[
                                   @{@"k":@"24h量",
                                     @"v": volumeDisplay},
                                   @{@"k":@"总市值",
                                     @"v": marketDisplay},
                                   @{@"k":@"24h额",
                                     @"v": amountDisplay},
                                   ];
        }
        if (!isNilString([data objectForKey: @"exchange"]))
            currency.exchangeName = [data objectForKey: @"exchange"];
        if (!isNilString([data objectForKey: @"exchangeName"]))
            currency.exchangeName = [data objectForKey: @"exchangeName"];
        
        currency.tickerId = [data objectForKey:@"tickerId"];
        currency.futureId = [data objectForKey:@"futureId"];
        NSString *exchangeAlias = [data objectForKey:@"exchangeAlias"];
        if (!isNilString(exchangeAlias)){
            currency.exchangeName = exchangeAlias;
        }
        
        
        NSString *tagNames = [data objectForKey: @"tagNames"];
        if (!isNilString(tagNames) && tagNames.length>2){
            NSArray *tagArr = [tagNames componentsSeparatedByString: @","];
            if ([tagArr isKindOfClass: [NSArray class]]){
                currency.tags = tagArr;
            }
        }
        
        currency.kLineEnabled = [[data objectForKey:@"klineEnabled"] intValue]==1;
        if ([[data objectForKey:@"favorExist"] intValue]==1){
            currency.isFavorite = true;
        }
        [DMCurrency addDataFromDic: data toCurrency: currency];
        
        if (success) {
            success(currency);
        }
    } failure:failure];
}

// 先取number、 后取string
+ (NSString *)getDataFromDic: (NSDictionary *)dic withKey:(NSString *)key type:(NSInteger )type isPairs: (BOOL) isPairs{
    NSNumber *origin = [dic objectForKey: key];
    if (![origin isKindOfClass: [NSNumber class]])
        return @"--";
    double originValue = [origin doubleValue];
    if (type==1){
        return [NSString formatterPriceWith: originValue isPairs: isPairs];
    }
    if (type==2){
        return [NSString formatterAmountWith: originValue];
    }
    return @"-";
}
// 详情补充数据
+ (void)addDataFromDic: (NSDictionary *)data toCurrency: (DMCurrency *)currency{
    currency.favorId = [data objectForKey:@"favorId"];
    if (currency.change == nil)
        currency.change = [data objectForKey:@"change"];
    if (currency.changePercent == nil){
        currency.changePercent = [data objectForKey:@"percentChangeH24"];
        if (currency.changePercent == nil){
            currency.changePercent = [data objectForKey:@"percentChange24h"];
        }
    }
    NSString *name = [data objectForKey:@"name"];
    if (!isNilString(name)){
        currency.name = name;
    }
    NSString *alias = [data objectForKey:@"alias"];
    if (alias){
        currency.alias = alias;
    }
    if ([[data objectForKey:@"favorExist"] intValue]==1){
        currency.isFavorite = true;
    }
    NSString *pair = [data objectForKey:@"pair"];
    if (!isNilString(pair) && isNilString(currency.symbol)){
        currency.symbol = pair;
    }
    
    if ([[data objectForKey:@"priceQuote"] isKindOfClass:[NSNumber class]])
        currency.priceQuote = [data objectForKey:@"priceQuote"];
    if ([[data objectForKey:@"priceUsd"] isKindOfClass:[NSNumber class]])
        currency.priceUsd = [data objectForKey: @"priceUsd"];
    if ([[data objectForKey:@"priceCny"] isKindOfClass:[NSNumber class]])
        currency.priceCny = [data objectForKey: @"priceCny"];
    if ([[data objectForKey:@"logo"] isKindOfClass:[NSString class]])
        currency.logo = [data objectForKey: @"logo"];
    
}
// 合约详情
+ (NSURLSessionDataTask *)getConstractDetailWith: (DMCurrency *)currency
                                          sucess:(void (^)(DMCurrency *currencyDetail))success failure:(void (^)(int code, NSString *error))failure;{
    NSDictionary *param = nil;
    if (currency.searchNumber){
        param = @{
                  @"searchNo" : currency.searchNumber,
                  };
    }
    NSString *urlHost = [NSString stringWithFormat:@"/market/front/future/%@", currency.dataId];
    return [[HTTPRequest shareObject] GETAndDetailData: urlHost parameters: param success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSDictionary *data = [responseObject valueForKey:@"data"];
        bool isUsd = false;
        NSString *marketDisplay = [self getDataFromDic:data
                                               withKey: isUsd? @"marketCapUsd": @"marketCapCny"
                                                  type:2
                                               isPairs: [currency.sourceType intValue] != 1];
        
        NSString *fbFlag = isUsd? @"$": @"¥";
        marketDisplay = [NSString stringWithFormat: @"%@%@", fbFlag, marketDisplay];
        NSString *volumeDisplay = [self getDataFromDic:data
                                               withKey: @"volumeUsd24h"
                                                  type:2
                                               isPairs: [currency.sourceType intValue] != 1];
        
        NSString *amountDisplay = [self getDataFromDic:data
                                               withKey: isUsd? @"amountUsd24h": @"amountCny24h"
                                                  type:2
                                               isPairs: [currency.sourceType intValue] != 1];
        amountDisplay = [NSString stringWithFormat: @"%@%@", fbFlag, amountDisplay];
        NSString *max24 = [self getDataFromDic:data
                                       withKey: @"priceHigh24h" // priceHighH24
                                          type:1
                                       isPairs: [currency.sourceType intValue] != 1];
        NSString *min24 = [self getDataFromDic:data
                                       withKey: @"priceLow24h"
                                          type:1
                                       isPairs: [currency.sourceType intValue] != 1];
        
        currency.deliveryTime = [data objectForKey:@"deliveryTime"];
        currency.headDatas = @[
                               @{@"k":@"24h量",
                                 @"v": volumeDisplay},
                               @{@"k":@"24h最高",
                                 @"v": max24},
                               @{@"k":@"24h额",
                                 @"v": amountDisplay},
                               @{@"k":@"24h最低",
                                 @"v": min24},
                               @{@"k":@"总市值",
                                 @"v": marketDisplay},
                               ];
        if (currency.change == nil){
            currency.change = [data objectForKey:@"numChange24h"];
        }
        if (currency.dataId == nil)
            currency.dataId = [data objectForKey:@"id"];
        if (!isNilString([data objectForKey: @"exchange"]))
            currency.exchangeName = [data objectForKey: @"exchange"];
        if (!isNilString([data objectForKey: @"exchangeName"]))
            currency.exchangeName = [data objectForKey: @"exchangeName"];
        currency.tickerId = [data objectForKey:@"tickerId"];
        currency.futureId = [data objectForKey:@"futureId"];
        currency.baseId = [data objectForKey:@"baseId"];
        currency.statType = [data objectForKey:@"statType"];
        NSString *tagNames = [data objectForKey: @"tagNames"];
        if (!isNilString(tagNames) && tagNames.length>2){
            NSArray *tagArr = [tagNames componentsSeparatedByString: @","];
            if ([tagArr isKindOfClass: [NSArray class]]){
                currency.tags = tagArr;
            }
        }
        
        NSString *exchangeAlias = [data objectForKey:@"exchangeAlias"];
        if (!isNilString(exchangeAlias)){
            currency.exchangeName = exchangeAlias;
        }
        
        [DMCurrency addDataFromDic: data toCurrency: currency];
        if (success) {
            success(currency);
        }
    } failure:failure];
}

// 币卡币详情
+ (NSURLSessionDataTask *)getBikaDetailWith: (DMCurrency *)currency
                                         sucess:(void (^)(DMCurrency *currencyDetail))success failure:(void (^)(int code, NSString *error))failure;{
    NSString *urlHost = [NSString stringWithFormat:@"/burse/front/bika_info"];
    return [[HTTPRequest shareObject] GETAndDetailData: urlHost parameters: nil success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSDictionary *data = [responseObject valueForKey:@"data"];
        bool isUsd = false;
        NSString *marketDisplay = [self getDataFromDic: data
                                                withKey: @"circulation"
                                                    type: 2
                                               isPairs: [currency.sourceType intValue] != 1];
        
        NSString *fbFlag = isUsd? @"$": @"¥";
        // marketDisplay = [NSString stringWithFormat: @"%@%@", fbFlag, marketDisplay];
        NSString *volumeDisplay = [self getDataFromDic:data
                                                withKey: @"volumeBaseH24"
                                                  type:2
                                               isPairs: [currency.sourceType intValue] != 1];
        
        NSString *amountDisplay = [self getDataFromDic:data
                                               withKey: isUsd? @"amountUsdH24": @"amountCnyH24"
                                                  type:2
                                               isPairs: [currency.sourceType intValue] != 1];
        amountDisplay = [NSString stringWithFormat: @"%@%@", fbFlag, amountDisplay];
        NSString *max24 = [self getDataFromDic:data
                                       withKey: @"priceHighH24" // priceHighH24
                                          type:1
                                       isPairs: [currency.sourceType intValue] != 1];
        NSString *min24 = [self getDataFromDic:data
                                       withKey: @"priceLowH24"
                                          type:1
                                       isPairs: [currency.sourceType intValue] != 1];
        max24 = [NSString stringWithFormat: @"¥%@", max24];
        min24 = [NSString stringWithFormat: @"¥%@", min24];
        
        currency.deliveryTime = [data objectForKey:@"deliveryTime"];
        
        
        BOOL showMarket = false;
        if ([[data objectForKey: @"circulation"] isKindOfClass: [NSString class]] || [[data objectForKey: @"circulation"] isKindOfClass: [NSNumber class]]){
            double market = [[data objectForKey: @"circulation"] doubleValue];
            if (market>=0)
                showMarket = true;
        }
        if (showMarket)
            currency.headDatas = @[
                               @{@"k":@"24h量",
                                 @"v": volumeDisplay},
                               @{@"k":@"24h最高",
                                 @"v": max24},
                               @{@"k":@"24h额",
                                 @"v": amountDisplay},
                               @{@"k":@"24h最低",
                                 @"v": min24},
                               @{@"k":@"流通量",
                                 @"v": marketDisplay},
                               ];
        else
            currency.headDatas = @[
                                   @{@"k":@"24h量",
                                     @"v": volumeDisplay},
                                   @{@"k":@"24h最高",
                                     @"v": max24},
                                   @{@"k":@"24h额",
                                     @"v": amountDisplay},
                                   @{@"k":@"24h最低",
                                     @"v": min24},
                                   ];
        if (currency.change == nil){
            currency.change = [data objectForKey:@"numChange24h"];
        }
        if (currency.dataId == nil)
            currency.dataId = [data objectForKey:@"id"];
        if (!isNilString([data objectForKey: @"exchange"]))
            currency.exchangeName = [data objectForKey: @"exchange"];
        if (!isNilString([data objectForKey: @"exchangeName"]))
            currency.exchangeName = [data objectForKey: @"exchangeName"];
        currency.tickerId = [data objectForKey:@"tickerId"];
        currency.futureId = [data objectForKey:@"futureId"];
        currency.baseId = [data objectForKey:@"baseId"];
        currency.statType = [data objectForKey:@"statType"];
        NSString *tagNames = [data objectForKey: @"tagNames"];
        
        currency.priceUsd = [data objectForKey: @"priceUsd"];
        currency.priceCny = [data objectForKey: @"priceCny"];
        currency.change = [data objectForKey:@"numChangeH24"];
        
        
        currency.changePercent = [data objectForKey:@"percentChangeH24"];
        if (currency.changePercent == nil){
            currency.changePercent = [data objectForKey:@"percentChange24h"];
        }
        
        if (!isNilString(tagNames) && tagNames.length>2){
            NSArray *tagArr = [tagNames componentsSeparatedByString: @","];
            if ([tagArr isKindOfClass: [NSArray class]]){
                currency.tags = tagArr;
            }
        }
        
        NSString *exchangeAlias = [data objectForKey:@"exchangeAlias"];
        if (!isNilString(exchangeAlias)){
            currency.exchangeName = exchangeAlias;
        }
        
        [DMCurrency addDataFromDic: data toCurrency: currency];
        if (success) {
            success(currency);
        }
    } failure:failure];
}

+ (NSURLSessionDataTask *)getCurrenciesWithExchangeId: (NSString *)exchangeId
                                              quoteId: (NSString *)quoteId
                                             baseName: (NSString *)baseName
                                                 sort: (NSString *)sort
                                               sucess: (void (^)(NSArray<DMCurrency *> *currencies, NSArray *quotes))success failure:(void (^)(int code, NSString *error))failure{
    NSDictionary *params = @{@"exchangeId":SafeString(exchangeId),
                             @"quoteId":SafeString(quoteId),
                             @"baseName":SafeString(baseName),
                             @"sort":SafeString(sort),
                             };
    return [[HTTPRequest shareObject] GETAndDetailData:@"/market/front/ticker/" parameters: params success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSArray *list = [[responseObject valueForKey:@"data"] valueForKey:@"tickers"];
        NSArray<DMCurrency *> *currencies = [self datasWithArray:list];
        NSArray *arr = [[responseObject valueForKey:@"data"] valueForKey:@"quotes"];
        
        NSMutableArray *quotes = [[NSMutableArray alloc] init];
        if ([arr isKindOfClass: [NSArray class]]){
            quotes = [arr mutableCopy];
        }
        
        if (success) {
            success(currencies, quotes);
        }
    } failure:failure];
}

// 合约列表
+ (NSURLSessionDataTask *)getContractsWithExchangeId: (NSString *)exchangeId
                                              sucess:(void (^)(NSArray *currencyDic))success failure:(void (^)(int code, NSString *error))failure{
    NSDictionary *params = @{@"exchangeId":SafeString(exchangeId),
                             };
    return [[HTTPRequest shareObject] GETAndDetailData: @"/market/front/future/" parameters: params success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSArray *datas = [responseObject valueForKey:@"data"];
        NSMutableArray *currencyDics = [[NSMutableArray alloc] init];
        for (int i=0; i<datas.count; ++i){
            NSDictionary *dic = datas[i];
            if ([dic isKindOfClass: [NSDictionary class]]){
                NSString *quote = [dic objectForKey: @"quote"];
                NSString *quoteId = [dic objectForKey: @"quoteId"];
                NSArray *futures = [dic objectForKey: @"futures"];
                NSArray<DMCurrency *> *currencies = [self datasWithArray:futures];
                NSDictionary *dic = @{
                                      @"quote" : quote,
                                      @"quoteId" : quoteId,
                                      @"currencies" : currencies,
                                      };
                [currencyDics addObject: dic];
            }
        }
        if (success) {
            success(currencyDics);
        }
    } failure:failure];
}


// 板块详情
+ (NSURLSessionDataTask *)getCurrenciesWithBlockId: (NSString *) blockId
                                              sort: (NSString *)sort
                                              page: (int)page
                                            sucess:(void (^)(NSArray *currencies))success failure:(void (^)(int code, NSString *error))failure{
    NSDictionary *params = @{@"blockId":SafeString(blockId),
                             @"sort":SafeString(sort),
                             @"pageNum": @(page),
                             @"pageSize": @(commonPageSize),
                             };
    EDLog(@"getCurrenciesWithBlockId request  %@", params);
    return [[HTTPRequest shareObject] GETAndDetailData:@"/market/front/currency/" parameters: params success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSArray *list = [[responseObject valueForKey:@"data"] valueForKey:@"list"];
        NSArray<DMCurrency *> *currencies = [self datasWithArray:list];
        if (success) {
            success(currencies);
        }
    } failure:failure];
}

// 市值 currency 列表
+ (NSURLSessionDataTask *)getCurrenciesWithPage: (int) pageNum
                                           Sort: (NSString *)sort
                                         sucess:(void (^)(NSArray *currencies))success failure:(void (^)(int code, NSString *error))failure{
    NSDictionary *params = @{@"pageNum": @(pageNum),
                             @"pageSize": @(commonPageSize),
                             @"sort": SafeString(sort),
                             };
//    DMCurrency *c = [[DMCurrency alloc] init];
//    NSArray *currencies = @[c];
//    success(currencies);
//    return nil;
    return [[HTTPRequest shareObject] GETAndDetailData:@"/market/front/currencys" parameters: params success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSArray *list = [[responseObject valueForKey:@"data"] valueForKey:@"list"];
        NSArray<DMCurrency *> *currencies = [self datasWithArray:list];
        if (success) {
            success(currencies);
        }
    } failure:failure];
}

// 币详情下面，获取币列表
+ (NSURLSessionDataTask *)getCurrenciesWithCurrency: (DMCurrency *) currency
                                               page:(int)page
                                             sucess:(void (^)(NSArray *currencyDics))success failure:(void (^)(int code, NSString *error))failure{
    NSNumber *dataId =  currency.dataId;
    NSString *host = @"";
    if ([currency.sourceType intValue]==1){
        host = @"/market/front/ticker/base/";
    }
    if ([currency.sourceType intValue]==2){
        host = @"/market/front/ticker/quotation";
        dataId = currency.baseId;
    }
    if ([currency.sourceType intValue]==3){
        host = @"/market/front/future/quotation";
        dataId = currency.baseId;
    }
    NSString *idStr = [NSString stringWithFormat: @"%@", dataId];
    NSDictionary *params = @{@"baseId": idStr,
                             @"pageNum": @(page),
                             @"pageSize": @(4),
                             };
    EDLog(@"getCurrenciesWithCurrencyId %@  %@",host, params);
    return [[HTTPRequest shareObject] GETAndDetailData: host parameters: params success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        id datas = [responseObject objectForKey: @"data"];
        NSArray *list;
        if ([datas isKindOfClass:[NSArray class]]){
            list = (NSMutableArray *)datas;
        }
        if ([datas isKindOfClass:[NSDictionary class]]){
            list = [datas objectForKey: @"list"];
        }
        NSMutableArray *currencyDics = [[NSMutableArray alloc] init];
        for (int i=0; i<list.count; ++i){
            NSDictionary *dic = list[i];
            if ([dic isKindOfClass: [NSDictionary class]]){
                NSString *name = [dic objectForKey: @"name"];
                NSString *alias = [dic objectForKey: @"alias"];
                NSArray *tickers = [dic objectForKey: @"tickers"];
                NSArray<DMCurrency *> *currencies = [self datasWithArray:tickers];
                NSDictionary *dic = @{
                                      @"name" : name,
                                      @"alias" : alias,
                                      @"currencies" : currencies,
                                      };
                [currencyDics addObject: dic];
            }
        }
        if (success) {
            success(currencyDics);
        }
    } failure:failure];
}

// 详情的， 观点
+ (NSURLSessionDataTask *)getNoticeWithCurrencyId:(NSNumber *)currencyId
                                             Page:(int)page
                                          success:(void (^)(NSArray *noticeList))success
                                          failure:(void (^)(int code, NSString *error))failure{
    NSDictionary *params = @{
                             @"currencyId" : SafeString(currencyId),
                             @"pageNum" : @(page),
                             @"pageSize" : @(commonPageSize),
                             };
    EDLog(@" getNoticeWithCurrencyId parameters %@", params);
    return [[HTTPRequest shareObject] GETAndDetailData:@"/viewpoint/front/viewpoint" parameters:params success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSDictionary *data = [responseObject valueForKey:@"data"];
        NSArray *exchangeList = [data valueForKey:@"list"];
        if (success) {
            success(exchangeList);
        }
    } failure:^(int code, NSString * _Nonnull error) {
        if (failure) {
            failure(code, error);
        }
    }];
}

@end

@implementation DMCurrencyRefresh

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self) {
        // bool isUsd = [MIUser sharedUser].accountMoney == 20;
        self.priceQuote = [dictionary objectForKey:@"priceQuote"];
        //
        self.priceUsd = [dictionary objectForKey: @"priceUsd"];
        self.priceCny = [dictionary objectForKey: @"priceCny"];
        self.change = [dictionary objectForKey:@"change"];
        if (self.change == nil){
            self.change = [dictionary objectForKey:@"numChange24h"];
        }
        if (self.change == nil){
            self.change = [dictionary objectForKey:@"numChange24H"];
        }
        // EDLog(@"initWithDictionaryinitWithDictionaryyyy  %@  %@",[self.change class] , self.change);
        self.changePercent = [dictionary objectForKey:@"percentChangeH24"];
        if (self.changePercent == nil){
            self.changePercent = [dictionary objectForKey:@"percentChange24h"];
        }
        
        self.sourceType = [dictionary objectForKey:@"sourceType"];
        if (self.sourceType==nil){
            self.sourceType = [dictionary objectForKey:@"type"];
        }
        self.dataId = [dictionary objectForKey:@"id"];
        self.currencyId = [dictionary objectForKey:@"currencyId"];
        self.tickerId = [dictionary objectForKey:@"tickerId"];
        if (self.tickerId == nil){
            self.tickerId = [dictionary objectForKey:@"id"];
        }
        self.exchangeId = [dictionary objectForKey:@"exchangeId"];
        
        self.volume = [dictionary objectForKey:@"volumeBaseH24"];
        if (self.volume == nil)
            self.volume = [dictionary objectForKey:@"volumeUsd24h"];
        self.marketCapUsd = [dictionary objectForKey: @"marketCapUsd"];
        self.marketCapCny = [dictionary objectForKey: @"marketCapCny"];
        self.amountCny = [dictionary objectForKey: @"amountCnyH24"];
        self.amountUsd = [dictionary objectForKey: @"amountUsdH24"];
        
        NSNumber *dataId = self.dataId;
        self.hashKey = [NSString stringWithFormat:@"%@,%@", self.sourceType, dataId];
    }
    return self;
}

//价格刷新
+ (NSURLSessionDataTask *)refresh:(NSArray<DMCurrency *> *)currencies success:(void (^)(NSArray *responseList))success failure:(void (^)(int code, NSString *error))failure {
    // EDLog(@"refreshrefresh : %ld", currencies.count);
    NSMutableString *string = [NSMutableString string];
    [currencies enumerateObjectsUsingBlock:^(DMCurrency * _Nonnull currency, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx<100){
            if (idx != 0)
                [string appendString:@"|"];
            NSString *key = currency.hashKey;
            [string appendString: key];
            // keyCurrenies[key] = currency;
        }
    }];
    // EDLog(@"initWithDictionaryinitWithDictionary  string00 : %@",string );
    return [self refreshPair:string success:^(NSArray<DMCurrencyRefresh *> *responseList) {
        [responseList enumerateObjectsUsingBlock:^(DMCurrencyRefresh * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //            EDLog(@"initWithDictionaryinitWithDictionary  string11111 : %@",obj.hashKey );
            [currencies enumerateObjectsUsingBlock:^(DMCurrency * _Nonnull cc, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.hashKey isEqualToString: cc.hashKey]){
                    [cc updatePrice:obj];
                }
            }];
        }];
        if (success) {
            success(responseList);
        }
    } failure:failure];
}

//价格刷新 [NSString stringWithFormat:@"%@_%@_%@_%@", self.marketId, self.name, self.symbol, self.anchor];
+ (NSURLSessionDataTask *)refreshPair:(NSString *)pairsKey success:(void (^)(NSArray<DMCurrencyRefresh *> *responseList))success failure:(void (^)(int code, NSString *error))failure {
    // EDLog(@"refreshPair: %@", pairsKey);
    return [[HTTPRequest shareObject] GETAndDetailData:@"/market/front/dataflush" parameters:@{@"ds":pairsKey} success:^(NSDictionary<NSString *,id> * _Nonnull responseObject) {
        NSArray *list = [responseObject valueForKey:@"data"];
        NSArray<DMCurrencyRefresh *> *currencies = [self datasWithArray:list];
        if (success) {
            success(currencies);
        }
    } failure:^(int code, NSString * _Nonnull error) {
        if (failure) {
            failure(code, error);
        }
    }];
}

@end


NSString *DMCurrencySortValue(DMCurrencySortType type)
{
    switch (type) {
        case DMCurrencySortTypeCap:
            return @"market_cap_usd";
            break;
        case DMCurrencySortTypeVolume:
            return @"volume_24h_usd";
            break;
        case DMCurrencySortTypePrice:
            return @"price_cny";
            break;
        case DMCurrencySortTypeChange:
            return @"percent_change_utc0";
            break;
        case DMCurrencySortTypeSymbol:
            return @"symbol";
            
        case DMCurrencySortTypeDefualt:
            return nil;
    }
    return nil;
}
