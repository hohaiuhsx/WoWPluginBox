//
//  AddonsUpdater.h
//  HuangShixin
//
//  Created by HuangShixin on 14-10-20.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "BaseJSONModel.h"


@interface AddonsUpdater : BaseJSONModel

@property (nonatomic,copy) NSString *plughttpaddr;
@property (nonatomic,copy) NSString *plugjsonaddr;
@property (nonatomic,assign) unsigned long crc32;
@property (nonatomic,copy) NSString *pluglistjsonaddr_TW;
@property (nonatomic,assign) int mainIndex;
@property (nonatomic,assign) int modifypatch;
@property (nonatomic,assign) int updatenum;
@property (nonatomic,copy) NSString *plughttpaddr_TW;
@property (nonatomic,assign) unsigned long pluglistcrc;
@property (nonatomic,assign) int inneryyopen;
@property (nonatomic,copy) NSString *ver;
@property (nonatomic,assign) unsigned long plugcrc;
@property (nonatomic,assign) unsigned long crc32_TW;
@property (nonatomic,assign) int modifywowfhx;
@property (nonatomic,assign) unsigned long plugcrc_TW;
@property (nonatomic,assign) int hellotipopen;
@property (nonatomic,assign) int bbsIndex;
@property (nonatomic,copy) NSString *pluglistjsonaddr;
@property (nonatomic,copy) NSString *plugjsonaddr_TW;
@property (nonatomic,assign) int modifywow;
@property (nonatomic,assign) int enforce;
@property (nonatomic,assign) unsigned long pluglistcrc_TW;
@property (nonatomic,copy) NSString *httpaddr;

@end

