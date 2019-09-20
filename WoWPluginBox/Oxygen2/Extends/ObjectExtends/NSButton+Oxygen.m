//
//  NSButton+Oxygen.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "NSButton+Oxygen.h"

@implementation NSButton (Oxygen)

- (void)setTextColor:(NSColor *)textColor
{
	NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
		initWithAttributedString:[self attributedTitle]];
	int		len		= [attrTitle length];
	NSRange range	= NSMakeRange(0, len);

	[attrTitle addAttribute:NSForegroundColorAttributeName
	value	:textColor
	range	:range];
	[attrTitle fixAttributesInRange:range];
	[self setAttributedTitle:attrTitle];

	attrTitle = [[NSMutableAttributedString alloc]
		initWithAttributedString:[self attributedAlternateTitle]];
	len		= [attrTitle length];
	range	= NSMakeRange(0, len);
	[attrTitle addAttribute:NSForegroundColorAttributeName
	value	:textColor
	range	:range];
	[attrTitle fixAttributesInRange:range];
	[self setAttributedAlternateTitle:attrTitle];
}

- (void)setOxygenDefaultStyle
{
    [self setOxygenStyleWithImage:[NSImage imageNamed:@"btn_primary_hover"] alternateImage:[NSImage imageNamed:@"btn_secondary_hover"]];
}

- (void)setOxygenStyleWithImage:(NSImage *)img alternateImage:(NSImage *)img2
{
	NSImage *image = [img stretchableImageWithSize:self.frame.size edgeInsets:NSEdgeInsetsMake(5, 5, 5, 5)];
    NSImage *image2 = [img2 stretchableImageWithSize:self.frame.size edgeInsets:NSEdgeInsetsMake(5, 5, 5, 5)];

	[self setImage:image];
    [self setAlternateImage:image2];
	[self.cell setHighlightsBy:NSContentsCellMask];
	[self setTextColor:[NSColor whiteColor]];
}

@end

