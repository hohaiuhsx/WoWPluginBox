//
//  WowBoxPluginItemCell.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-16.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "WowBoxPluginItemCell.h"
#import "PluginList.h"
#import "BigFootFileList.h"

@interface WowBoxPluginItemCell ()
@property (weak) IBOutlet NSTextField	*name;
@property (weak) IBOutlet NSTextField	*author;
@property (weak) IBOutlet NSTextField	*descript;
@property (weak) IBOutlet NSButton		*ignore;

@end

@implementation WowBoxPluginItemCell

- (id)initWithDefaultNib
{
	if (self = [super init]) {
		[NSBundle loadNibNamed:@"WowBoxPluginItemCell" owner:self];
	}

	return self;
}

- (void)setObjectValue:(id)objectValue
{
	[super setObjectValue:objectValue];

	if (objectValue) {
		if ([objectValue isKindOfClass:[PluginList_PluginitemsItem class]]) {
			PluginList_PluginitemsItem *item = (PluginList_PluginitemsItem *)objectValue;
			self.name.stringValue				= item.name ? : @"";
			self.author.stringValue				= item.author ? : @"";
			self.descript.attributedStringValue = item.attributedDescript ? :[[NSMutableAttributedString alloc] initWithString:@""];
			self.ignore.state = [APP_DELEGATE isPluginIgnore:item.foldername] ? NSOffState : NSOnState;
		} else if ([objectValue isKindOfClass:[BigFootFileList_AddOnItem class]]) {
			BigFootFileList_AddOnItem *item = (BigFootFileList_AddOnItem *)objectValue;
			self.name.stringValue	= item.Title_zhCN ? : @"";
			self.author.stringValue = item.Author ? : @"";
			self.descript.stringValue	= item.des;
			self.ignore.state			= [APP_DELEGATE isPluginIgnore:item.name] ? NSOffState : NSOnState;
		}
	}
}

- (IBAction)onIgnoreCheck:(id)sender
{
	if (sender == self.ignore) {
		NSString *dir = nil;

		if ([self.objectValue isKindOfClass:[PluginList_PluginitemsItem class]]) {
			dir = ((PluginList_PluginitemsItem *)self.objectValue).foldername;
		} else if ([self.objectValue isKindOfClass:[BigFootFileList_AddOnItem class]]) {
			dir = ((PluginList_PluginitemsItem *)self.objectValue).name;
		}

		if (self.ignore.state == NSOnState) {
			[APP_DELEGATE removeIgnorePlugin:dir];
		} else if (self.ignore.state == NSOffState) {
			[APP_DELEGATE addIgnorePlugin:dir];
		}
	}
}

@end

