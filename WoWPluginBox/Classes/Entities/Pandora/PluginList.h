//
//  PluginList.h
//  HuangShixin
//
//  Created by HuangShixin on 14-10-20.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "BaseJSONModel.h"

@class PluginList_PluginsItem;
@class PluginList_PluginitemsItem;

@protocol PluginList_PluginsItem @end
@protocol PluginList_PluginitemsItem @end

@interface PluginList : BaseJSONModel

- (id)initWithDictionary:(NSDictionary *)dict;


/**
 *  PluginList_PluginsItem
 */
@property (nonatomic,strong) NSArray<PluginList_PluginsItem> *plugins;

@property (nonatomic,strong) NSArray *allPluginDirs;

@end

@interface PluginList_PluginsItem : BaseJSONModel


/**
 *  PluginList_PluginitemsItem
 */
@property (nonatomic,strong) NSArray<PluginList_PluginitemsItem> *pluginitems;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *icon;

@end

@interface PluginList_PluginitemsItem : BaseJSONModel

@property (nonatomic,copy) NSString *author;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *descript;
@property (nonatomic,copy) NSString *foldername;

- (NSString *)toString;
- (NSAttributedString *)attributedDescript;
- (float)heightForCell;

@end

