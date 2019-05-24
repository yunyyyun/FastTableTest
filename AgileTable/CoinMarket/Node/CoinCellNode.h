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

//@property (strong, nonatomic) UILabel *symbolLabel;
//@property (strong, nonatomic) UILabel *nameLabel;
//@property (strong, nonatomic) UILabel *rankLabel;
//@property (strong, nonatomic) UILabel *marketCapLabel;
//@property (strong, nonatomic) UILabel *priceLabel;
//@property (strong, nonatomic) UILabel *convertPriceLabel;
//@property (strong, nonatomic) UIButton *changePercentButton;



@end
