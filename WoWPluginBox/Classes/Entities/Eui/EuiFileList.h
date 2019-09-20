//
//  EuiFileList.h
//  HuangShixin
//
//  Created by HuangShixin on 14-11-12.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "BaseJSONModel.h"

@class EuiFileList_DeleteFileItem;
@class EuiFileList_FileItem;

@protocol EuiFileList_DeleteFileItem @end
@protocol EuiFileList_FileItem @end

@interface EuiFileList : BaseJSONModel


/**
 *  EuiFileList_DeleteFileItem
 */
@property (nonatomic,strong) NSArray<EuiFileList_DeleteFileItem> *DeleteFile;
@property (nonatomic,copy) NSString *Ver;

/**
 *  EuiFileList_FileItem
 */
@property (nonatomic,strong) NSArray<EuiFileList_FileItem> *File;

@end

@interface EuiFileList_DeleteFileItem : BaseJSONModel

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *type;

@end

@interface EuiFileList_FileItem : BaseJSONModel

@property (nonatomic,copy) NSString *Md5;
@property (nonatomic,copy) NSString *Url;

@end

