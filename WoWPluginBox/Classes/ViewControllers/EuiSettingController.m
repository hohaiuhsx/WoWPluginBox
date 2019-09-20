//
//  EuiSettingController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-18.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "EuiSettingController.h"
#import "PBPinger.h"
#import "OFFileManager.h"
#import <zipzap.h>

@interface EuiSettingController () <ASIProgressDelegate>
{
	double maxProgress;
}

@property (weak) IBOutlet NSPopUpButton *line;
@property (weak) IBOutlet NSPopUpButton *edition;
@property (weak) IBOutlet NSTextField	*ping;
@property (weak) IBOutlet NSButton		*btnFonts;
@property (weak) IBOutlet NSView		*view;

@property (nonatomic, strong) EuiXml *xml;
@end

@implementation EuiSettingController

+ (EuiSettingController *)showWithEuixml:(EuiXml *)xml sender:(id)sender
{
	EuiSettingController *controller = [[EuiSettingController alloc]initWithWindowNibName:@"EuiSettingController"];

	controller.xml = xml;
	[controller showWindow:sender];
	return controller;
}

- (void)windowDidLoad
{
	[self pingInBackground];
	[self checkFont];
}

#pragma mark - action
- (IBAction)onBtnAction:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (sender == _line) {
		NSInteger line = [self.line indexOfSelectedItem];
		[defaults setInteger:line forKey:kU_EUI_LINE];
		[self pingInBackground];
	} else if (sender == _edition) {
		NSInteger edition = [self.edition indexOfSelectedItem];
		[defaults setInteger:edition forKey:KU_EUI_EDITION];
	}

	[defaults synchronize];
	postNotification(KN_EUISETTING_CHANGED, nil);
}

- (IBAction)onBtnFontAction:(id)sender
{
	NSString *addonsPath = [AppDelegate addonsPath];

	__weak MBProgressHUD *hud = showProgressHud(self.view);

	if (self.btnFonts.state == NSOnState) {
		// 安装
		weakObj(self);
		// self.tip = @"正在下载字体文件...";
		hud.mode		= MBProgressHUDModeDeterminate;
		hud.labelText	= @"下载中";
		hud.labelFont	= [NSFont systemFontOfSize:14];
		__block NSString *path = [[self tempPath] stringByAppendingPathComponent:@"ARHei.zipx"];
		[self startDownloadWithUrl:[self curFontUrl] destinationPath:path progressDelegate:self showAccurateProgress:YES completionBlock:^(ASIHTTPRequest *request, BOOL success) {
			if (success) {
				hud.labelText = @"解压...";
				ZZArchive *archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:path] error:nil];
				ZZArchiveEntry *entry = archive.entries[0];
				NSString *toPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:entry.fileName];
				[OFFileManager removeItemAtPath:toPath];
				[OFFileManager createDirectoriesForFileAtPath:toPath];
				NSError *error = nil;

				NSData *data = [entry newDataWithError:&error];
				NSLog(@"Uncompress Error:%@", error);
				BOOL success = [data writeToFile:toPath atomically:YES];

				if (success) {
					// bself.tip = @"字体更新成功！";
					NSArray *array = @[@"ZYKai_T.ttf",
					@"ARHei.ttf",
					@"ARIALN.ttf",
					@"ARKai_C.ttf",
					@"ARKai_T.ttf",
					@"FRIZQT__.ttf",
					@"skurri.ttf",
					@"ZYHei.ttf",
					@"ZYKai_C.ttf"];

					[OFFileManager createDirectoriesForPath:[AppDelegate fontsPath]];

					for (NSString * file in array) {
						[OFFileManager copyItemAtPath:toPath toPath:[[AppDelegate fontsPath] stringByAppendingPathComponent:file]];
					}

					showComletedHud(bself.view, @"success", @"安装成功");
				} else {
					bself.btnFonts.state = NSOnState;
					showComletedHud(bself.view, @"failed", @"解压失败");
				}
			} else {
				bself.btnFonts.state = NSOnState;
				// bself.tip = @"字体文件下载失败！";
				NSLog(@"=====error:%@", request.error);
				showComletedHud(bself.view, @"failed", @"下载失败");
			}
		}];
	} else {
		// 移除
		[OFFileManager removeItemAtPath:[AppDelegate fontsTrashPath]];
		BOOL succes = [OFFileManager moveItemAtPath:[AppDelegate fontsPath] toPath:[AppDelegate fontsTrashPath]];

		if (!succes) {
			self.btnFonts.state = NSOffState;
			showComletedHud(self.view, @"failed", @"卸载失败");
		} else {
			// [NSAlert showAlertViewWithTitle:@"卸载成功" message:strFormat(@"字体文件已移动到:%@", [AppDelegate fontsTrashPath])];
			showComletedHud(self.view, @"success", @"卸载成功");
		}
	}
}

- (NSString *)tempPath
{
	return [[AppDelegate cachePath] stringByAppendingPathComponent:@"EUI"];
}

- (NSString *)currentServer
{
	NSInteger	line	= [self.line indexOfSelectedItem];
	NSString	*server = [self.xml.Server server:line];

	return server;
}

- (NSString *)currentUrl
{
	NSString	*server		= [self currentServer];
	NSInteger	index		= [self.edition indexOfSelectedItem];
	NSString	*edition	= [self.xml.AddOns addOnsUrl:index];

	return strFormat(@"%@%@", server, edition);
}

- (NSString *)curFontUrl
{
	return strFormat(@"%@%@", [self currentServer], self.xml.AddOns.fontUrl);
}

- (void)pingInBackground
{
	weakObj(self);
	showProgressHud(bself.view);
	self.ping.stringValue = @"检测中...";
	[self pingCurrentLine:^(NSTimeInterval time) {
		hideAllHuds(bself.view);
		self.ping.stringValue = strFormat(@"%.2f ms", time * 1000);

		if (time < 0) {
			self.ping.textColor = [NSColor redColor];
			self.ping.stringValue = @"不通";
		} else if (time * 1000 < 50) {
			self.ping.textColor = NSColorFromRGB(0x00ad5f);
		} else if (time * 1000 < 100) {
			self.ping.textColor = [NSColor orangeColor];
		} else {
			self.ping.textColor = [NSColor redColor];
		}
	}];
}

- (void)pingCurrentLine:(void (^)(NSTimeInterval time))block
{
	[self performBlockInBackground:^{
		NSURL *url = [NSURL URLWithString:[self currentUrl]];
		PBPinger *pinger = [PBPinger pingerWithHost:url.host];
		NSTimeInterval time = [pinger pingOnce];

		if (block) {
			block(time);
		}
	}];
}

- (void)checkFont
{
	BOOL exist = [OFFileManager existsItemAtPath:[AppDelegate fontsPath]];

	self.btnFonts.state = exist ? NSOnState : NSOffState;
}

- (void)setDoubleValue:(double)newProgress
{
	MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];

	hud.progress = newProgress / maxProgress;
}

- (void)setMaxValue:(double)newMax
{
	maxProgress = newMax;
}

@end

