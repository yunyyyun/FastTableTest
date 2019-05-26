//
//  CoinCellNode.h
//  AgileTable
//
//  Created by mengyun on 2019/5/23.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "CurrencyData.h"

@interface CoinCellNode : ASCellNode

- (instancetype)initWithCurrencyData:(CurrencyData *)data;

@end
