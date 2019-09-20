//
//  BigfootViewController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "BigfootViewController.h"
#import "FileUpdater.h"
#import "BigFootFileList.h"
#import "OFFileManager.h"
#import <zipzap.h>
#import <XMLDictionary.h>
#import "FileInfoCollecter.h"
#import "WowBoxPluginItemCell.h"

@interface BigfootViewController () <NSTableViewDelegate, NSTableViewDataSource>
{
	__block BOOL requesting;
}
@property (weak) IBOutlet NSButton				*btnUpdate;
@property (weak) IBOutlet NSProgressIndicator	*progress;
@property (weak) IBOutlet NSTableView			*pluginTable;
@property (weak) IBOutlet NSButton				*selectAll;

@property (nonatomic, copy) NSString		*tip;
@property (nonatomic, strong) FileUpdater	*updater;

@property (nonatomic, strong) BigFootFileList *fileList;
@end

@implementation BigfootViewController

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
	self.selectAll.state	= [APP_DELEGATE isOneOrMoreIgnore:self.fileList.allPluginDirs] ? NSOffState : NSOnState;
	self.updater			= nil;
}

- (void)onWowPathChanged:(NSNotification *)notification
{
	[self onSelected];
}

- (NSString *)workPath
{
	return [[AppDelegate cachePath] stringByAppendingPathComponent:@"BigFoot"];
}

- (NSString *)fileListPath:(BOOL)zip
{
	return [[[self workPath] stringByAppendingPathComponent:@"filelist.xml"] stringByAppendingString:zip ? @".z":@""];
}

- (void)onSelected
{
	if (!self.fileList && !requesting) {
		requesting = YES;
		[self requestFileList];
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
		[APP_DELEGATE addIgnorePlugins:self.fileList.allPluginDirs];
		[self.pluginTable reloadData];
		self.updater = nil;
	} else {
		[APP_DELEGATE removeIgnorePlugins:self.fileList.allPluginDirs];
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

#pragma mark - request filelist
- (void)requestFileList
{
	NSLogTrace;

	self.tip = @"获取大脚更新...";
	[self.btnUpdate setEnabled:NO];

	__block NSString *path = [self fileListPath:YES];
	weakObj(self);

	[self startDownloadWithUrl:kBIGFOOT_FILELIST destinationPath:path progressDelegate:self.progress showAccurateProgress:YES completionBlock:^(ASIHTTPRequest *request, BOOL success) {
		if (success) {
			[bself showCompleteTip:@""];
			ZZArchive *archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:[bself fileListPath:YES]] error:nil];
			ZZArchiveEntry *entry = archive.entries[0];
			NSData *data = [entry newDataWithError:nil];

			XMLDictionaryParser *parser = [XMLDictionaryParser sharedInstance];
			[parser setNodeNameMode:XMLDictionaryNodeNameModeNever];
			[parser setAttributesMode:XMLDictionaryAttributesModeUnprefixed];
			NSDictionary *dict = [parser dictionaryWithData:data];
			bself.fileList = [[BigFootFileList alloc]initWithDictionary:dict error:nil];

			[bself.pluginTable reloadData];
			//
			[bself chekFileDiffence:NO];
		} else {
			[bself showCompleteTip:@"获取大脚更新失败！"];
		}
	}];
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
		[bself setProgressValue:((float)curIndex / collecter.itemCount * 100.f) tip:tip];
	}];
	[collecter setCompleteBlock:^(FileInfoCollecter *collecter) {
		APP_DELEGATE.localPluginFileAttributes = collecter.collections;
		[bself showCompleteTip:@"扫描本地插件完成！"];

		// check
		bself.updater = [[FileUpdater alloc]init];
		NSInteger count = 0;
		NSInteger ignore = 0;
		NSURL *baseUrl = [NSURL URLWithString:[kBIGFOOT_BASE_URL stringByAppendingString:@"Interface/3.1/Interface/AddOns/"]];

		for (BigFootFileList_AddOnItem * plugin in self.fileList.AddOn) {
			if ([APP_DELEGATE isPluginIgnore:plugin.name]) {
				ignore++;
				continue;
			}

			for (BigFootFileList_FileItem * file in plugin.File) {
				NSString *relativePath = [plugin.name stringByAppendingPathComponent:file.path];
				FileAttributes *attr = collecter.collections[relativePath];

				if ([NSString isStringEmptyOrBlank:file.checksum] || (attr && [attr isMd5Value:file.checksum])) {
					continue;
				}

				NSString *rawSavePath = [bself.workPath stringByAppendingPathComponent:[relativePath stringByAppendingString:@".z"]];
				NSURL *url = [baseUrl URLByAppendingPathComponent:[relativePath stringByAppendingString:@".z"].URLDecodedString];

				[bself.updater addItemWithUrl:url rawSavePath:rawSavePath relativePath:relativePath compress:@".z" md5:file.checksum crc32:0];
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
	return self.fileList.AddOn.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	BigFootFileList_AddOnItem *item = self.fileList.AddOn[row];

	return item;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	BigFootFileList_AddOnItem *item = self.fileList.AddOn[row];

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

@end

