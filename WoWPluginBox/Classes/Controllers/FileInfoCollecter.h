//
//  FileInfoCollecter.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileAttributes : NSObject

@property (nonatomic, copy) NSString			*path;
@property (nonatomic, readonly) unsigned long	crcValue;
@property (nonatomic, readonly) NSString		*md5Value;
@property (nonatomic, readonly) BOOL			isDirectory;
@property (nonatomic, readonly) BOOL			isExist;

- (id)initWithPath:(NSString *)path;
- (BOOL)isCrcValue:(unsigned long)value;
- (BOOL)isMd5Value:(NSString *)value;
@end

//
@class FileInfoCollecter;
typedef void (^ CollectFileAttributes)(FileInfoCollecter *collecter, FileAttributes *attr, NSUInteger curIndex);
typedef void (^ CollectComplete)(FileInfoCollecter *collecter);
typedef void (^ CollectFailed)(FileInfoCollecter *collecter, NSError *error);
@interface FileInfoCollecter : NSObject

@property (nonatomic, copy) CollectFileAttributes	collectBlock;
@property (nonatomic, copy) CollectComplete			completeBlock;
@property (nonatomic, copy) CollectFailed			failedBlock;

- (void)setCollectBlock:(CollectFileAttributes)collectBlock;
- (void)setCompleteBlock:(CollectComplete)completeBlock;
- (void)setFailedBlock:(CollectFailed)failedBlock;

- (id)initWithDirectory:(NSString *)path;
- (NSUInteger)itemCount;
- (BOOL)start;
- (NSDictionary *)collections;
@end

