//
//  AppDelegate.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-10-31.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RootWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) RootWindowController	*rootWindowController;

@property (nonatomic, strong) NSDictionary *localPluginFileAttributes;

+ (NSString *)cachePath;
+ (NSString *)addonsPath;
+ (NSString *)fontsPath;
+ (NSString *)addOnsTrashPath;
+ (NSString *)addOnsBackupPath;
+ (NSString *)fontsTrashPath;

+ (void)checkAndMakeAddOnsDir;

//
- (NSArray *)ignorePlugins;
- (BOOL)isPluginIgnore:(NSString *)dirName;
- (BOOL)isOneOrMoreIgnore:(NSArray *)dirNames;
- (void)addIgnorePlugin:(NSString *)dirName;
- (void)removeIgnorePlugin:(NSString *)dirName;
- (void)addIgnorePlugins:(NSArray *)dirNames;
- (void)removeIgnorePlugins:(NSArray *)dirNames;
//
- (NSUInteger) maxConcurrentDownloadCount;
@end

