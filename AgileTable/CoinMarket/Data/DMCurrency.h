//
//  DMCurrency.h
//  GoIco
//
//  Created by Andy on 2017/8/12.
//  Copyright © 2017年 ico. All rights reserved.
//

#import "DMData.h"
#import "Config.h"

typedef NS_ENUM(NSUInteger, DMCurrencySortType) {
    DMCurrencySortTypeDefualt = 0,  //默认
    DMCurrencySortTypeCap,          //市值
    DMCurrencySortTypeVolume,       //成交额
    DMCurrencySortTypePrice,        //价格
    DMCurrencySortTypeChange,       //涨幅
    DMCurrencySortTypeSymbol,       //symbol首字母排序
};
NSString *DMCurrencySortValue(DMCurrencySortType type);

typedef NS_ENUM(int, DMCurrencyPriceChange) {
    DMCurrencyPriceChangeUp = -1,
    DMCurrencyPriceChangeNone = 0,
    DMCurrencyPriceChangeDown = 1,
};

static NSNotificationName const DMCurrencyFavoriteDidChangeNotification = @"DMCurrencyFavoriteDidChangeNotif";

//@class DMTag;
@class DMCurrencyRefresh;
@interface DMCurrency : DMData

// for display
@property (nonatomic, strong) NSString *display_rank;
@property (nonatomic, strong) NSString *display_market;
@property (nonatomic, strong) NSAttributedString *display_name;
@property (nonatomic, strong) NSString *display_volume;
@property (nonatomic, strong) NSString *display_price;
@property (nonatomic, strong) NSString *display_convertprice;
@property (nonatomic, strong) NSString *display_change;
@property (nonatomic, strong) NSString *display_changepercent;

// 交易所
@property (nonatomic, strong) NSString *base;
@property (nonatomic, strong) NSString *quote;

// 板块、
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *alias;
@property (nonatomic, strong) NSString *symbol;

// 推荐币
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *exchangeName;

// 详情head要展示的数据
@property (strong, nonatomic) NSArray *headDatas;

@property (nonatomic, strong) NSString *contractDisplay;

@property (nonatomic, strong) NSNumber *priceQuote;
@property (nonatomic, strong) NSNumber *priceCny;
@property (nonatomic, strong) NSNumber *priceUsd;
//@property (nonatomic, strong) NSNumber *convertPriceCny;
//@property (nonatomic, strong) NSNumber *convertPriceUsd;
@property (nonatomic, strong) NSNumber *change;   // 涨跌幅
@property (nonatomic, strong) NSNumber *changePercent; //涨跌比
@property (nonatomic, strong) NSNumber *marketCapUsd;  // 市值
@property (nonatomic, strong) NSNumber *marketCapCny;  // 市值
@property (nonatomic, strong) NSNumber *amountUsd;     // 额
@property (nonatomic, strong) NSNumber *amountCny;     // 额
@property (nonatomic, strong) NSNumber *volume;     // 量
@property (nonatomic, assign) int rank;

@property (nonatomic, assign) BOOL isBIKA;
@property (nonatomic, strong) NSNumber *searchNumber; // 热搜标记

@property (nonatomic, assign) DMCurrencyPriceChange changeType;
//@property (assign, nonatomic) DMCurrencyType currencyType;

@property (nonatomic, strong) NSArray<NSString *> *tags;//币标签
@property (nonatomic, strong) NSNumber *dataId;          // 通用ID
@property (nonatomic, strong) NSNumber *currencyId;      // 币ID
@property (nonatomic, strong) NSNumber *tickerId;        // 交易对ID
@property (nonatomic, strong) NSNumber *futureId;     // 合约ID
@property (nonatomic, strong) NSNumber *exchangeId;      // 交易所ID
@property (nonatomic, strong) NSNumber *favorId;         // 自选ID
@property (nonatomic, strong) NSNumber *curTickerId;     // 自选推荐ID
@property (nonatomic, strong) NSNumber *baseId;
@property (nonatomic, strong) NSNumber *quoteId;
@property (nonatomic, strong) NSNumber *sourceType; // 1=币，2=交易对，3=合约，4=交易所
@property (nonatomic, strong) NSNumber *statType;
@property (nonatomic, strong) NSString *deliveryTime;
@property (nonatomic, assign) int typeDetail;  // 0不是详情 1币详情 2交易对详情 3合约详情 4交易所详情

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign, readonly) BOOL isCMC;
@property (nonatomic, assign) BOOL kLineEnabled;

@property (nonatomic, strong) NSString *comId;      // 交易对ID
@property (nonatomic, strong) NSString *marketId;   // 交易所ID

@property (nonatomic, strong) NSString *logo;
@property (nonatomic, strong) NSString *price_change_today;
@property (nonatomic, strong) NSString *legal_currency_price_usd;
@property (nonatomic, strong) NSArray *com_info;

//@property (nonatomic, assign) double percentChangeDisplay;//展示的价格变化
//@property (nonatomic, strong) NSString *percentChangeRange;//今天还是24h
//@property (nonatomic, assign) double volumeUsd24h;
//@property (nonatomic, assign) double volume24h;
//@property (nonatomic, assign) double high24h;
//@property (nonatomic, assign) double low24h;
//@property (nonatomic, assign) double volume24hFrom;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic) NSNumber *height;
@property (nonatomic) NSNumber *pageNum; // 0:mid -1:left
@property (strong, nonatomic) NSArray *trendDatas;

//@property (nonatomic, strong) NSString *marketName;
//@property (nonatomic, strong) NSString *marketAlias;
////@property (nonatomic, strong) NSString *market_alias;

@property (nonatomic, strong) NSString *pair;
@property (nonatomic, strong) NSString *hrPriceDisplay;
@property (nonatomic, assign) double dayRiseDisplay;
@property (nonatomic, strong) NSString *anchor;
@property (nonatomic, assign) BOOL news;
@property (nonatomic, strong) NSString *tvSymbol;//tradingview
@property (nonatomic, assign) BOOL ccKline;//k线
@property (strong, nonatomic) NSString *searchField;
@property (strong, nonatomic, readonly) NSString *hashKey;//币唯一标示
@property (assign, nonatomic) BOOL isFromHomeFavori;//是否是首页自选来的
@property (assign, nonatomic) DMCurrencySortType sortType;//当前排序
@property (strong, nonatomic) NSString *userCurrencyId;//收藏类使用
@property (assign, nonatomic) BOOL isPriceAbnormal;
@property (strong, nonatomic) NSString *priceAbnormalIcon;

// 供自选用
- (NSString *)self_alias;
- (NSAttributedString *)self_name;
- (NSString *)self_volume;
- (NSString *)self_price;
- (NSString *)self_convertPrice;

//价格变动及动画
@property (nonatomic, assign) DMCurrencyPriceChange lastChange;//价格变动
@property (nonatomic, assign, readonly) BOOL isAnimated;//是否展示了动画
- (void)animation:(NSTimeInterval)duration;//进行动画,持续时间
- (BOOL)matchKey:(NSString *)key;
@property (nonatomic, assign) BOOL hiddenAlisName;

- (BOOL)isMarketFrom;//是否是市场的币，不是全网的
- (void)updatePrice:(DMCurrencyRefresh *)obj;//根据DMCurrencyRefresh更新价格

+ (NSArray<DMCurrency *> *)getLocalDataWithMarketId:(NSString *)marketId;

//搜索内容
+ (NSURLSessionDataTask *)searchSymbol:(NSString *)symbol  page:(int)page groupId:(NSString *)groupId success:(void (^)(NSArray<DMCurrency *> *currencies, BOOL isMore))success failure:(void (^)(int code, NSString *error))failure;

//币资产里面的搜索
+ (NSURLSessionDataTask *)searchToeken:(NSString *)symbol success:(void (^)(NSArray<DMCurrency *> *currencies))success failure:(void (^)(int code, NSString *error))failure;

//交易所列表所有交易对
+ (NSURLSessionDataTask *)getCurreniesMarket:(NSString *)marketId groupId:(NSString *)userCurrencyGroupId success:(void (^)(NSArray<DMCurrency *> *currencies))success failure:(void (^)(int code, NSString *error))failure;
//备注里面包含的币
+ (NSURLSessionDataTask *)getMemorandumCurrencies:(void (^)(NSArray<DMCurrency *> *currencies))success failure:(void (^)(int code, NSString *error))failure;

+ (BOOL)isEqual:(NSArray<DMCurrency *> *)currencies to:(NSArray<DMCurrency *> *)newCurrencies;


// BKQ
// 币详情
+ (NSURLSessionDataTask *)getCurrenctDetailWith: (DMCurrency *)currency
                                               sucess:(void (^)(DMCurrency *currencyDetail))success failure:(void (^)(int code, NSString *error))failure;

// 合约详情
+ (NSURLSessionDataTask *)getConstractDetailWith: (DMCurrency *)currency
                                         sucess:(void (^)(DMCurrency *currencyDetail))success failure:(void (^)(int code, NSString *error))failure;

// bika详情
+ (NSURLSessionDataTask *)getBikaDetailWith: (DMCurrency *)currency
                                     sucess:(void (^)(DMCurrency *currencyDetail))success failure:(void (^)(int code, NSString *error))failure;

// 交易所详情的币列表
+ (NSURLSessionDataTask *)getCurrenciesWithExchangeId: (NSString *)exchangeId
                                              quoteId: (NSString *)quoteId
                                             baseName: (NSString *)baseName
                                                 sort: (NSString *)sort
                                               sucess:(void (^)(NSArray<DMCurrency *> *currencies, NSArray *quotes))success failure:(void (^)(int code, NSString *error))failure;
// 交易所详情的heyue
+ (NSURLSessionDataTask *)getContractsWithExchangeId: (NSString *)exchangeId
                                              sucess:(void (^)(NSArray *currencyDics))success failure:(void (^)(int code, NSString *error))failure;

// 板块详情的currency
+ (NSURLSessionDataTask *)getCurrenciesWithBlockId: (NSString *) blockId
                                              sort: (NSString *)sort
                                              page: (int)page
                                              sucess:(void (^)(NSArray *currencies))success failure:(void (^)(int code, NSString *error))failure;

// 市值 currency 列表
+ (NSURLSessionDataTask *)getCurrenciesWithPage: (int) pageNum
                                           Sort: (NSString *)sort
                                            sucess:(void (^)(NSArray *currencies))success failure:(void (^)(int code, NSString *error))failure;

// 币详情下面，获取币列表
+ (NSURLSessionDataTask *)getCurrenciesWithCurrency: (DMCurrency *) currency
                                               page: (int)page
                                         sucess:(void (^)(NSArray *currencyDics))success failure:(void (^)(int code, NSString *error))failure;

// 币详情， 观点
+ (NSURLSessionDataTask *)getNoticeWithCurrencyId:(NSString *)currencyId
                                                 Page:(int)page
                                              success:(void (^)(NSArray *noticeList))success
                                          failure:(void (^)(int code, NSString *error))failure;

@end

/*
 {"key":"338_Bitcoin_BTC_USDT","price":"10000.00000000","updated_at":"1512025632","percent_change_utc0":"3.22","price_ctc0":"9687.88","price_cny_ctc0":"64912.887724557","market_id":"338","symbol":"BTC","anchor":"USDT","price_display":"10,000","hr_price_display":"\u00a566,943.15","percent_change_display":"3.22","percent_change_range":"\u4eca\u65e5"}
 */
@interface DMCurrencyRefresh : DMData

@property (strong, nonatomic) NSString *hashKey;

@property (nonatomic, strong) NSNumber *dataId;          // 通用ID
@property (nonatomic, strong) NSNumber *currencyId;      // 币ID
@property (nonatomic, strong) NSNumber *tickerId;        // 交易对ID
@property (nonatomic, strong) NSNumber *constractId;     // 合约ID
@property (nonatomic, strong) NSNumber *exchangeId;      // 交易所ID
@property (nonatomic, strong) NSNumber *favorId;         // 自选ID
@property (nonatomic, strong) NSNumber *sourceType; // 1=币，2=交易对，3=合约，4=交易所

@property (nonatomic, strong) NSNumber *priceQuote;
@property (nonatomic, strong) NSNumber *priceCny;
@property (nonatomic, strong) NSNumber *priceUsd;
@property (nonatomic, strong) NSNumber *change;   // 涨跌幅
@property (nonatomic, strong) NSNumber *changePercent; //涨跌比
@property (nonatomic, strong) NSNumber *marketCapUsd;  // 市值
@property (nonatomic, strong) NSNumber *marketCapCny;  // 市值
@property (nonatomic, strong) NSNumber *amountUsd;     // 额
@property (nonatomic, strong) NSNumber *amountCny;     // 额
@property (nonatomic, strong) NSNumber *volume;     // 量

// 价格刷新
+ (NSURLSessionDataTask *)refresh:(NSArray<DMCurrency *> *)currencies success:(void (^)(NSArray *responseList))success failure:(void (^)(int code, NSString *error))failure;
// 价格刷新 [NSString stringWithFormat:@"%@_%@_%@_%@", self.marketId, self.name, self.symbol, self.anchor];
+ (NSURLSessionDataTask *)refreshPair:(NSString *)pairsKey success:(void (^)(NSArray<DMCurrencyRefresh *> *responseList))success failure:(void (^)(int code, NSString *error))failure;

@end
