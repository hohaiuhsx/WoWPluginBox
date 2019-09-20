//
//  EuiFileList.m
//  HuangShixin
//
//  Created by HuangShixin on 14-11-12.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "EuiFileList.h"

@implementation EuiFileList

@end


@implementation EuiFileList_DeleteFileItem

@end


@implementation EuiFileList_FileItem

- (NSString *)Url
{
    return [_Url stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
}
@end


