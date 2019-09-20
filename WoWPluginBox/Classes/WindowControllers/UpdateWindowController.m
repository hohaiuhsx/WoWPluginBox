//
//  UpdateWindowController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-14.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "UpdateWindowController.h"
#import <ASIHTTPRequest.h>
#import "OFFileManager.h"

@interface UpdateWindowController () <ASIProgressDelegate>
{
    NSString	*url;
    NSString *hisUrl;
    NSString	*fileName;
    NSString	*savePath;
    long long	bytes;
}
@property (nonatomic, copy) NSString			*curVersion;
@property (nonatomic, copy) NSString			*lastVersion;
@property (nonatomic, copy) NSString			*note;
@property (nonatomic, copy) NSString			*tip;
@property (weak) IBOutlet NSProgressIndicator	*downloadProgress;
@property (weak) IBOutlet NSButton				*btnDown;

@property (nonatomic, strong) ASIHTTPRequest *request;

@end

@implementation UpdateWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)setData:(NSDictionary *)dict
{
    [self cancel];
    self.curVersion		= APP_VERSION;
    self.lastVersion	= dict[@"vername"];
    self.note			= dict[@"note"];
    
    url			= dict[@"url"];
    hisUrl = dict[@"hisUrl"];
    fileName	= [url lastPathComponent];
    savePath	= [[AppDelegate cachePath] stringByAppendingPathComponent:fileName];
    
}

- (void)cancel
{
    if (self.request) {
        [self.request setDownloadProgressDelegate:nil];
        [self.request setFailedBlock:nil];
        [self.request setCompletionBlock:nil];
        [self.request cancel];
    }
    
    bytes		= 0;
    self.tip	= @"";
    self.downloadProgress.doubleValue = 0;
    self.btnDown.state = NSOffState;
}

- (IBAction)onBtnAction:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    [self close];
    
    //	if (self.btnDown.state == NSOffState) {
    //		[self cancel];
    //		[self close];
    //	} else {
    //		//下载
    
    //        weakObj(self);
    //        blockObj(savePath);
    //
    //        self.request = [self startDownloadWithUrl:url destinationPath:savePath progressDelegate:self showAccurateProgress:YES completionBlock:^(ASIHTTPRequest *request, BOOL success) {
    //            if (success) {
    //                [bself close];
    //                NSTask *task = [[NSTask alloc]init];
    //                [task setLaunchPath:@"/usr/bin/open"];
    //                [task setArguments:@[bsavePath]];
    //                [task launch];
    //            } else {
    //                bself.btnDown.state = NSOffState;
    //                bself.tip = @"下载失败,请重试！";
    //            }
    //        }];
    //	}
}

- (IBAction)versionHist:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:hisUrl]];
}

#pragma mark progress
- (void)setDoubleValue:(double)newProgress
{
    self.downloadProgress.doubleValue = newProgress * 100;
}

- (void)setMaxValue:(double)newMax
{
    self.downloadProgress.maxValue = newMax;
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)b
{
    bytes		+= b;
    self.tip	= strFormat(@"%.2fMB/%.2fMB", ((float)bytes / 1024 / 1024), ((float)request.contentLength / 1024 / 1024));
}

@end

