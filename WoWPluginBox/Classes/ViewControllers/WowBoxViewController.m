//
//  WowBoxViewController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "WowBoxViewController.h"
#import "FileInfoCollecter.h"
#import "AddonsUpdater.h"
#import "PluginList.h"
#import "PluginCrcList.h"
#import "WowBoxPluginCategoryCell.h"
#import "FileUpdater.h"

@interface WowBoxViewController () <NSTableViewDelegate, NSTableViewDataSource>
{
	__block BOOL requesting;
}
@property (weak) IBOutlet NSButton				*btnUpdate;
@property (weak) IBOutlet NSProgressIndicator	*progress;
@property (weak) IBOutlet NSTableView			*pluginCategory;
@property (weak) IBOutlet NSTableView			*pluginTable;
@property (weak) IBOutlet NSButton				*selectAll;

@property (nonatomic, copy) NSString *tip;

//
@property (nonatomic, strong) AddonsUpdater				*addonsUpdater;
@property (nonatomic, strong) PluginList				*list, *list_tw;
@property (nonatomic, strong) PluginCrcList				*crc, *crc_tw;
@property (nonatomic, strong) PluginList_PluginsItem	*currentCategory;

@property (nonatomic, strong) FileUpdater *updater;
@end

@implementation WowBoxViewController

- (void)loadView
{
	[super loadView];
	addSelfAsNotificationObserver(KN_IGNORE_CHANGED, @selector(onIgnoreChanged:));
	addSelfAsNotificationObserver(KN_WOWPATH_CHANGED, @selector(onWowPathChanged:));
}

- (void)dealloc
{
	removeSelfNofificationObservers;
}

- (void)onIgnoreChanged:(NSNotification *)notification
{
	self.selectAll.state = [APP_DELEGATE isOneOrMoreIgnore:self.list.allPluginDirs] ? NSOffState : NSOnState;
    self.updater = nil;
}

- (void)onWowPathChanged:(NSNotification *)notification
{
	[self onSelected];
}

- (NSString *)workPath
{
	return [[AppDelegate cachePath] stringByAppendingPathComponent:@"Pandora"];
}

- (void)onSelected
{
	if (!self.addonsUpdater && !requesting) {
		requesting = YES;
		[self requestAddonsUpdater];
	}
}

- (void)awakeFromNib
{
	[self.btnUpdate setOxygenDefaultStyle];
	NSMutableAttributedString *title = [[NSMutableAttributedString alloc]initWithString:@"全部更新（未选中的将不会更新）"];

	[title addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, title.length)];
	[title addAttribute:NSForegroundColorAttributeName value:[NSColor greenColor] range:[title.string rangeOfString:@"未选中的将不会更新"]];
	[self.selectAll setAttributedTitle:title];
}

- (IBAction)onSelectAllAction:(id)sender
{
	if (self.selectAll.state == NSOffState) {
		[APP_DELEGATE addIgnorePlugins:self.list.allPluginDirs];
		[self.pluginTable reloadData];
        self.updater = nil;
	} else {
		[APP_DELEGATE removeIgnorePlugins:self.list.allPluginDirs];
		[self.pluginTable reloadData];
        self.updater = nil;
	}
}

- (IBAction)onBtnAction:(id)sender
{
	if (sender == _btnUpdate) {
		if (_btnUpdate.state == NSOnState) {
			[self doUpdate];
		} else {
			[self.updater cancel];
		}
	}
}

#pragma mark - 检测文件差异
- (void)chekFileDiffence:(BOOL)autoUpdate
{
	[self.btnUpdate setEnabled:NO];
	[AppDelegate checkAndMakeAddOnsDir];
	FileInfoCollecter *collecter = [[FileInfoCollecter alloc]initWithDirectory:[AppDelegate addonsPath]];
	weakObj(self);
	[collecter setCollectBlock:^(FileInfoCollecter *collecter, FileAttributes *attr, NSUInteger curIndex) {
		NSString *tip = [NSString stringWithFormat:@"正在扫描本地插件:%@", [attr.path lastPathComponent]];
		double progress = (float)curIndex / collecter.itemCount * 100.f;
		[bself setProgressValue:progress tip:tip];
	}];
	[collecter setCompleteBlock:^(FileInfoCollecter *collecter) {
		APP_DELEGATE.localPluginFileAttributes = collecter.collections;
		[bself showCompleteTip:@"扫描本地插件完成！"];

		// check
		bself.updater = [[FileUpdater alloc]init];
		NSInteger count = 0;
		NSInteger ignore = 0;
		NSURL *baseUrl = [NSURL URLWithString:[kBASE_URL stringByAppendingString:@"AddOns"]];

		for (PluginCrcList_Crc32Item * plugin in self.crc.Crc32) {
			if ([APP_DELEGATE isPluginIgnore:plugin.folder]) {
				ignore++;
				continue;
			}

			for (PluginCrcList_FilesItem * file in plugin.files) {
				NSString *relativePath = [plugin.folder stringByAppendingPathComponent:file.file];
				FileAttributes *attr = collecter.collections[relativePath];

				if ((file.CrcVal.unsignedLongValue == 0) || (attr && [attr isCrcValue:file.CrcVal.unsignedLongValue])) {
					continue;
				}

				NSString *rawSavePath = [bself.workPath stringByAppendingPathComponent:[relativePath stringByAppendingString:@".7z"]];
				NSURL *url = [baseUrl URLByAppendingPathComponent:[relativePath stringByAppendingString:@".7z"].URLDecodedString];

				[bself.updater addItemWithUrl:url rawSavePath:rawSavePath relativePath:relativePath compress:@".7z" md5:nil crc32:file.CrcVal.unsignedLongValue];
				count++;
			}
		}

		NSMutableString *msg = [NSMutableString stringWithFormat:@""];

		if (count > 0) {
			[msg appendFormat:@"检测到 %ld 个文件需要更新！", count];
		} else {
			[msg appendString:@"未检测到需要更新的文件！"];
		}

		if (ignore > 0) {
			[msg appendFormat:@"(%ld个插件被忽略更新)", ignore];
		}

		[bself showCompleteTip:msg];

		[bself.btnUpdate setEnabled:YES];

		if (autoUpdate && (count > 0)) {
			[bself doUpdate];
		}
	}];
	[collecter setFailedBlock:^(FileInfoCollecter *collecter, NSError *error) {
		[bself showCompleteTip:strFormat(@"%@,%@", error.domain, @"请确认AddOns文件夹是否被意外删除！")];
		[bself.btnUpdate setEnabled:YES];
	}];
    self.progress.maxValue = 100.f;
	[collecter start];
}

- (void)doUpdate
{
	NSLogTrace;
	self.btnUpdate.state = NSOnState;

	if (self.updater && (self.updater.itemCount > 0)) {
		weakObj(self);
		[self.updater setUpdateCompletedBlock:^(FileUpdater *updater, NSError *error, NSArray *errorItems) {
			if (!error) {
				[bself showCompleteTip:@"更新完成！"];
                showComletedHud(bself.view, @"success", @"更新完成");
			} else {
				[bself showCompleteTip:@"更新失败！"];

				[NSAlert showAlertViewWithTitle:@"提示" message:error.domain];
			}

			bself.updater.updateCompletedBlock = nil;
			bself.updater.updateFileBlock = nil;
			bself.updater = nil;
			bself.btnUpdate.state = NSOffState;
		}];
		[self.updater setUpdateFileBlock:^(FileUpdater *updater, FileItemInfo *info, UpdateOperationType type) {
            NSString *tip = strFormat(@"正在%@文件 %@", type == OperationDownload ? @"下载" : @"解压", info.relativePath);
			[bself setProgressValue:updater.progressValue tip:tip];
		}];
        self.progress.maxValue = 100.f;
		[self.updater start];
	} else {
		[self chekFileDiffence:YES];
	}
}

#pragma mark - 获取插件列表
- (void)requestAddonsUpdater
{
	NSString *addonsPath = [AppDelegate addonsPath];

	if ([NSString isStringEmpty:addonsPath]) {
		self.tip = @"请选择游戏路径！";
		return;
	}

	self.tip = @"正在获取魔盒更新信息...";
	[self.btnUpdate setEnabled:NO];

	weakObj(self);

	ASIHTTPRequest *request = [self startGetRequestWithUrl:kADDONSUPDATER_URL completeBlock:^(ASIHTTPRequest *request, NSDictionary *dict, NSError *error) {
			if (!error) {
				bself.addonsUpdater = [[AddonsUpdater alloc]initWithDictionary:dict error:nil];

				if (bself.addonsUpdater) {
					[bself getPluginList:NO];	// 国服
												// [bself getPluginList:YES];	// 台服
				} else {
												// 报错
				}
			} else {
				[self showCompleteTip:@"魔盒更新信息获取失败！"];
			}
		}];
	[request setShowAccurateProgress:YES];
	[request setDownloadProgressDelegate:self.progress];
}

- (void)getPluginList:(BOOL)isTW
{
	self.tip = @"正在获取魔盒插件列表...";
	weakObj(self);
	ASIHTTPRequest *request = [self startGetRequestWithUrl:(isTW ? self.addonsUpdater.pluglistjsonaddr_TW : self.addonsUpdater.pluglistjsonaddr)
									completeBlock:^(ASIHTTPRequest *request, NSDictionary *dict, NSError *error) {
			if (!error) {
				if (isTW) {
					bself.list_tw = [[PluginList alloc]initWithDictionary:dict];
					[bself getPluginCrcList:YES];
				} else {
					bself.list = [[PluginList alloc]initWithDictionary:dict];
					[bself.pluginCategory reloadData];
					[self onIgnoreChanged:nil];
					[bself getPluginCrcList:NO];
				}
			} else {
				// TODO
				[self showCompleteTip:@"魔盒插件列表获取失败！"];
			}
		}];
	[request setShowAccurateProgress:YES];
	[request setDownloadProgressDelegate:self.progress];
}

- (void)getPluginCrcList:(BOOL)isTW
{
	self.tip = @"正在获取插件文件列表...";
	weakObj(self);
	ASIHTTPRequest *request = [self startGetRequestWithUrl:(isTW ? self.addonsUpdater.plugjsonaddr_TW : self.addonsUpdater.plugjsonaddr)
									completeBlock:^(ASIHTTPRequest *request, NSDictionary *dict, NSError *error) {
			if (!error) {
				[bself showCompleteTip:@""];
				[bself.btnUpdate setEnabled:YES];
				requesting = NO;

				if (isTW) {
					bself.crc_tw = [[PluginCrcList alloc]initWithDictionary:dict error:nil];
				} else {
					bself.crc = [[PluginCrcList alloc]initWithDictionary:dict error:nil];
					//				[DJProgressHUD dismiss];

					NSString *path = [[NSUserDefaults standardUserDefaults] valueForKey:kU_WOW_PATH];

					if (![NSString isStringEmpty:path]) {
						[bself chekFileDiffence:NO];
					}
				}
			} else {
				// TODO
				[self showCompleteTip:@"获取插件文件列表失败！"];
			}
		}];

	[request setShowAccurateProgress:YES];
	[request setDownloadProgressDelegate:self.progress];
}

#pragma mark - NSTableViewDelegate,NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if (tableView == self.pluginCategory) {
		return self.list.plugins.count;
	} else if (tableView == self.pluginTable) {
		return self.currentCategory.pluginitems.count;
	}

	return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if (tableView == self.pluginCategory) {
		PluginList_PluginsItem *item = self.list.plugins[row];
		return item;
	} else if (tableView == self.pluginTable) {
		PluginList_PluginitemsItem *plugin = self.currentCategory.pluginitems[row];
		return plugin;
	}

	return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if (tableView == self.pluginCategory) {
		return 50;
	} else if (tableView == self.pluginTable) {
        PluginList_PluginitemsItem *plugin = self.currentCategory.pluginitems[row];
		return plugin.heightForCell;
	}

	return 20;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if (self.pluginCategory == notification.object) {
		NSInteger index = self.pluginCategory.selectedRow;

		if ((index >= 0) && (index < self.list.plugins.count)) {
			PluginList_PluginsItem *item = self.list.plugins[index];

			self.currentCategory = item;
			[self.pluginTable reloadData];
		}
	}
}

#pragma mark - UI tip

- (void)setProgressValue:(double)progressValue  tip:(NSString *)tip
{
	self.progress.doubleValue = progressValue;
    self.tip = tip;
}

- (void)showCompleteTip:(NSString *)tip
{
	self.btnUpdate.state	= NSOffState;
	[self setProgressValue:0 tip:tip];
}

@end

