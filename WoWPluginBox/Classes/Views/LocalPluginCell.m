//
//  LocalPluginCell.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-19.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "LocalPluginCell.h"
#import "LocalViewController.h"

@interface LocalPluginCell()

@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSButton *button;
@property (weak) IBOutlet NSButton *check;
@end
@implementation LocalPluginCell

- (void)awakeFromNib{
    [self.button setOxygenDefaultStyle];
}

- (void)setObjectValue:(LocalPlugin *)objectValue
{
    [super setObjectValue:objectValue];
    if(objectValue){
        self.name.stringValue = objectValue.name;
        self.check.state = objectValue.checked?NSOnState:NSOffState;
    }
}

- (IBAction)onBtnAction:(id)sender
{
    LocalPlugin *item = self.objectValue;
    if(sender == self.button){
        [item.controller onUninstallItem:item];
    }else{
        item.checked = self.check.state == NSOnState;
        [item.controller onItemCheckChange:item];
    }
}

@end
