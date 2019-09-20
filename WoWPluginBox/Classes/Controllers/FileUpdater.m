//
//  FileUpdater.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-17.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "FileUpdater.h"
#import "OFFileManager.h"
#import <ASIHTTPRequest.h>
#import <ASINetworkQueue.h>
#import "LZMAExtractor.h"
#import <zipzap.h>
#import <URKArchive.h>

#define errorCanceled [NSError errorWithDomain:@"更新操作被取消" code:-100 userInfo:nil]

@implementation FileItemInfo

- (BOOL)isMd5Check
{
	return ![NSString isStringEmptyOrBlank:_md5];
}

- (BOOL)isCrcCheck
{
	return _crc32Value != 0 && _crc32Value != NSNotFound;
}

- (BOOL)is7zCompress
{
	return [_rawSavePath endWith:@".7z"];
}

- (BOOL)isZipCompress
{
	return [_rawSavePath endWith:@".zip"] || [_rawSavePath endWith:@".zipx"] || [_rawSavePath endWith:@".z"];
}

- (BOOL)isRarCompress
{
	return [_rawSavePath endWith:@".rar"];
}

- (BOOL)isCompress
{
	return self.is7zCompress || self.isZipCompress || self.isRarCompress;
}

- (NSString *)cachePath
{
	if (self.isCompress) {
		return [self.rawSavePath stringByDeletingPathExtension];
	}

	return self.rawSavePath;
}

- (BOOL)isFileNeedReDownload
{
	BOOL	isFile	= ![OFFileManager isDirectoryItemAtPath:self.cachePath];
	BOOL	isExist = [OFFileManager existsItemAtPath:self.cachePath];

	if (isExist && isFile) {
		NSData *data = [NSData dataWithContentsOfFile:self.cachePath];

		if (self.isMd5Check) {
			if ([self.md5.lowercaseString isEqualToString:data.MD5HexDigest.lowercaseString]) {
				return NO;
			}
            NSLog(@"NeedReDownload file not exist:md5new:%@ md5local:%@ \n%@ %@",self.md5,data.MD5HexDigest,self.rawSavePath,self.url);
		} else if (self.isCrcCheck) {
			if (self.crc32Value == [data crc32Value]) {
				return NO;
			}
		}
	}
    NSLog(@"NeedReDownload file not exist:%@ %@",self.rawSavePath,self.url);
	return YES;
}

- (NSString *)description
{
	NSMutableString *s = [NSMutableString stringWithString:[super description]];

	[s appendString:@"\n"];
	[s appendFormat:@"url:%@\n", _url];
	[s appendFormat:@"rawSavePath:%@\n", _rawSavePath];
	[s appendFormat:@"relativePath:%@\n", _relativePath];
	[s appendFormat:@"compressSuffix:%@\n", _compressSuffix];
	[s appendFormat:@"md5:%@\n", _md5];
	[s appendFormat:@"crc32Value:%ld\n", _crc32Value];
	[s appendFormat:@"errorTip:%@", _errorTip];
	return s;
}

@end

@interface FileUpdater ()
{
	BOOL		canceled;
	NSInteger	curStep;
}

@property (nonatomic, strong) NSMutableArray	*files;
@property (nonatomic, strong) NSMutableArray	*errorItems;

@property (nonatomic, strong) ASINetworkQueue *downloadQueue;

@end

@implementation FileUpdater

- (void)addItemWithUrl:(NSURL *)url rawSavePath:(NSString *)path relativePath:(NSString *)relativePath compress:(NSString *)suffix md5:(NSString *)md5 crc32:(unsigned long)crc
{
	if (!_files) {
		self.files = [NSMutableArray array];
	}

	FileItemInfo *info = [[FileItemInfo alloc]init];
	info.url			= url;
	info.rawSavePath	= path;
	info.relativePath	= relativePath;
	info.compressSuffix = suffix;
	info.md5			= md5;
	info.crc32Value		= crc;

	[_files addObject:info];
}

- (NSUInteger)itemCount
{
	return _files.count;
}

- (void)start
{
	weakObj(self);
	[self performBlockInBackground:^{
		[bself startUpdate];
	}];
}

- (void)cancel
{
	canceled = YES;
    self.downloadQueue.delegate = nil;
	[self.downloadQueue cancelAllOperations];

	curStep = 0;
	[self onUpdateCompleted:errorCanceled];
}

- (void)startUpdate
{
	self.errorItems = [NSMutableArray array];

	self.downloadQueue = [[ASINetworkQueue alloc]init];
	self.downloadQueue.shouldCancelAllRequestsOnFailure = NO;
	self.downloadQueue.maxConcurrentOperationCount		= APP_DELEGATE.maxConcurrentDownloadCount;
	self.downloadQueue.delegate = self;
	self.downloadQueue.requestDidStartSelector	= @selector(requestDidStart:);
	self.downloadQueue.requestDidFinishSelector = @selector(requestDidFinish:);
	self.downloadQueue.requestDidFailSelector	= @selector(requestDidFail:);
	[self.downloadQueue go];

	weakObj(self);

	for (FileItemInfo *item in self.files) {
		if (canceled) {
			break;
		}

		if (item.isFileNeedReDownload) {
			//下载
			[OFFileManager removeItemAtPath:item.rawSavePath];
			ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:item.url];
			[OFFileManager createDirectoriesForFileAtPath:item.rawSavePath];
			[request setDownloadDestinationPath:item.rawSavePath];
            [request setNumberOfTimesToRetryOnTimeout:2];
			request.userInfo = @{@"data":item};
			[self.downloadQueue addOperation:request];
		} else {
			[self onMainThreadOperationFinish:item operation:OperationDownload success:YES];
		}
	}
}

- (void)unCompressItemInBackground:(FileItemInfo *)item
{
	if ([NSThread isMainThread]) {
		weakObj(self);
		weakObj(item);
		[self performBlockInBackground:^{
			[bself unCompressItem:bitem];
		}];
	} else {
		[self unCompressItem:item];
	}
}

- (void)unCompressItem:(FileItemInfo *)item
{
	[self onMainThreadOperationStart:item operation:OperationUncompress];

	BOOL		success		= NO;
	NSString	*entry		= item.relativePath.lastPathComponent;
	NSString	*outPath	= [[AppDelegate addonsPath] stringByAppendingPathComponent:item.relativePath];
	[OFFileManager removeItemAtPath:outPath];

	if (!item.isFileNeedReDownload) {
		// 缓存的 或者不需要解压的 直接移动
		success = [OFFileManager copyItemAtPath:item.cachePath toPath:outPath];
    }else{
        if(!item.isCompress){
            //不需要解压的
            success = [OFFileManager copyItemAtPath:item.rawSavePath toPath:outPath];
        }else {
            // 重新下载的 解压后再移动
            if (item.is7zCompress) {
                [OFFileManager createDirectoriesForFileAtPath:item.cachePath];
                success = [LZMAExtractor extractArchiveEntry:item.rawSavePath archiveEntry:entry outPath:item.cachePath];
                
                NSLog(@"=====7z解压====%d   %@   %@",success,item.rawSavePath,item.cachePath);
                if (success) {
                    [OFFileManager createDirectoriesForFileAtPath:outPath];
                    success = [OFFileManager copyItemAtPath:item.cachePath toPath:outPath];
                }
                
                NSLog(@"======移动====%d",success);
                if(!success){
                    NSLog(@"==失败==%@",item.url);
                }
            } else if (item.isZipCompress) {
                NSError		*error		= nil;
                ZZArchive	*archive	= [ZZArchive archiveWithURL:[NSURL fileURLWithPath:item.rawSavePath] error:&error];
                
                if (!error) {
                    ZZArchiveEntry	*entry	= archive.entries[0];
                    NSData			*data	= [entry newDataWithError:&error];
                    
                    if (!error) {
                        success = [data writeToFile:item.cachePath atomically:YES];
                        
                        if (success) {
                            [OFFileManager createDirectoriesForFileAtPath:outPath];
                            success = [OFFileManager copyItemAtPath:item.cachePath toPath:outPath];
                        }
                    }
                }else{
                    NSLog(@"===zip解压失败===%@",error);
                }
            }
        }
    }

	[OFFileManager removeItemAtPath:item.rawSavePath];

	if (!success) {
		item.errorTip = @"文件解压失败！";
		[self.errorItems addObject:item];
	}

	[self onMainThreadOperationFinish:item operation:OperationUncompress success:success];
}

#pragma asi selectors
- (void)requestDidStart:(ASIHTTPRequest *)request
{
	FileItemInfo *item = request.userInfo[@"data"];

	[self onMainThreadOperationStart:item operation:OperationDownload];
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
	FileItemInfo *item = request.userInfo[@"data"];

	[self onMainThreadOperationFinish:item operation:OperationDownload success:YES];
}

- (void)requestDidFail:(ASIHTTPRequest *)request
{
	FileItemInfo *item = request.userInfo[@"data"];
    NSLog(@"downloadFailed %@",item.url);
	[self onMainThreadOperationFinish:item operation:OperationDownload success:NO];
}

#pragma mark - progress

- (double)progressValue
{
	return (float)curStep / (self.itemCount * 2) * 100.f;
}

- (void)onMainThreadOperationStart:(FileItemInfo *)item operation:(UpdateOperationType)type
{
	if ([NSThread isMainThread]) {
		[self onOperationStart:item operation:type];
	} else {
		weakObj(self);
		weakObj(item);
		[self performBlockOnMainThread:^{
			[bself onOperationStart:bitem operation:type];
		}];
	}
}

- (void)onOperationStart:(FileItemInfo *)item operation:(UpdateOperationType)type
{
	if (canceled) {
		return;
	}

	// NSLog(@"=======1======%d", [NSThread isMainThread]);

	if (self.updateFileBlock) {
		self.updateFileBlock(self, item, type);
	}
}

- (void)onMainThreadOperationFinish:(FileItemInfo *)item operation:(UpdateOperationType)type success:(BOOL)success
{
	if ([NSThread isMainThread]) {
		[self onOperationFinish:item operation:type success:success];
	} else {
		weakObj(self);
		weakObj(item);
		[self performBlockOnMainThread:^{
			[bself onOperationFinish:bitem operation:type success:success];
		}];
	}
}

- (void)onOperationFinish:(FileItemInfo *)item operation:(UpdateOperationType)type success:(BOOL)success
{
	// NSLog(@"========2=====%d", [NSThread isMainThread]);

	if (canceled) {
		return;
	}

	if (type == OperationDownload) {
		if (success) {
			curStep += 1;
			[self unCompressItemInBackground:item];
		} else {
			curStep			+= 2;
			item.errorTip	= @"文件下载失败!";
			[self.errorItems addObject:item];
		}
	} else if (type == OperationUncompress) {
		if (!success) {
			item.errorTip = @"文件解压失败！";
			[self.errorItems addObject:item];
		}

		curStep += 1;
	}

	// 判断
	if (curStep >= self.itemCount * 2) {
		NSError *error = nil;

		if (self.errorItems.count > 0) {
			NSMutableString *msg = [[NSMutableString alloc]initWithString:@""];
			[msg appendString:@"更新中遇到以下错误:\n"];

			for (FileItemInfo *item in self.errorItems) {
				[msg appendFormat:@"%@ %@ \n", item.relativePath, item.errorTip];
			}

			error = [NSError errorWithDomain:msg code:-200 userInfo:nil];
		}

		[self onUpdateCompleted:error];
	}
}

- (void)onUpdateCompleted:(NSError *)error
{
	// NSLog(@"========3=====%d", [NSThread isMainThread]);

	if (self.updateCompletedBlock) {
		self.updateCompletedBlock(self, error, self.errorItems);
	}
}

@end

