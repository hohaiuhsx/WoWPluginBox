//
//  NSColor+Oxygen.h
//  Pandora
//
//  Created by 黄 时欣 on 14-10-20.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSColor *NSColorFromRGB(unsigned long rgbValue);

NSColor *NSColorFromARGB(unsigned long argbValue);

NSColor *NSColorFromString(NSString *stringToConvert);

@interface NSColor (Oxygen)

@end

