//
//  CoinCell.h
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "CurrencyData.h"
#define cellDefaultHeight 266

NS_ASSUME_NONNULL_BEGIN

@interface CoinCell : BaseTableViewCell

@property (strong, nonatomic) CurrencyData *currency;

@end

NS_ASSUME_NONNULL_END
