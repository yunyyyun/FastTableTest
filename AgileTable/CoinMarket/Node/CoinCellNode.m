//
//  CoinCellNode.m
//  AgileTable
//
//  Created by mengyun on 2019/5/23.
//  Copyright © 2019 mengyun. All rights reserved.
//
#import "CoinCellNode.h"

@implementation CoinCellNode{
    ASNetworkImageNode *_logoImageNode;
    ASTextNode *_rankNode;
    ASTextNode *_nameNode;
    ASTextNode *_symbolNode;
    ASTextNode *_marketCapNode;
    
    ASTextNode *_priceNode;
    ASTextNode *_convertPriceNode;
    ASButtonNode *_changePercentNode;
    
    ASDisplayNode *_lineNode;
    CurrencyData *_data;
}

- (instancetype)initWithCurrencyData:(CurrencyData *)data{
    self = [super init];
    
    if (self){
        _data = data;
        
        _logoImageNode = [[ASNetworkImageNode alloc] init];
        _logoImageNode.URL = [NSURL URLWithString: data.logo];
        [self addSubnode: _logoImageNode];
        _logoImageNode.placeholderFadeDuration = 3; // 防止闪
        // _logoImageNode.placeholderColor = [UIColor clearColor];
        
        _rankNode = [[ASTextNode alloc] init];
        _rankNode.attributedText = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%@", data.rank]];
        [self addSubnode: _rankNode];
        
        _symbolNode = [[ASTextNode alloc] init];
        _symbolNode.attributedText = [[NSAttributedString alloc]initWithString: data.symbol attributes:@{NSForegroundColorAttributeName: [UIColor blackColor],NSFontAttributeName: [UIFont systemFontOfSize:17 weight: UIFontWeightSemibold]}];
        [self addSubnode: _symbolNode];
        
        _nameNode = [[ASTextNode alloc] init];
        _nameNode.attributedText = [[NSAttributedString alloc]initWithString: data.alias attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor],NSFontAttributeName: [UIFont systemFontOfSize:12 weight: UIFontWeightRegular]}];
        [self addSubnode: _nameNode];
        _nameNode.truncationMode = NSLineBreakByTruncatingTail;
        _nameNode.maximumNumberOfLines = 1;
        // _nameNode.truncationAttributedText = [[NSAttributedString alloc]initWithString:@"¶¶¶"];
        
        _marketCapNode = [[ASTextNode alloc] init];
        _marketCapNode.attributedText = [[NSAttributedString alloc]initWithString: [NSString stringWithFormat: @"市值 ¥%@", data.marketCapCnyDisplay] attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor],NSFontAttributeName: [UIFont systemFontOfSize:12 weight: UIFontWeightRegular]}];
        [self addSubnode: _marketCapNode];
        
        _priceNode = [[ASTextNode alloc] init];
        _priceNode.attributedText = [[NSAttributedString alloc]initWithString: [NSString stringWithFormat: @"$%@", data.priceUsdDisplay] attributes:@{NSForegroundColorAttributeName: [UIColor blackColor],NSFontAttributeName: [UIFont systemFontOfSize:17 weight: UIFontWeightSemibold]}];
        [self addSubnode: _priceNode];
        
        _convertPriceNode = [[ASTextNode alloc] init];
        _convertPriceNode.attributedText = [[NSAttributedString alloc]initWithString: [NSString stringWithFormat: @"≈¥%@", data.priceCnyDisplay] attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor],NSFontAttributeName: [UIFont systemFontOfSize:12 weight: UIFontWeightRegular]}];
        [self addSubnode: _convertPriceNode];
        
        _changePercentNode = [[ASButtonNode alloc] init];
        double percentChange24h = [data.percentChange24h doubleValue];
        NSString *percentChange24hStr = [NSString stringWithFormat: @"%.2f%%", percentChange24h*100];
        if (![percentChange24hStr containsString: @"-"]){
            percentChange24hStr = [NSString stringWithFormat: @"+%@", percentChange24hStr];
        }

        [_changePercentNode setTitle: percentChange24hStr withFont: [UIFont systemFontOfSize:16 weight: UIFontWeightSemibold] withColor: [UIColor whiteColor] forState: UIControlStateNormal];
        if (percentChange24h>=0){
            _changePercentNode.backgroundColor = [UIColor colorWithRed: 235/255.0 green: 47/255.0 blue: 47/255.0 alpha: 0.9];
        }
        else{
            _changePercentNode.backgroundColor = [UIColor colorWithRed: 0/255.0 green: 167/255.0 blue: 50/255.0 alpha: 0.9];
        }
        _changePercentNode.cornerRadius = 2.0;
        [self addSubnode: _changePercentNode];
     
        _lineNode = [[ASDisplayNode alloc] init];
        _lineNode.backgroundColor = [UIColor colorWithWhite:102/155.0 alpha: 0.3];
        [self addSubnode: _lineNode];
    }
    
    return self;
}

// 布局
- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    _logoImageNode.style.preferredSize = CGSizeMake(30, 30);
    ASStackLayoutSpec *logoRankSpec =
    [ASStackLayoutSpec
     stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical // 竖直排列
     spacing:4.0
     justifyContent:ASStackLayoutJustifyContentCenter // 排列方向上居中
     alignItems:ASStackLayoutAlignItemsCenter   // 水平方向居中对齐
     children: @[_logoImageNode, _rankNode]];

    // BTC bitcoin
    ASStackLayoutSpec *nameSymbolSpec =
    [ASStackLayoutSpec
     stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
     spacing: 4.0
     justifyContent:ASStackLayoutJustifyContentStart
     alignItems:ASStackLayoutAlignItemsEnd
     children:@[_symbolNode, _nameNode]];
    // _nameNode.style.preferredSize = CGSizeMake(160, 15);
    _nameNode.style.maxWidth = ASDimensionMakeWithPoints(122);
    
    ASStackLayoutSpec *nameSymbolMarketSpec =
    [ASStackLayoutSpec
     stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
     spacing:8
     justifyContent:ASStackLayoutJustifyContentStart
     alignItems:ASStackLayoutAlignItemsStretch
     children: @[nameSymbolSpec, _marketCapNode]];

    ASLayoutSpec *nameSymbolMarketSpec2 = [ASInsetLayoutSpec
                                               insetLayoutSpecWithInsets:UIEdgeInsetsMake(5, 4, 4, 4)
                                                child: nameSymbolMarketSpec];
    ASStackLayoutSpec *pricesSpec =
    [ASStackLayoutSpec
     stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
     spacing:8
     justifyContent:ASStackLayoutJustifyContentEnd
     alignItems:ASStackLayoutAlignItemsBaselineLast
     children: @[_priceNode, _convertPriceNode]];
    
    _changePercentNode.style.preferredSize = CGSizeMake(80, 30);
    ASStackLayoutSpec *pricesPercentSpec =
    [ASStackLayoutSpec
     stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
     spacing: 8.0
     justifyContent:ASStackLayoutJustifyContentEnd  // 排列方向上往右挤压
     alignItems:ASStackLayoutAlignItemsCenter
     children:@[pricesSpec, _changePercentNode]];

    ASLayoutSpec *pricesPercentSpec2 = [ASInsetLayoutSpec
                                           insetLayoutSpecWithInsets:UIEdgeInsetsMake(4, 4, 4, 4)
                                           child: pricesPercentSpec];

    ASStackLayoutSpec *mainStackContent =
    [ASStackLayoutSpec
     stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
     spacing:4.0
     justifyContent:ASStackLayoutJustifyContentStart
     alignItems:ASStackLayoutAlignItemsCenter
     children: @[logoRankSpec, nameSymbolMarketSpec2]];

    ASStackLayoutSpec *allSpec =
    [ASStackLayoutSpec
     stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
     spacing:4.0
     justifyContent:ASStackLayoutJustifyContentSpaceBetween
     alignItems:ASStackLayoutAlignItemsCenter
     children: @[mainStackContent, pricesPercentSpec2]];
    mainStackContent.style.flexShrink = 0.4;
    pricesPercentSpec2.style.flexShrink = 0.2;

    _lineNode.style.preferredSize = CGSizeMake(500, 0.5);
    ASStackLayoutSpec *allSpecWithLine =
    [ASStackLayoutSpec
     stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
     spacing:3.0
     justifyContent:ASStackLayoutJustifyContentSpaceBetween
     alignItems:ASStackLayoutAlignItemsStretch
     children: @[allSpec, _lineNode]];

    // allSpecWithLine.style.preferredSize = CGSizeMake(355, 66);
    return [ASInsetLayoutSpec
            insetLayoutSpecWithInsets:UIEdgeInsetsMake(10, 16, 0, 12)
            child: allSpecWithLine];
}

//- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize{
//    return CGSizeMake(355, 166);
//}


@end
