//
//  EuiOtherPluginCell.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-18.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EuiXml.h"

@class EuiOtherPluginCell;

@protocol EuiCellDelegate <NSObject>
- (void)onRemoveItem:(EuiXml_AItem *)item sender:(EuiOtherPluginCell *)cell;
- (void)onInstallItem:(EuiXml_AItem *)item sender:(EuiOtherPluginCell *)cell;

@end
@interface EuiOtherPluginCell : NSTableCellView

@property (weak) IBOutlet NSButton		*button;

@property (weak) IBOutlet id<EuiCellDelegate> delegate;

@end
