//
//  NSButton+Oxygen.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButton (Oxygen)

- (void)setTextColor:(NSColor *)textColor;

- (void)setOxygenDefaultStyle;
- (void)setOxygenStyleWithImage:(NSImage *)img alternateImage:(NSImage *)img2;

@end
