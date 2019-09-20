//
//  PluginCell.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-3.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MoGuPluginList.h"
@class PluginCell;

@protocol PluginCellDelegate <NSObject>
- (void)onRemoveItem:(MoGuPluginList_PItem *)item sender:(PluginCell *)cell;
- (void)onInstallItem:(MoGuPluginList_PItem *)item sender:(PluginCell *)cell;

@end

@interface PluginCell : NSTableCellView
@property (assign) IBOutlet NSButton	*button;
@property (weak) IBOutlet id			delegate;

- (void)setObjectValue:(MoGuPluginList_PItem *)objectValue;
@end

