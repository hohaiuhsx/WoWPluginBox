//
//  AppDelegate.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-10-31.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "AppDelegate.h"
//#import <Countly.h>
#import "UpdateWindowController.h"
#import "PreferencesController.h"
#import "RootWindowController.h"
#import "OFFileManager.h"

@interface AppDelegate () <NSTabViewDelegate>
{
	NSMutableArray *ignorePlugins;
}

@property (nonatomic, strong)  UpdateWindowController	*update;
@property (nonatomic, strong) PreferencesController		*preferences;

@end

@implementation AppDelegate

+ (NSString *)cachePath
{
	return [SandBoxCachePath stringByAppendingPathComponent:APP_NAME];
}

+ (NSString *)addonsPath
{
	NSString *path = [[NSUserDefaults standardUserDefaults]valueForKey:kU_WOW_PATH];

	return [path stringByAppendingPathComponent:@"Interface/AddOns"];
}

+ (NSString *)fontsPath
{
	NSString *path = [[NSUserDefaults standardUserDefaults]valueForKey:kU_WOW_PATH];

	return [path stringByAppendingPathComponent:@"Fonts"];
}

+ (NSString *)addOnsTrashPath
{
	return [[AppDelegate addonsPath] stringByAppendingString:@"_WowPluginBoxTrash"];
}

+ (NSString *)addOnsBackupPath
{
    return [[AppDelegate addonsPath] stringByAppendingString:@"_WowPluginBoxBackup"];
}

+ (NSString *)fontsTrashPath
{
	return [[AppDelegate addOnsTrashPath] stringByAppendingPathComponent:@"Fonts"];
}

+ (void)checkAndMakeAddOnsDir
{
	BOOL	isExist = [OFFileManager existsItemAtPath:[AppDelegate addonsPath]];
	BOOL	isDir	= [OFFileManager isDirectoryItemAtPath:[AppDelegate addonsPath]];

	if (!isExist) {
		[OFFileManager createDirectoriesForPath:[AppDelegate addonsPath]];
	} else if (!isDir) {
		[OFFileManager removeItemAtPath:[AppDelegate addonsPath]];
		[OFFileManager createDirectoriesForPath:[AppDelegate addonsPath]];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self registerRequestManagerObserver];
	//[[Countly sharedInstance] startOnCloudWithAppKey:@"3631d11c7157d761749b9ae0cab50476d62f0caf"];

	[self checkForUpdates:nil];

    self.rootWindowController = [[RootWindowController alloc]initWithWindowNibName:@"RootWindowController"];
    if([self checkWowPath]){
        [_rootWindowController showWindow:self];
    }else{
        [self showPreferences:self];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self unregisterRequestManagerObserver];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	NSLogTrace;

    if([self checkWowPath]){
        if (![self.rootWindowController.window isVisible]) {
            [self.rootWindowController showWindow:self];
        }
    }else{
        [self showPreferences:self];
    }

	return YES;
}

- (BOOL)checkWowPath
{
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:kU_WOW_PATH];
    NSFileManager	*defaultManager = [NSFileManager defaultManager];
    BOOL			isDir			= NO;
    BOOL			exist			= [defaultManager fileExistsAtPath:path isDirectory:&isDir];
    
    if (exist && isDir) {
        NSString *appPath = [path stringByAppendingPathComponent:@"World of Warcraft.app"];
        
        if ([defaultManager fileExistsAtPath:appPath]) {
            return YES;
        } else {
            NSRunAlertPanel(@"错误", @"游戏目录设置错误,请重新设置！", @"好", nil, nil, nil);
        }
    }
    return NO;
}

#pragma mark - menu action
- (IBAction)checkForUpdates:(id)sender
{
	[self startGetRequestWithUrl:kVER_CHECK completeBlock:^(ASIHTTPRequest *request, NSDictionary *dict, NSError *error) {
        
//        dict = @{
//                 @"ver":@"6",
//                 @"vername":@"1.3.2 Beta",
//                 @"hisUrl":@"http://yun.baidu.com/share/link?shareid=2374490510&uk=1141984061#path=%252Fwowpluginbox",
//                 @"url":@"http://cachefile13.rayfile.com/f541/zh-cn/download/c64418b2890c126a02db32259864c515/www.k7dj.com%20-%20WoWPluginBox_v1.3.2_beta.dmg",
//                 @"note":@"1.修复OSX 10.10（Yosemite）下无法更新的问题"
//                 };
        
		NSInteger ver = [dict[@"ver"] integerValue];

		if (ver > [APP_BUILD integerValue]) {
			// 更新
			if (!APP_DELEGATE.update) {
				APP_DELEGATE.update = [[UpdateWindowController alloc]initWithWindowNibName:@"UpdateWindowController"];
			}

			[APP_DELEGATE.update setData:dict];

			[APP_DELEGATE.update showWindow:self];
		} else if (sender) {
			NSRunAlertPanel(@"最新版本", strFormat(@"当前版本 v%@ 已经是最新版本了！", APP_VERSION), @"好", nil, nil, nil);
		}
	}];
}

- (IBAction)showPreferences:(id)sender
{
	if (!self.preferences) {
		self.preferences = [[PreferencesController alloc]initWithWindowNibName:@"PreferencesController"];
	}

	[self.preferences showWindow:self];
}

- (IBAction)openFeedback:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://nga.178.com/read.php?tid=7530658"]];
}

#pragma Plugins Ignore

- (NSArray *)ignorePlugins
{
	return [NSArray arrayWithArray:[self mutableIgnorePlugins]];
}

- (NSMutableArray *)mutableIgnorePlugins
{
	if (ignorePlugins == nil) {
		ignorePlugins = [NSMutableArray arrayWithArray:([[NSUserDefaults standardUserDefaults] arrayForKey:KU_IGNORE_PLUGINS] ? :[NSArray array])];
	}

	return ignorePlugins;
}

- (BOOL)isPluginIgnore:(NSString *)dirName
{
	return [self.ignorePlugins containsObject:dirName];
}

- (BOOL)isOneOrMoreIgnore:(NSArray *)dirNames
{
	for (NSString *item in dirNames) {
		if ([self.ignorePlugins containsObject:item]) {
			return YES;
		}
	}

	return NO;
}

- (void)addIgnorePlugin:(NSString *)dirName
{
	NSLog(@"====%@", dirName);

	if (![self isPluginIgnore:dirName]) {
		[[self mutableIgnorePlugins] addObject:dirName];
	}

	[self syncIgnorePlugins];
}

- (void)removeIgnorePlugin:(NSString *)dirName
{
	[[self mutableIgnorePlugins] removeObject:dirName];
	[self syncIgnorePlugins];
}

- (void)addIgnorePlugins:(NSArray *)dirNames
{
	for (NSString *d in dirNames) {
		if (![self isPluginIgnore:d]) {
			[[self mutableIgnorePlugins] addObject:d];
		}
	}

	[self syncIgnorePlugins];
}

- (void)removeIgnorePlugins:(NSArray *)dirNames
{
	for (NSString *d in dirNames) {
		[[self mutableIgnorePlugins] removeObject:d];
	}

	[self syncIgnorePlugins];
}

- (void)syncIgnorePlugins
{
	[[NSUserDefaults standardUserDefaults] setValue:ignorePlugins forKey:KU_IGNORE_PLUGINS];
	[[NSUserDefaults standardUserDefaults] synchronize];
	postNotification(KN_IGNORE_CHANGED, nil);
}

- (NSUInteger)maxConcurrentDownloadCount
{
	NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:KU_MAX_CONCURRENT_COUNT];

	return count > 0 ? count : 5;
}

@end

