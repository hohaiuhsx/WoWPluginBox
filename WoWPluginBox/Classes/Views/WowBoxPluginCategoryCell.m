//
//  WowBoxPluginCategoryCell.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-16.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "WowBoxPluginCategoryCell.h"
#import "PluginList.h"

@interface WowBoxPluginCategoryCell ()
@property (weak) IBOutlet NSImageView	*icon;
@property (weak) IBOutlet NSTextField	*name;
@end

@implementation WowBoxPluginCategoryCell

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

	// Drawing code here.
}

- (void)setObjectValue:(PluginList_PluginsItem *)objectValue
{
    self.name.stringValue = strFormat(@"%@(%ld)",objectValue.name,objectValue.pluginitems.count);
    self.icon.image = [NSImage imageNamed:objectValue.icon];
}

@end

