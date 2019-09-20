//
//  EuiSettingController.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-18.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EuiXml.h"

@interface EuiSettingController : NSWindowController

+ (EuiSettingController *)showWithEuixml:(EuiXml *)xml sender:(id)sender;

@end
