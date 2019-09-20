//
//  NSColor+Oxygen.m
//  Pandora
//
//  Created by 黄 时欣 on 14-10-20.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "NSColor+Oxygen.h"

NSColor *NSColorFromRGB(unsigned long rgbValue)
{
	return [NSColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
					green		:((float)((rgbValue & 0xFF00) >> 8)) / 255.0
					blue		:((float)(rgbValue & 0xFF)) / 255.0
					alpha		:1.0];
}

NSColor *NSColorFromARGB(unsigned long argbValue)
{
	return [NSColor colorWithRed:((float)((argbValue & 0xFF0000) >> 16)) / 255.0
					green		:((float)((argbValue & 0xFF00) >> 8)) / 255.0
					blue		:((float)(argbValue & 0xFF)) / 255.0
					alpha		:((float)((argbValue & 0xFF000000) >> 24)) / 255.0];
}

NSColor *NSColorFromString(NSString *stringToConvert)
{
	NSString	*cString			= [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	NSColor		*DEFAULT_VOID_COLOR = [NSColor clearColor];

	if ([cString length] < 6) {
		return DEFAULT_VOID_COLOR;
	}

	if ([cString hasPrefix:@"0X"]) {
		cString = [cString substringFromIndex:2];
	}

	if ([cString hasPrefix:@"0x"]) {
		cString = [cString substringFromIndex:2];
	}

	if ([cString hasPrefix:@"#"]) {
		cString = [cString substringFromIndex:1];
	}

	NSString *alpha = @"FF";

	if ([cString length] == 8) {
		alpha	= [cString substringToIndex:2];
		cString = [cString substringFromIndex:2];
	}

	if ([cString length] != 6) {
		return DEFAULT_VOID_COLOR;
	}

	NSRange range;
	range.location	= 0;
	range.length	= 2;
	NSString *rString = [cString substringWithRange:range];

	range.location = 2;
	NSString *gString = [cString substringWithRange:range];

	range.location = 4;
	NSString *bString = [cString substringWithRange:range];

	unsigned int r, g, b, a;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	[[NSScanner scannerWithString:alpha] scanHexInt:&a];

	return [NSColor colorWithRed:((float)r / 255.0f)
					green		:((float)g / 255.0f)
					blue		:((float)b / 255.0f)
					alpha		:((float)a / 255.0f)];
}

@implementation NSColor (Oxygen)

@end

