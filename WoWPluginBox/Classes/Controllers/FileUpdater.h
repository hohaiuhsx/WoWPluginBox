//
//  FileUpdater.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-17.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASIHTTPRequest.h>

@interface FileItemInfo : NSObject
@property (nonatomic, copy) NSURL			*url;
@property (nonatomic, copy) NSString		*rawSavePath;
@property (nonatomic, copy) NSString		*relativePath;
@property (nonatomic, copy) NSString		*compressSuffix;
@property (nonatomic, copy) NSString		*md5;
@property (nonatomic, assign) unsigned long crc32Value;
@property (nonatomic, copy) NSString		*errorTip;

- (NSString *)cachePath;
- (BOOL)isMd5Check;
- (BOOL)isCrcCheck;
- (BOOL)isFileNeedReDownload;
- (BOOL)is7zCompress;
- (BOOL)isZipCompress;
- (BOOL)isRarCompress;
- (BOOL) isCompress;
@end

@class FileUpdater;
typedef enum {
	OperationDownload,
	OperationUncompress
} UpdateOperationType;

typedef void (^ UpdateFile)(FileUpdater *updater, FileItemInfo *info, UpdateOperationType type);
typedef void (^ UpdateCompleted)(FileUpdater *updater, NSError *error, NSArray *errorItems);

@interface FileUpdater : NSObject

@property (nonatomic, copy) UpdateFile		updateFileBlock;
@property (nonatomic, copy) UpdateCompleted updateCompletedBlock;
@property (nonatomic, assign) double progressValue;

- (void)setUpdateFileBlock:(UpdateFile)updateFileBlock;
- (void)setUpdateCompletedBlock:(UpdateCompleted)updateCompletedBlock;

- (void)addItemWithUrl:(NSURL *)url rawSavePath:(NSString *)path relativePath:(NSString *)relativePath compress:(NSString *)suffix md5:(NSString *)md5 crc32:(unsigned long)crc;
- (NSUInteger)itemCount;
- (void)start;
- (void)cancel;

@end

