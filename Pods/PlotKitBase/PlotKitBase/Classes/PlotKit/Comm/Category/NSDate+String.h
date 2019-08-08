//
//  NSDate+String.h
//  PlotKitTest
//
//  Created by DFG on 2019/3/27.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (String)

- (NSString *)toTimeStringWithFormat:(NSString *)format;

@end

NS_ASSUME_NONNULL_END
