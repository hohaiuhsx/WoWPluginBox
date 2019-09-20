//
//  MBProgressHUD+Extend.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-19.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "MBProgressHUD.h"

MBProgressHUD* showProgressHud(NSView *view);

void hideAllHuds(NSView *view);

MBProgressHUD* showComletedHud(NSView *view, NSString *imageName, NSString *text);

@interface MBProgressHUD (Extend)

@end
