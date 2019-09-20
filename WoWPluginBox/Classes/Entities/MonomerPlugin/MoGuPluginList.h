//
//  MoGuPluginList.h
//  HuangShixin
//
//  Created by HuangShixin on 14-11-3.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "BaseJSONModel.h"

@class MoGuPluginList_PItem;

@protocol MoGuPluginList_PItem @end

@interface MoGuPluginList : BaseJSONModel

@property (nonatomic,copy) NSString *DownLoadUrl;

/**
 *  MoGuPluginList_PItem
 */
@property (nonatomic,strong) NSArray<MoGuPluginList_PItem> *P;
@property (nonatomic,copy) NSString *ver;

@end

@interface MoGuPluginList_PItem : BaseJSONModel

@property (nonatomic,copy) NSString *Name;
@property (nonatomic,copy) NSString *Ver;
@property (nonatomic,copy) NSString *Folder;
@property (nonatomic,copy) NSString *Url;
@property (nonatomic,copy) NSString *Id;

@property (nonatomic,assign) BOOL installed;

- (NSString *)toString;

@end

