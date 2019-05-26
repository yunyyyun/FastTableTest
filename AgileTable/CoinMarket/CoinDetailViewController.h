//
//  CoinDetailViewController.h
//  AgileTable
//
//  Created by mengyun on 2019/5/26.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "BaseViewController.h"
#import "CurrencyData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoinDetailViewController : BaseViewController

+ (CoinDetailViewController *)viewControllerWithCurrency: (CurrencyData *)currency;

@end

NS_ASSUME_NONNULL_END
