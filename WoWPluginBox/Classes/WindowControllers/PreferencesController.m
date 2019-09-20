//
//  PreferencesController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-14.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "PreferencesController.h"
#import "OFFileManager.h"

@interface PreferencesController ()
@property (weak) IBOutlet NSPopUpButton *maxConcurrentCount;
@property (weak) IBOutlet NSTextField	*wowPath;
@property (weak) IBOutlet NSButton		*btnClearCache;
@property (weak) IBOutlet NSButton		*btnBrowse;
@property (nonatomic, copy) NSString	*cacheSize;
@end

@implementation PreferencesController

- (void)windowDidLoad
{
	[super windowDidLoad];

	NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:KU_MAX_CONCURRENT_COUNT];
	count = count > 0 ? count : 5;
	[self.maxConcurrentCount selectItemAtIndex:count / 5 - 1];

	NSString *path = [[NSUserDefaults standardUserDefaults]valueForKey:kU_WOW_PATH];
	self.wowPath.stringValue = path;

	long long size = [OFFileManager sizeOfDirectoryAtPath:[AppDelegate cachePath]];
	self.cacheSize = strFormat(@"%.2fMB", (float)size / 1024 / 1024);
}

- (IBAction)onMaxConcurrentCountAction:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:(self.maxConcurrentCount.indexOfSelectedItem + 1) * 5 forKey:KU_MAX_CONCURRENT_COUNT];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onBtnAction:(id)sender
{
	if (sender == self.btnBrowse) {
		//

		__block NSOpenPanel *panel = [NSOpenPanel openPanel];

		[panel setPrompt:@"Open"];
		panel.canChooseFiles		= NO;
		panel.canChooseDirectories	= YES;

		weakObj(self);
		[panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSInteger result) {
			NSArray *fileNames = [panel URLs];

			if ((result == 1) && (fileNames.count > 0)) {
				NSURL *url = fileNames[0];
				[bself checkPath:url.path];
			}
		}];
	} else if (sender == self.btnClearCache) {
		showProgressHud(self.btnClearCache.superview);

		weakObj(self);
		[self performBlockInBackground:^{
			[OFFileManager removeItemsInDirectoryAtPath:[AppDelegate cachePath]];
			long long size = [OFFileManager sizeOfDirectoryAtPath:[AppDelegate cachePath]];
			bself.cacheSize = strFormat(@"%.2fMB", (float)size / 1024 / 1024);

			[bself performBlockOnMainThread:^{
				showComletedHud(bself.btnClearCache.superview, @"success", @"缓存已清空");
			}];
			// NSRunAlertPanel(@"提示", @"缓存已清空！", @"好", nil, nil, nil);
		}];
	}
}

#pragma mark - 校验路径

- (void)checkPath:(NSString *)path
{
	if ([NSString isStringEmptyOrBlank:path]) {
		[NSAlert showAlertViewWithTitle:@"路径错误" message:@"请选择正确的游戏文件夹路径!"];
		return;
	}

	NSString *oldPath = [[NSUserDefaults standardUserDefaults] stringForKey:kU_WOW_PATH];

	if ([path isEqualToString:oldPath]) {
		self.wowPath.stringValue = path;
		return;
	}

	NSFileManager	*defaultManager = [NSFileManager defaultManager];
	BOOL			isDir			= NO;
	BOOL			exist			= [defaultManager fileExistsAtPath:path isDirectory:&isDir];

	if (exist && isDir) {
		NSString *appPath = [path stringByAppendingPathComponent:@"World of Warcraft.app"];

		if ([defaultManager fileExistsAtPath:appPath]) {
			self.wowPath.stringValue = path;
			[[NSUserDefaults standardUserDefaults] setValue:path forKey:kU_WOW_PATH];
			[[NSUserDefaults standardUserDefaults] synchronize];
			postNotification(KN_WOWPATH_CHANGED, path);
            
            if(![APP_DELEGATE.rootWindowController.window isVisible]){
                [self close];
                [APP_DELEGATE.rootWindowController showWindow:APP_DELEGATE];
            }

		} else {
			[NSAlert showAlertViewWithTitle:@"路径错误" message:@"请选择正确的游戏文件夹路径!"];
		}
	}
}

@end

