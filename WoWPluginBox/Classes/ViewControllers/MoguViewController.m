//
//  MoguViewController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "MoguViewController.h"
#import "FileUpdater.h"
#import "MoGuPluginList.h"
#import <XMLDictionary.h>
#import "OFFileManager.h"
#import "PluginCell.h"
#import <URKArchive.h>

@interface MoguViewController () <NSTableViewDelegate, NSTableViewDataSource>
{
	__block BOOL requesting;
}
@property (weak) IBOutlet NSProgressIndicator	*progress;
@property (weak) IBOutlet NSTableView			*pluginTable;
@property (weak) IBOutlet NSSearchField			*searchField;

@property (nonatomic, copy) NSString *tip;

@property (nonatomic, strong) NSArray			*fileMd5s;	// 蘑菇xml文件MD5 不是插件的
@property (nonatomic, strong) MoGuPluginList	*pluginList;
@property (nonatomic, strong) NSArray			*plugins;
@property (nonatomic, strong) NSArray			*localPlugins;

@end

@implementation MoguViewController

- (void)loadView
{
	[super loadView];
	addSelfAsNotificationObserver(KN_WOWPATH_CHANGED, @selector(onWowPathChanged:));

	NSData *data = [NSData dataWithContentsOfFile:[self pluginListPath]];

	if (data) {
		XMLDictionaryParser *parser = [XMLDictionaryParser sharedInstance];
		[parser setNodeNameMode:XMLDictionaryNodeNameModeNever];
		[parser setAttributesMode:XMLDictionaryAttributesModeUnprefixed];
		NSDictionary *dict = [parser dictionaryWithData:data];
		self.pluginList = [[MoGuPluginList alloc]initWithDictionary:dict error:nil];
	}
}

- (void)dealloc
{
	removeSelfNofificationObservers;
}

- (void)onWowPathChanged:(NSNotification *)notification
{
	[self onSelected];
}

- (NSString *)workPath
{
	return [[AppDelegate cachePath] stringByAppendingPathComponent:@"MoguPlugin"];
}

- (NSString *)pluginListPath
{
	return [[self workPath] stringByAppendingPathComponent:@"pluglist.xml"];
}

- (void)onSelected
{
	if (!self.fileMd5s && !requesting) {
		requesting = YES;
		[self getInfo];
	}
}

- (void)getInfo
{
	weakObj(self);
	[self startGetRequestWithUrl:kMOGU_INFO_URL completeBlock:^(ASIHTTPRequest *request, NSDictionary *dict, NSError *error) {
		NSArray *lines = [request.responseString componentsSeparatedByString:@"\r\n"];
		bself.fileMd5s = lines;

		for (NSString * s in lines) {
			if ([s startWith:@"Plug="]) {
				NSString *pluginListMd5 = [s substringFromIndex:5];

				if (bself.pluginList) {
					if (![pluginListMd5.lowercaseString isEqualToString:bself.pluginList.ver.lowercaseString]) {
						[bself getPluginList];
					} else {
						[bself checkInstallStatusAndReload];
					}
				} else {
					[bself getPluginList];
				}

				break;
			}
		}
	}];
}

- (void)getPluginList
{
	NSLogTrace;
	__block NSString *path = [self pluginListPath];
	weakObj(self);
	self.tip = @"获取插件列表...";
	[self startDownloadWithUrl:kMOGU_PlUGINLIST_URL destinationPath:path progressDelegate:self.progress showAccurateProgress:YES completionBlock:^(ASIHTTPRequest *request, BOOL success) {
		if (success) {
			bself.tip = @"";
			XMLDictionaryParser *parser = [XMLDictionaryParser sharedInstance];
			[parser setNodeNameMode:XMLDictionaryNodeNameModeNever];
			[parser setAttributesMode:XMLDictionaryAttributesModeUnprefixed];
			NSDictionary *dict = [parser dictionaryWithData:[NSData dataWithContentsOfFile:path]];
			bself.pluginList = [[MoGuPluginList alloc]initWithDictionary:dict error:nil];

			for (MoGuPluginList_PItem * item in bself.pluginList.P) {
				item.installed = [bself.localPlugins containsObject:item.Folder];
			}

			[bself checkInstallStatusAndReload];
		} else {
			bself.tip = @"获取插件列表失败！";
		}
	}];
}

- (void)checkInstallStatusAndReload
{
	NSLogTrace;

	if (self.plugins.count > 0) {
		[self filtePluginsByKeyword:self.searchField.stringValue];
		return;
	}

	NSString *addonsPath = [AppDelegate addonsPath];

	if ([NSString isStringEmpty:addonsPath]) {
		self.tip = @"请选择游戏路径！";
		return;
	}

	self.tip = @"搜索指定的插件，点击添加即可安装！";

	NSFileManager	*manager	= [NSFileManager defaultManager];
	BOOL			isDir		= NO;
	BOOL			exist		= [manager fileExistsAtPath:addonsPath isDirectory:&isDir];

	if (exist && !isDir) {
		[manager moveItemAtURL:[NSURL fileURLWithPath:addonsPath] toURL:[NSURL fileURLWithPath:[addonsPath stringByAppendingString:@"_back"]] error:nil];
		[manager createDirectoryAtPath:addonsPath withIntermediateDirectories:YES attributes:nil error:nil];
	}

	if (!exist) {
		[manager createDirectoryAtPath:addonsPath withIntermediateDirectories:YES attributes:nil error:nil];
	}

	self.localPlugins = [manager contentsOfDirectoryAtPath:addonsPath error:nil];

	//
	for (MoGuPluginList_PItem *item in self.pluginList.P) {
		item.installed = [self.localPlugins containsObject:item.Folder];
	}

	[self filtePluginsByKeyword:self.searchField.stringValue];
}

#pragma mark - NSTableViewDelegate,NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.plugins.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	MoGuPluginList_PItem *item = self.plugins[row];

	return item;// strFormat(@"%@        %@",item.toString,[self.localPlugins containsObject:item.Folder]?@"移除":@"添加");
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 60;
}

#pragma mark - NSTextFieldDelegate
- (IBAction)onSearchAction:(NSSearchField *)sender
{
	[self filtePluginsByKeyword:sender.stringValue];
}

- (void)filtePluginsByKeyword:(NSString *)key
{
	if ([NSString isStringEmptyOrBlank:key]) {
		self.plugins = self.pluginList.P;
	} else {
		NSMutableArray *temp = [NSMutableArray array];

		for (MoGuPluginList_PItem *item in self.pluginList.P) {
			if ([item.Name.lowercaseString contains:key.lowercaseString]) {
				[temp addObject:item];
			}
		}

		self.plugins = temp;
	}

	[self.pluginTable reloadData];
}

#pragma mark - cell button action
- (void)onRemoveItem:(MoGuPluginList_PItem *)item sender:(PluginCell *)cell
{
	NSLogTrace;

	showProgressHud(self.view);
	NSString	*path		= [[AppDelegate addonsPath] stringByAppendingPathComponent:item.Folder];
	NSString	*trashPath	= [[AppDelegate addOnsTrashPath] stringByAppendingPathComponent:item.Folder];
	NSError		*error		= nil;
	[OFFileManager removeItemAtPath:trashPath error:nil];
	[OFFileManager moveItemAtPath:path toPath:trashPath error:&error];

	NSLog(@"=======\n%@\n%@", path, trashPath);
	item.installed = NO;
	showComletedHud(self.view, @"success", @"操作成功");
	// [NSAlert showAlertViewWithTitle:@"操作成功" message:strFormat(@"该插件已移动到:\n%@", trashPath)];
}

- (void)onInstallItem:(__weak MoGuPluginList_PItem *)item sender:(__weak PluginCell *)cell
{
	NSLogTrace;
	showProgressHud(self.view);
	NSString	*url	= [self.pluginList.DownLoadUrl stringByAppendingString:item.Url.URLEncodedString];
	NSString	*path	= [[self workPath] stringByAppendingPathComponent:item.Url];
	weakObj(self);
	self.tip = strFormat(@"正在下载 %@", item.Url);
	[self startDownloadWithUrl:url destinationPath:path progressDelegate:self.progress showAccurateProgress:YES completionBlock:^(ASIHTTPRequest *request, BOOL success) {
		if (success) {
			[bself showCompleteTip:@"下载成功！"];
			// todo 解压
			[bself uncompress:item cell:cell];
		} else {
			[bself showCompleteTip:@"下载失败！"];
			cell.button.state = NSOffState;
			showComletedHud(bself.view, @"failed", @"文件下载失败");
		}
	}];
}

- (void)uncompress:(MoGuPluginList_PItem *)item cell:(PluginCell *)cell
{
	self.tip = @"正在解压...";
	NSString	*path	= [[self workPath] stringByAppendingPathComponent:item.Url];
	NSString	*toDir	= [self workPath];
	[OFFileManager createDirectoriesForPath:toDir];
	URKArchive	*archive	= [URKArchive rarArchiveAtPath:path];
	NSError		*error		= nil;
	[archive extractFilesTo:toDir overWrite:YES error:&error];

	if (error) {
        self.tip = @"文件解压失败";
		NSLog(@"===error:%@", error);
		cell.button.state = NSOffState;
		showComletedHud(self.view, @"failed", @"文件解压失败");
	} else {
		self.tip = @"正在移动插件到游戏目录...";

		NSString *toPath = [[AppDelegate addonsPath] stringByAppendingPathComponent:item.Folder];
		[OFFileManager createDirectoriesForPath:toDir];
		[OFFileManager removeItemAtPath:toPath];
		BOOL success = [OFFileManager moveItemAtPath:[toDir stringByAppendingPathComponent:item.Folder] toPath:toPath error:&error];

		if (!success) {
			[self showCompleteTip:@"文件解压失败！"];
			cell.button.state = NSOffState;
			showComletedHud(self.view, @"failed", @"文件解压失败");
		} else {
			[self showCompleteTip:@"安装成功!"];
			item.installed = YES;
			showComletedHud(self.view, @"success", @"安装成功");
		}
	}
}

#pragma mark - UI tip
- (void)setProgressValue:(double)value tip:(NSString *)tip
{
	self.progress.doubleValue = value;
	self.tip = tip;
}

- (void)showCompleteTip:(NSString *)tip
{
	self.tip = tip;
	self.progress.doubleValue = 0;
}

@end

