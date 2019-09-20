//
//  EuiOtherPluginCell.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-18.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "EuiOtherPluginCell.h"
#import "EuiXml.h"

@interface EuiOtherPluginCell ()
@property (weak) IBOutlet NSTextField	*name;
@property (weak) IBOutlet NSTextField	*ver;
@property (weak) IBOutlet NSTextField	*descript;
@end

@implementation EuiOtherPluginCell

- (void)awakeFromNib
{
	[self.button setOxygenDefaultStyle];
}

- (void)setObjectValue:(EuiXml_AItem *)objectValue
{
	[super setObjectValue:objectValue];

	if (objectValue) {
		self.name.stringValue		= objectValue.name;
		self.ver.stringValue		= objectValue.ver;
		self.descript.stringValue	= objectValue.desc;

        self.button.state = objectValue.installed?NSOnState:NSOffState;
        [self.button setEnabled:objectValue.checked];
	}
}

- (IBAction)onBtnAction:(NSButton *)sender{
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

