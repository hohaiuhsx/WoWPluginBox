//
//  PluginCrcList.h
//  HuangShixin
//
//  Created by HuangShixin on 14-10-20.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "BaseJSONModel.h"

@class PluginCrcList_Crc32Item;
@class PluginCrcList_FilesItem;

@protocol PluginCrcList_Crc32Item @end
@protocol PluginCrcList_FilesItem @end

@interface PluginCrcList : BaseJSONModel


/**
 *  PluginCrcList_Crc32Item
 */
@property (nonatomic,strong) NSArray<PluginCrcList_Crc32Item> *Crc32;

@end

@interface PluginCrcList_Crc32Item : BaseJSONModel

@property (nonatomic,copy) NSString *folder;

/**
 *  PluginCrcList_FilesItem
 */
@property (nonatomic,strong) NSArray<PluginCrcList_FilesItem> *files;

@end

@interface PluginCrcList_FilesItem : BaseJSONModel

@property (nonatomic,copy) NSString *file;
@property (nonatomic,strong) NSNumber *CrcVal;

@end

