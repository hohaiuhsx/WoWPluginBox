//
//  MBProgressHUD+Extend.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-19.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "MBProgressHUD+Extend.h"

MBProgressHUD *showProgressHud(NSView *view)
{
	return [MBProgressHUD showHUDAddedTo:view animated:YES];
}

void hideAllHuds(NSView *view)
{
	return [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

MBProgressHUD *showComletedHud(NSView *view, NSString *imageName, NSString *text)
{
	BOOL needShow = NO;

	MBProgressHUD *HUD = [MBProgressHUD HUDForView:view];
	if (!HUD || HUD.isFinished) {
		HUD = [[MBProgressHUD alloc] initWithView:view];
		[view addSubview:HUD];
		needShow = YES;
	}

	HUD.customView = [[NSImageView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 37.0f, 37.0f)];
	NSImage *img = [NSImage imageNamed:imageName];
	[(NSImageView *)HUD.customView setImage : img];
	HUD.mode		= MBProgressHUDModeCustomView;
	HUD.labelText	= text;
	HUD.labelFont	= [NSFont systemFontOfSize:14];

	if (needShow) {
		[HUD show:YES];
	}

	[HUD hide:YES afterDelay:2];
	return HUD;
}

@implementation MBProgressHUD (Extend)

@end

