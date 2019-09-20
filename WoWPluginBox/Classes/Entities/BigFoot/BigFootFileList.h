//
//  BigFootFileList.h
//  HuangShixin
//
//  Created by HuangShixin on 14-10-31.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "BaseJSONModel.h"

@class BigFootFileList_AddOnItem;
@class BigFootFileList_FileItem;

@protocol BigFootFileList_AddOnItem @end
@protocol BigFootFileList_FileItem @end

@interface BigFootFileList : BaseJSONModel

@property (nonatomic,readonly) NSArray *allPluginDirs;


/**
 *  BigFootFileList_AddOnItem
 */
@property (nonatomic,strong) NSArray<BigFootFileList_AddOnItem> *AddOn;
@property (nonatomic,copy) NSString *version;

@end

@interface BigFootFileList_AddOnItem : BaseJSONModel

@property (nonatomic,copy) NSString *Notes;
@property (nonatomic,copy) NSString *Title_zhCN;
@property (nonatomic,copy) NSString *Title_zhTW;
@property (nonatomic,copy) NSString *name;

- (NSString *)toString;
- (NSString *)des;
- (float)heightForCell;

/**
 *  BigFootFileList_FileItem
 */
@property (nonatomic,strong) NSArray<BigFootFileList_FileItem> *File;
@property (nonatomic,copy) NSString *Author;
@property (nonatomic,copy) NSString *Notes_zhTW;
@property (nonatomic,copy) NSString *X_Revision;
@property (nonatomic,copy) NSString *Dependencies;
@property (nonatomic,copy) NSString *Notes_zhCN;
@property (nonatomic,copy) NSString *Title;
@property (nonatomic,copy) NSString *LoadOnDemand;

@end

@interface BigFootFileList_FileItem : BaseJSONModel

@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *checksum;

@end

