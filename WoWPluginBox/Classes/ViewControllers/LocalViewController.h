//
//  LocalViewController.h
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "BaseViewController.h"
@class LocalPlugin;
@interface LocalViewController : BaseViewController

- (void)onItemCheckChange:(LocalPlugin *)item;
- (void)onUninstallItem:(LocalPlugin *)item;
@end

@interface LocalPlugin : NSObject;
@property (nonatomic, copy) NSString				*name;
@property(nonatomic, assign) BOOL					checked;
@property (nonatomic, assign) LocalViewController	*controller;
@end

