//
//  MoGuPluginList.m
//  HuangShixin
//
//  Created by HuangShixin on 14-11-3.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "MoGuPluginList.h"

@implementation MoGuPluginList

@end


@implementation MoGuPluginList_PItem
- (NSString *)toString
{
    return strFormat(@"%@(v%@)",self.Name,self.Ver);
}
@end


