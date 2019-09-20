//
//  EuiViewController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "EuiViewController.h"
#import "FileUpdater.h"
#import "OFFileManager.h"
#import <zipzap.h>
#import <XMLDictionary.h>
#import "FileInfoCollecter.h"
#import "WowBoxPluginItemCell.h"
#import "EuiSettingController.h"
#import "EuiXml.h"
#import "EuiFileList.h"
#import "EuiSettingController.h"

@interface EuiViewController () <NSTableViewDelegate, NSTableViewDataSource>
{
	__block BOOL requesting;
}
@property (weak) IBOutlet NSButton				*btnUpdate;
@property (weak) IBOutlet NSProgressIndicator	*progress;
@property (weak) IBOutlet NSTableView			*pluginTable;
@property (weak) IBOutlet NSButton				*btnSetting;

@property (nonatomic, copy) NSString	*tip;
@property (nonatomic, copy) NSString	*settingInfo;

@property (nonatomic, strong) FileUpdater *updater;

@property (nonatomic, strong) EuiXml		*xml;
@property (nonatomic, strong) EuiFileList	*fileList;

@property (nonatomic, strong) NSMutableArray		*conflicts;
@property (nonatomic, strong) EuiSettingController	*settingController;

@end

@implementation EuiViewController

- (void)loadView
{
	[super loadView];
	addSelfAsNotificationObserver(KN_EUISETTING_CHANGED, @selector(onSettingChanged:));
	addSelfAsNotificationObserver(KN_WOWPATH_CHANGED, @selector(onWowPathChanged:));
}

- (void)dealloc
{
	removeSelfNofificationObservers;
}

- (void)onSettingChanged:(NSNotification *)notification
{
	self.settingInfo = strFormat(@"线路:%@  版本:%@", self.lineName, self.editionName);
}

- (void)onWowPathChanged:(NSNotification *)notification
{
	[self onSelected];
}

- (NSString *)workPath
{
	return [[AppDelegate cachePath] stringByAppendingPathComponent:@"EUI"];
}

- (NSUInteger)lineIndex
{
	return [[NSUserDefaults standardUserDefaults]integerForKey:kU_EUI_LINE];
}

- (NSString *)lineName
{
	NSMutableString *s		= [NSMutableString stringWithFormat:@"线路%ld", self.lineIndex + 1];
	NSURL			*url	= [NSURL URLWithString:self.currentServer];

	[s appendFormat:@"(%@)", url.host];
	return s;
}

- (NSUInteger)editionIndex
{
	return [[NSUserDefaults standardUserDefaults]integerForKey:KU_EUI_EDITION];
}

- (NSString *)editionName
{
	switch (self.editionIndex) {
		case 0:
			return @"正式服开发版";

		case 1:
			return @"正式服稳定版";

		case 2:
			return @"PTR服专用版";

		case 3:
			return @"Beta服版";

		default:
			return @"";
	}
}

- (NSString *)currentServer
{
	NSString *server = [self.xml.Server server:self.lineIndex];

	return server;
}

- (NSString *)currentUrl
{
	NSString	*server		= [self currentServer];
	NSString	*edition	= [self.xml.AddOns addOnsUrl:self.editionIndex];

	return strFormat(@"%@%@", server, edition);
}

- (NSString *)euilistUrl
{
	return [[self currentUrl] stringByAppendingString:@"euilist.xml"];
}

- (void)onSelected
{
	if (!self.xml && !requesting) {
		requesting = YES;
		[self requestXml];
	}
}

- (void)awakeFromNib
{
	[self.btnUpdate setOxygenDefaultStyle];
}

- (IBAction)onBtnAction:(id)sender
{
	if (sender == _btnUpdate) {
		if (_btnUpdate.state == NSOnState) {
			[self doUpdate];
		} else {
			[self.updater cancel];
		}
	} else if (sender == _btnSetting) {
		if (self.xml) {
			if (self.settingController) {
				[self.settingController showWindow:self];
			} else {
				self.settingController = [EuiSettingController showWithEuixml:self.xml sender:self];
			}
		}
	}
}

#pragma mark - request
- (void)requestXml
{
	NSLogTrace;
	self.tip = @"获取EUI更新...";
	[self.btnUpdate setEnabled:NO];
	weakObj(self);
	ASIHTTPRequest *request = [self startGetRequestWithUrl:kEUI_XML_URL completeBlock:^(ASIHTTPRequest *request, NSDictionary *dict, NSError *error) {
			if (!request.error) {
				XMLDictionaryParser *parser = [XMLDictionaryParser sharedInstance];
				[parser setNodeNameMode:XMLDictionaryNodeNameModeNever];
				[parser setAttributesMode:XMLDictionaryAttributesModeUnprefixed];
				dict = [parser dictionaryWithData:request.responseData];
				bself.xml = [[EuiXml alloc]initWithDictionary:dict error:&error];
				[bself.pluginTable reloadData];

				if (bself.xml) {
					[bself onSettingChanged:nil];
					[bself requestEuiList:NO];
				} else {
					[bself showCompleteTip:@"无法获取EUI插件信息！"];
				}
			} else {
				[bself showCompleteTip:@"无法获取EUI插件信息！"];
				requesting = NO;
			}
		}];
	[request setShowAccurateProgress:YES];
	[request setDownloadProgressDelegate:self.progress];
}

- (void)requestEuiList:(BOOL)autoDownload
{
	weakObj(self);
	[self startGetRequestWithUrl:[self euilistUrl] completeBlock:^(ASIHTTPRequest *request, NSDictionary *dict, NSError *error) {
		requesting = NO;

		if (!request.error) {
			XMLDictionaryParser *parser = [XMLDictionaryParser sharedInstance];
			[parser setNodeNameMode:XMLDictionaryNodeNameModeNever];
			[parser setAttributesMode:XMLDictionaryAttributesModeUnprefixed];
			dict = [parser dictionaryWithData:request.responseData];

			bself.fileList = [[EuiFileList alloc]initWithDictionary:dict error:nil];
			[bself showCompleteTip:@""];
			[bself chekFileDiffence:autoDownload];
			[bself.btnUpdate setEnabled:YES];
		} else {
			[bself showCompleteTip:@"获取EUI插件文件信息失败！请检查线路设置后重试！"];
		}
	}];
}

#pragma mark - 检测文件差异
- (void)chekFileDiffence:(BOOL)autoUpdate
{
	[self.btnUpdate setEnabled:NO];
	[AppDelegate checkAndMakeAddOnsDir];

	self.conflicts = [NSMutableArray array];
	FileInfoCollecter *collecter = [[FileInfoCollecter alloc]initWithDirectory:[AppDelegate addonsPath]];
	weakObj(self);
	[collecter setCollectBlock:^(FileInfoCollecter *collecter, FileAttributes *attr, NSUInteger curIndex) {
		NSString *tip = [NSString stringWithFormat:@"正在扫描本地插件:%@", [attr.path lastPathComponent]];
		[bself setProgressValue:((float)curIndex / collecter.itemCount * 100.f) tip:tip];
	}];
	[collecter setCompleteBlock:^(FileInfoCollecter *collecter) {
		APP_DELEGATE.localPluginFileAttributes = collecter.collections;
		[bself showCompleteTip:@"扫描本地插件完成！"];

		// check
		bself.updater = [[FileUpdater alloc]init];
		NSInteger count = 0;
		NSInteger conflict = 0;
		NSURL *baseUrl = [NSURL URLWithString:[[self currentUrl] stringByAppendingString:@"Interface/AddOns/"]];

		for (EuiXml_AItem * item in self.xml.OtherAddOns.A) {
			if (collecter.collections[item.name]) {
				item.installed = YES;
			}

			item.checked = YES;
		}

		[bself.pluginTable reloadData];

		NSMutableString *cofilictTip = [NSMutableString string];

		for (EuiFileList_DeleteFileItem * item in self.fileList.DeleteFile) {
			NSString *component = item.name;

			if (collecter.collections[component]) {
				conflict++;
				[bself.conflicts addObject:component];
				[cofilictTip appendFormat:@"%@\n", component];
			}
		}

		for (EuiFileList_FileItem * item in self.fileList.File) {
			NSString *relativePath = item.Url;

			if ([relativePath startWith:@"Interface/AddOns/"]) {
				relativePath = [relativePath substringFromIndex:[@"Interface/AddOns/" length]];
			}

			FileAttributes *attr = collecter.collections[relativePath];

			if ([NSString isStringEmptyOrBlank:item.Md5] || (attr && [attr isMd5Value:item.Md5])) {
				continue;
			}

			NSString *rawSavePath = [bself.workPath stringByAppendingPathComponent:relativePath];
			NSURL *url = [baseUrl URLByAppendingPathComponent:relativePath.URLDecodedString];

			[bself.updater addItemWithUrl:url rawSavePath:rawSavePath relativePath:relativePath compress:@"" md5:item.Md5 crc32:0];
			count++;
		}

		NSMutableString *msg = [NSMutableString stringWithFormat:@""];

		if (count > 0) {
			[msg appendFormat:@"检测到 %ld 个文件需要更新！", count];
		} else {
			[msg appendString:@"未检测到需要更新的文件！"];
		}

		if (conflict > 0) {
			[msg appendFormat:@"%ld个不兼容插件将删除！", conflict];
		}

		[bself showCompleteTip:msg];

		[bself.btnUpdate setEnabled:YES];

		if (conflict > 0) {
			NSInteger index = NSRunAlertPanel(@"提示", @"以下插件不兼容，执行更新将删除：\n%@", @"更新", @"取消", nil, cofilictTip, nil);

			if (index == 0) {
				bself.updater = nil;
				bself.conflicts = nil;
				return;
			}
		}

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

	self.progress.maxValue = self.conflicts.count;
	int i = 0;

	for (NSString *plugin in self.conflicts) {
		i++;
		NSString *trash = [[AppDelegate addOnsTrashPath] stringByAppendingPathComponent:plugin];
		[OFFileManager removeItemAtPath:trash error:nil];
		[OFFileManager moveItemAtPath:[[AppDelegate addonsPath] stringByAppendingPathComponent:plugin] toPath:trash];
		[self setProgressValue:i tip:strFormat(@"正在删除插件 %@", plugin)];
	}

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
			[bself setProgressValue:updater.progressValue tip:strFormat(@"正在%@文件 %@", type == OperationDownload ? @"下载" : @"解压", info.relativePath)];
		}];
		self.progress.maxValue = 100.f;
		[self.updater start];
	} else {
		[self chekFileDiffence:YES];
	}
}

#pragma mark - NSTableViewDelegate,NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.xml.OtherAddOns.A.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	EuiXml_AItem *item = self.xml.OtherAddOns.A[row];

	return item;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	EuiXml_AItem *item = self.xml.OtherAddOns.A[row];

	return item.heightForCell;
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
	self.progress.doubleValue	= 0;
	self.btnUpdate.state		= NSOffState;
}

#pragma mark - EuiCellDelegate
- (void)onRemoveItem:(EuiXml_AItem *)item sender:(EuiOtherPluginCell *)cell
{
	NSLogTrace;

	for (NSString *dir in [item.dirlist componentsSeparatedByString : @"|"]) {
		NSString	*path		= [[AppDelegate addonsPath] stringByAppendingPathComponent:dir];
		NSString	*trashPath	= [[AppDelegate addOnsTrashPath] stringByAppendingPathComponent:dir];

		if (![OFFileManager existsItemAtPath:path]) {
			continue;
		}

		[OFFileManager removeItemAtPath:trashPath error:nil];
		[OFFileManager moveItemAtPath:path toPath:trashPath error:nil];
	}

	item.installed = NO;
	showComletedHud(self.view, @"success", @"操作成功");

	[NSAlert showAlertViewWithTitle:@"操作成功" message:strFormat(@"以下插件:\n%@\n已移动到:\n%@", [item.dirlist stringByReplacingOccurrencesOfString:@"|" withString:@"\n"], [AppDelegate addOnsTrashPath])];
}

- (void)onInstallItem:(__weak EuiXml_AItem *)item sender:(__weak EuiOtherPluginCell *)cell
{
	NSLogTrace;
	showProgressHud(self.view);
	NSString	*url	= [self.currentServer stringByAppendingString:item.url];
	NSString	*path	= [[self workPath] stringByAppendingPathComponent:item.url];

	self.tip = strFormat(@"正在下载 %@", item.url);
	weakObj(self);
	[self startDownloadWithUrl:url destinationPath:path progressDelegate:self.progress showAccurateProgress:YES completionBlock:^(ASIHTTPRequest *request, BOOL success) {
		if (success) {
			[bself showCompleteTip:@"下载成功!"];
			// todo 解压
			[bself uncompress:item cell:cell];
		} else {
			[bself showCompleteTip:@"下载失败！"];

			cell.button.state = NSOffState;
			showComletedHud(bself.view, @"failed", @"下载失败");
		}
	}];
}

- (void)uncompress:(EuiXml_AItem *)item cell:(EuiOtherPluginCell *)cell
{
	self.tip = @"正在解压...";
	NSString	*path	= [[self workPath] stringByAppendingPathComponent:item.url];
	NSString	*toDir	= [AppDelegate addonsPath];

	NSError		*error		= nil;
	ZZArchive	*archive	= [ZZArchive archiveWithURL:[NSURL fileURLWithPath:path] error:&error];

	if (!error) {
		BOOL	success = NO;
		int		count	= 0;

		for (ZZArchiveEntry *entry in archive.entries) {
			NSLog(@"====%@", entry.fileName);
			count++;
			[self setProgressValue:(double)count / archive.entries.count * 100.f tip:strFormat(@"正在解压文件 %@", entry.fileName)];
			NSString *toPath = [toDir stringByAppendingPathComponent:entry.fileName];

			if ([entry.fileName endWith:@"/"]) {
				[OFFileManager createDirectoriesForPath:toPath];
				continue;
			}

			NSData *data = [entry newDataWithError:&error];

			if (!error) {
				[OFFileManager createDirectoriesForFileAtPath:toPath];
				success = [data writeToFile:toPath atomically:YES];
			}
		}

		[self showCompleteTip:@"安装成功！"];
		item.installed = YES;
		showComletedHud(self.view, @"success", @"安装成功");
	} else {
		[self showCompleteTip:@"文件解压失败！"];
		cell.button.state = NSOffState;
		showComletedHud(self.view, @"failed", @"解压失败");
	}
}

@end

