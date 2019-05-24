//
//  BaseSelectCell.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "BaseSelectCell.h"

@implementation BaseSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsAlphaSelect:(BOOL)isAlphaSelect
{
    _isAlphaSelect = isAlphaSelect;
    if (isAlphaSelect) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.isAlphaSelect) self.alpha = highlighted ? 0.4 : 1;
}

@end
