//
//  FileInfoCollecter.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "FileInfoCollecter.h"
#import "OFFileManager.h"

@implementation FileAttributes

- (id)initWithPath:(NSString *)path
{
	if (self = [super init]) {
		self.path = path;
	}

	return self;
}

- (void)setPath:(NSString *)path
{
	if ([_path isEqualToString:path]) {
		return;
	}

	_path			= path;
	_isExist		= NO;
	_isDirectory	= NO;
	_crcValue		= 0;
	_md5Value		= nil;

	if (![NSString isStringEmptyOrBlank:_path]) {
		_isExist = [OFFileManager existsItemAtPath:path];

		if (_isExist) {
			_isDirectory = [OFFileManager isDirectoryItemAtPath:path];

			if (!_isDirectory) {
				NSData *data = [NSData dataWithContentsOfFile:path];
				_crcValue	= [data crc32Value];
				_md5Value	= [data MD5HexDigest];
			}
		}
	}
}

- (BOOL)isCrcValue:(unsigned long)value
{
	return _crcValue == value;
}

- (BOOL)isMd5Value:(NSString *)value
{
	return [_md5Value.lowercaseString isEqualToString:value.lowercaseString];
}

- (NSString *)description
{
	NSString *s = [super description];

	return strFormat(@"%@  \npath:%@\ncrc32:%ld\nmd5:%@", s, _path, _crcValue, _md5Value);
}

@end

@interface FileInfoCollecter ()
@property (nonatomic, strong) NSArray				*subItems;
@property (nonatomic, copy) NSString				*dirPath;
@property (nonatomic, strong) NSMutableDictionary	*results;
@end

@implementation FileInfoCollecter

- (id)initWithDirectory:(NSString *)path
{
	if (self = [super init]) {
		self.dirPath = path;
	}

	return self;
}

- (NSUInteger)itemCount
{
	return self.subItems.count;
}

- (BOOL)start
{
	__block NSFileManager	*fileManager	= [NSFileManager defaultManager];
	BOOL					isDir			= NO;
	BOOL					isExist			= [fileManager fileExistsAtPath:_dirPath isDirectory:&isDir];

	if (isExist && isDir) {
		weakObj(self);
		[self performBlockInBackground:^{
			bself.subItems = [fileManager subpathsOfDirectoryAtPath:bself.dirPath error:nil];
			bself.results = [NSMutableDictionary dictionaryWithCapacity:bself.subItems.count];

			for (int i = 0; i < bself.subItems.count; i++) {
				NSString *path = bself.subItems[i];
				FileAttributes *attr = [[FileAttributes alloc]initWithPath:[bself.dirPath stringByAppendingPathComponent:path]];
				[bself.results setValue:attr forKey:path];

				[self onMainThreadCollect:attr index:i];
			}

			[self onMainThreadCompleted];
		}];
		return YES;
	}

	[self onMainThreadFailed];

	return NO;
}

- (NSDictionary *)collections
{
	return _results;
}

- (void)onMainThreadCollect:(FileAttributes *)attr index:(NSUInteger)index
{
	if (self.collectBlock) {
		if ([NSThread isMainThread]) {
			self.collectBlock(self, attr, index);
		} else {
			weakObj(self);
			weakObj(attr);
			[self performBlockOnMainThread:^{
				bself.collectBlock(bself, battr, index);
			}];
		}
	}
}

- (void)onMainThreadCompleted
{
	if (self.completeBlock) {
		if ([NSThread isMainThread]) {
			self.completeBlock(self);
		} else {
			weakObj(self);
			[self performBlockOnMainThread:^{
				bself.completeBlock(bself);
			}];
		}
	}
}

- (void)onMainThreadFailed
{
	if (self.failedBlock) {
		NSError *error = [NSError errorWithDomain:@"无法找到指定的文件夹" code:100 userInfo:@{@"path":self.dirPath}];

		if ([NSThread isMainThread]) {
			self.failedBlock(self, error);
		} else {
			weakObj(self);
			weakObj(error);
			[self performBlockOnMainThread:^{
				bself.failedBlock(bself, berror);
			}];
		}
	}
}

@end

