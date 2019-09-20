//
//  PluginCrcList.m
//  HuangShixin
//
//  Created by HuangShixin on 14-10-20.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "PluginCrcList.h"

@implementation PluginCrcList

@end


@implementation PluginCrcList_Crc32Item

@end


@implementation PluginCrcList_FilesItem

- (NSString *)file
{
    return [_file stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
}
@end


