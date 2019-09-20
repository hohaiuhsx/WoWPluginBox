//
//  PluginCell.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-3.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "PluginCell.h"

@interface PluginCell ()
@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *ver;
@end
@implementation PluginCell
- (void)awakeFromNib
{
    [self.button setOxygenDefaultStyle];
}

- (void)setObjectValue:(MoGuPluginList_PItem *)objectValue
{
	[super setObjectValue:objectValue];
    if(objectValue){
        self.name.stringValue = objectValue.Name;
        self.ver.stringValue = objectValue.Ver;
        self.button.state			= objectValue.installed ?  NSOnState : NSOffState;
    }
}

- (IBAction)onButtonAction:(NSButton *)sender
{
	NSLogTrace;

	if (sender.state == NSOnState) {
		// 添加

		if (self.delegate && [self.delegate respondsToSelector:@selector(onInstallItem:sender:)]) {
			[self.delegate onInstallItem:self.objectValue sender:self];
		}
	} else if (sender.state == NSOffState) {
		// 移除
		if (self.delegate && [self.delegate respondsToSelector:@selector(onRemoveItem:sender:)]) {
			[self.delegate onRemoveItem:self.objectValue sender:self];
		}
	}
}

@end

