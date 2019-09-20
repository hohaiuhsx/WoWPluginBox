//
//  LocalViewController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "LocalViewController.h"
#import "OFFileManager.h"

@interface LocalViewController () <NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSButton		*btnSelectAll;
@property (weak) IBOutlet NSTableView	*pluginTable;
@property (weak) IBOutlet NSButton		*btnBackup;
@property (weak) IBOutlet NSButton		*btnDelete;
@property (weak) IBOutlet NSButton		*btnDeleteBackups;

@property (nonatomic, strong) NSMutableArray *localPlugins;

@end

@implementation LocalPlugin

@end

@implementation LocalViewController

- (void)awakeFromNib
{
	[self.btnDelete setOxygenDefaultStyle];
	[self.btnBackup setOxygenDefaultStyle];
    [self.btnDeleteBackups setOxygenDefaultStyle];
	[self.btnSelectAll setTextColor:[NSColor whiteColor]];
}

- (void)loadView
{
	[super loadView];

	[self scanLocalPlugins];
}

- (void)onSelected
{
	[super onSelected];

	[self scanLocalPlugins];
}

- (void)scanLocalPlugins
{
	NSArray			*array	= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[AppDelegate addonsPath] error:nil];
	NSMutableArray	*temp	= [NSMutableArray array];

	for (NSString *path in array) {
		if ([path startWith:@"."]) {
			continue;
		}

		LocalPlugin *plugin = [[LocalPlugin alloc]init];
		plugin.name			= path;
		plugin.checked		= YES;
		plugin.controller	= self;
		[temp addObject:plugin];
	}

	self.localPlugins = temp;

	if (self.localPlugins.count <= 0) {
		showComletedHud(self.view, @"failed", @"未发现插件");
	}

	[self reload];
}

- (void)reload
{
	BOOL all = YES;

	for (LocalPlugin *p in self.localPlugins) {
		if (!p.checked) {
			all = NO;
			break;
		}
	}

	self.btnSelectAll.state = all ? NSOnState : NSOffState;
	[self.pluginTable reloadData];
	[self.btnSelectAll setTitle:strFormat(@"全选（%ld个插件)", self.localPlugins.count)];
	[self.btnSelectAll setTextColor:[NSColor whiteColor]];
}

- (BOOL)hasOneOrMoreChecked
{
	for (LocalPlugin *p in self.localPlugins) {
		if (p.checked) {
			return YES;
		}
	}

	return NO;
}

- (IBAction)onBtnAction:(id)sender
{
	if (sender == self.btnBackup) {
		if (![self hasOneOrMoreChecked]) {
			showComletedHud(self.view, @"failed", @"未选择插件");
			return;
		}

		weakObj(self);
		__weak MBProgressHUD *hud = showProgressHud(bself.view);
		hud.mode = MBProgressHUDModeDeterminate;
		[self performBlockInBackground:^{
			NSString *dir = [[AppDelegate addOnsBackupPath] stringByAppendingPathComponent:@"AddOns_"];
			dir = [dir stringByAppendingString:date2StringFormatYMDHMS([NSDate date])];
			[OFFileManager createDirectoriesForPath:dir];

			NSUInteger i = 0;

			for (LocalPlugin * item in bself.localPlugins) {
				if (item.checked) {
					NSString *to = [dir stringByAppendingPathComponent:item.name];
					[OFFileManager copyItemAtPath:[[AppDelegate addonsPath] stringByAppendingPathComponent:item.name] toPath:to];
				}

				hud.progress = (double)i / bself.localPlugins.count;
				i++;
			}

			hud.detailsLabelText = dir.lastPathComponent;
			[bself performBlockOnMainThread:^{
				showComletedHud(bself.view, @"success", @"备份完成");
			}];
		}];
	} else if (sender == self.btnDelete) {
		if (![self hasOneOrMoreChecked]) {
			showComletedHud(self.view, @"failed", @"未选择插件");
			return;
		}

		weakObj(self);
		__weak MBProgressHUD *hud = showProgressHud(bself.view);
		hud.mode = MBProgressHUDModeDeterminate;
		[self performBlockInBackground:^{
			NSUInteger i = 0;

			for (LocalPlugin * item in bself.localPlugins) {
				if (item.checked) {
					[OFFileManager removeItemAtPath:[[AppDelegate addonsPath] stringByAppendingPathComponent:item.name]];
				}

				hud.progress = (double)i / bself.localPlugins.count;
				i++;
			}

			[bself scanLocalPlugins];
			[bself performBlockOnMainThread:^{
				showComletedHud(bself.view, @"success", @"删除完成");
			}];
		}];
	} else if (sender == self.btnSelectAll) {
		BOOL all = self.btnSelectAll.state == NSOnState;

		for (LocalPlugin *p in self.localPlugins) {
			p.checked = all;
		}

		[self reload];
	} else if (sender == self.btnDeleteBackups) {
		__weak NSArray *dirs = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[AppDelegate addOnsBackupPath] error:nil];

		if (dirs.count <= 0) {
			showComletedHud(self.view, @"failed", @"没有备份");
			return;
		}

		weakObj(self);
		__weak MBProgressHUD *hud = showProgressHud(bself.view);
		hud.mode = MBProgressHUDModeDeterminate;
		[self performBlockInBackground:^{
			NSUInteger i = 0;

			for (NSString * item in dirs) {
				[OFFileManager removeItemAtPath:[[AppDelegate addOnsBackupPath] stringByAppendingPathComponent:item]];

				hud.progress = (double)i / dirs.count;
				i++;
			}

			[bself performBlockOnMainThread:^{
				showComletedHud(bself.view, @"success", @"删除完成");
			}];
		}];
	}
}

- (void)onItemCheckChange:(LocalPlugin *)item
{
	if (item.checked) {
		[self reload];
	} else {
		self.btnSelectAll.state = NSOffState;
	}
}

- (void)onUninstallItem:(LocalPlugin *)item
{
	showProgressHud(self.view);
	[OFFileManager removeItemAtPath:[[AppDelegate addonsPath] stringByAppendingPathComponent:item.name]];
	[self.localPlugins removeObject:item];
	[self.pluginTable reloadData];
	showComletedHud(self.view, @"success", @"卸载成功");
	[self reload];
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.localPlugins.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return self.localPlugins[row];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 40;
}

@end

