//
//  Macro.h
//  cpsdna
//
//  Created by 黄 时欣 on 13-11-7.
//  Copyright 黄 时欣 2013年. All rights reserved.
//

// Common headers import
#import "SysConfig.h"
#import "ConstKeys.h"
#import "AppDelegate.h"
#import "Oxygen2-Prefix.pch"
#import <NSData+MD5Digest.h>
#import "MBProgressHUD+Extend.h"

// #if DEBUG
// static const DDLogLevel ddLogLevel = LOG_LEVEL_VERBOSE;
// #else
// static const DDLogLevel ddLogLevel = LOG_LEVEL_INFO;
// #endif

// #define DDLogInfo NSLog
// #define DDLogError NSLog
// #define DDLogWarn NSLog

// colors
#define color_blue			UIColorFromRGB(0x0085D0)
#define color_grass			UIColorFromRGB(0x8DC73F)
#define color_rose			UIColorFromRGB(0xEC198C)
#define color_orange		UIColorFromRGB(0XEF6526)
#define color_bg			UIColorFromRGB(0XEEEEEE)

// font
#define font_small			[UIFont systemFontOfSize:FONT_SIZE - 4]
#define font_normal			[UIFont systemFontOfSize:FONT_SIZE]
#define font_middle			[UIFont systemFontOfSize:FONT_SIZE + 2]
#define font_large			[UIFont systemFontOfSize:FONT_SIZE + 4]
#define font_xlarge			[UIFont systemFontOfSize:FONT_SIZE + 8]

#define bold_font_small		[UIFont boldSystemFontOfSize:FONT_SIZE - 4]
#define bold_font_normal	[UIFont boldSystemFontOfSize:FONT_SIZE]
#define bold_font_middle	[UIFont boldSystemFontOfSize:FONT_SIZE + 2]
#define bold_font_large		[UIFont boldSystemFontOfSize:FONT_SIZE + 4]
#define bold_font_xlarge	[UIFont boldSystemFontOfSize:FONT_SIZE + 8]

