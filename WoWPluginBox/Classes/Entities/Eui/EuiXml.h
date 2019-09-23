//
//  EuiXml.h
//  HuangShixin
//
//  Created by HuangShixin on 14-11-7.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "BaseJSONModel.h"

@class EuiXml_Status;
@class EuiXml_AddOns;
@class EuiXml_App;
@class EuiXml_ClassAddOns;
@class EuiXml_OtherAddOns;
@class EuiXml_AAItem;
@class EuiXml_Module;
@class EuiXml_AItem;
@class EuiXml_Server;

@protocol EuiXml_AItem @end
@protocol EuiXml_AAItem @end

@interface EuiXml : BaseJSONModel

@property (nonatomic,strong) EuiXml_Status *Status;
@property (nonatomic,strong) EuiXml_AddOns *AddOns;
@property (nonatomic,strong) EuiXml_App *App;
@property (nonatomic,strong) EuiXml_ClassAddOns *ClassAddOns;
@property (nonatomic,strong) EuiXml_OtherAddOns *OtherAddOns;
@property (nonatomic,strong) EuiXml_Module *Module;
@property (nonatomic,strong) EuiXml_Server *Server;

@end

@interface EuiXml_Status : BaseJSONModel

@property (nonatomic,copy) NSString *lock;
@property (nonatomic,copy) NSString *warning;

@end

@interface EuiXml_AddOns : BaseJSONModel

@property (nonatomic,copy) NSString *ptrUrl;
@property (nonatomic,copy) NSString *normalUrl;
@property (nonatomic,copy) NSString *fontUrl;
@property (nonatomic,copy) NSString *betaUrl;
@property (nonatomic,copy) NSString *devUrl;
@property (nonatomic,copy) NSString *gfUrl;
@property (nonatomic,copy) NSString *tfUrl;

- (NSString *)addOnsUrl:(NSUInteger)index;

@end

@interface EuiXml_App : BaseJSONModel

@property (nonatomic,copy) NSString *ver5;
@property (nonatomic,copy) NSString *ver6;
@property (nonatomic,copy) NSString *ver3;
@property (nonatomic,copy) NSString *md5;
@property (nonatomic,copy) NSString *ver;
@property (nonatomic,copy) NSString *url;

@end

@interface EuiXml_OtherAddOns : BaseJSONModel


/**
 *  EuiXml_AItem
 */
@property (nonatomic,strong) NSArray<EuiXml_AItem> *A;

@end

@interface EuiXml_ClassAddOns : BaseJSONModel

@property (nonatomic,strong) NSArray<EuiXml_AItem> *A;

@end

@interface EuiXml_AItem : BaseJSONModel

@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *toc;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *ver;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *dirlist;
@property (nonatomic,copy) NSString *localVer;
@property (nonatomic,assign) BOOL installed;
@property (nonatomic,assign) BOOL checked;
@property (nonatomic,readonly) BOOL hasUpdate;

- (NSString *)toString;
- (float)heightForCell;
@end

@interface EuiXml_Module : BaseJSONModel


/**
 *  EuiXml_AItem
 */
@property (nonatomic,strong) NSArray<EuiXml_AAItem> *A;

@end

@interface EuiXml_AAItem : BaseJSONModel

@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *filelist;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *imgurl;

- (NSString *)toString;
- (float)heightForCell;
@end

@interface EuiXml_Server : BaseJSONModel

@property (nonatomic,copy) NSString *s2;
@property (nonatomic,copy) NSString *s1;
@property (nonatomic,copy) NSString *s3;
@property (nonatomic,copy) NSString *s4;

- (NSString *)server:(NSUInteger )index;

@end

