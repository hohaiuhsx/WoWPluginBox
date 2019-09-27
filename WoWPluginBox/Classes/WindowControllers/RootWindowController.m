//
//  RootWindowController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-14.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "RootWindowController.h"
#import "WowBoxViewController.h"
#import "BigfootViewController.h"
#import "EuiViewController.h"
#import "MoguViewController.h"
#import "LocalViewController.h"

@interface RootWindowController ()
{
	NSUInteger currentSelected;
}
@property (weak) IBOutlet NSView	*container;
@property (weak) IBOutlet NSMatrix	*radioGroup;

@property (nonatomic, readonly) WowBoxViewController	*wowBoxController;
@property (nonatomic, readonly) BigfootViewController	*bigfootController;
@property (nonatomic, readonly) EuiViewController		*euiController;
@property (nonatomic, readonly) MoguViewController		*moguController;
@property (nonatomic, readonly) LocalViewController		*localController;
@end

@implementation RootWindowController
@synthesize wowBoxController	= _wowBoxController;
@synthesize bigfootController	= _bigfootController;
@synthesize euiController		= _euiController;
@synthesize moguController		= _moguController;
@synthesize localController		= _localController;

- (void)windowDidLoad
{
	[super windowDidLoad];
	currentSelected = NSNotFound;

    //默认EUI
    NSInteger index = 0;//[[NSUserDefaults standardUserDefaults] integerForKey:kU_TAB_INDEX];
	[self.radioGroup selectCellAtRow:index column:0];
	[self onRadioChanged:self.radioGroup];
}

- (IBAction)onRadioChanged:(id)sender
{
	if (currentSelected == self.radioGroup.selectedRow) {
		return;
	}

	currentSelected = self.radioGroup.selectedRow;

	for (NSView *view in self.container.subviews) {
		[view removeFromSuperview];
	}

	BaseViewController *controller = nil;
	switch (currentSelected) {
//		case 0:
//			controller = self.wowBoxController;
//			break;
//
//		case 1:
//			controller = self.bigfootController;
//			break;

		case 0:
			controller = self.euiController;
			break;

//		case 3:
//			controller = self.moguController;
//			break;

		case 1:
			controller = self.localController;
			break;

		default:
			break;
	}

	if (controller) {
		[self.container addSubview:controller.view];
		[controller onSelected];
	}

	[[NSUserDefaults standardUserDefaults]setInteger:currentSelected forKey:kU_TAB_INDEX];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (WowBoxViewController *)wowBoxController
{
	if (!_wowBoxController) {
		_wowBoxController = [[WowBoxViewController alloc]initWithNibName:@"WowBoxViewController" bundle:nil];
	}

	return _wowBoxController;
}

- (BigfootViewController *)bigfootController
{
	if (!_bigfootController) {
		_bigfootController = [[BigfootViewController alloc]initWithNibName:@"BigfootViewController" bundle:nil];
	}

	return _bigfootController;
}

- (EuiViewController *)euiController
{
	if (!_euiController) {
		_euiController = [[EuiViewController alloc]initWithNibName:@"EuiViewController" bundle:nil];
	}

	return _euiController;
}

- (MoguViewController *)moguController
{
	if (!_moguController) {
		_moguController = [[MoguViewController alloc]initWithNibName:@"MoguViewController" bundle:nil];
	}

	return _moguController;
}

- (LocalViewController *)localController
{
	if (!_localController) {
		_localController = [[LocalViewController alloc]initWithNibName:@"LocalViewController" bundle:nil];
	}

	return _localController;
}

@end

