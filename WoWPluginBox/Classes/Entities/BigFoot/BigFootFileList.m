//
//  BigFootFileList.m
//  HuangShixin
//
//  Created by HuangShixin on 14-10-31.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "BigFootFileList.h"

JSONKeyMapper *mapper()
{
	return [[JSONKeyMapper alloc]initWithJSONToModelBlock:^NSString *(NSString *keyName) {
			   return [keyName stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
		   } modelToJSONBlock:^NSString *(NSString *keyName) {
			   return [keyName stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
		   }];
}

@implementation BigFootFileList
@synthesize allPluginDirs = _allPluginDirs;

+ (JSONKeyMapper *)keyMapper
{
	return mapper();
}

- (NSArray *)allPluginDirs
{
    if(!_allPluginDirs){
        NSMutableArray *temp = [NSMutableArray array];
        for (BigFootFileList_AddOnItem *item in self.AddOn) {
            [temp addObject:item.name];
        }
        _allPluginDirs = [NSArray arrayWithArray:temp];
    }
    return _allPluginDirs;
}

@end

@implementation BigFootFileList_AddOnItem
+ (JSONKeyMapper *)keyMapper
{
	return mapper();
}

- (NSString *)toString
{
    return strFormat(@"%@ \t 作者：%@\n依赖：%@\t修订：%@\t按需加载：%@\n描述：%@", self.Title_zhCN, self.Author?:@"未知",self.Dependencies?:@"无",self.X_Revision,[self.LoadOnDemand intValue]==1?@"是":@"否",self.Notes_zhCN);
}

- (NSString *)des{
    NSMutableString *des = [NSMutableString stringWithString:@""];
    
    if (self.name) {
        [des appendFormat:@"%@\n", self.name];
    }
    
    if (self.Dependencies) {
        [des appendFormat:@"依赖%@\t", self.Dependencies];
    }
    
    if (self.X_Revision) {
        [des appendFormat:@"%@修订\t", self.X_Revision];
    }
    
    [des appendString:[self.LoadOnDemand integerValue] == 1 ? @"可按需加载\n":@"必须加载\n"];
    
    if(self.Notes_zhCN){
        [des appendString:self.Notes_zhCN];
    }
    return des;
}

- (float)heightForCell
{
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 473, 1000)];
    
    textField.font			= [NSFont systemFontOfSize:13];
    [textField.cell setLineBreakMode:NSLineBreakByWordWrapping];
    textField.stringValue = self.des;
    NSSize size = [textField.cell cellSizeForBounds:textField.frame];
    
    float height = 26 + size.height + 4;
    return height;
}

@end

@implementation BigFootFileList_FileItem
+ (JSONKeyMapper *)keyMapper
{
	return mapper();
}

- (NSString *)path
{
    return [_path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
}

@end

