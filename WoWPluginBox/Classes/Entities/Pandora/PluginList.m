//
//  PluginList.m
//  HuangShixin
//
//  Created by HuangShixin on 14-10-20.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "PluginList.h"

@implementation PluginList

- (id)initWithDictionary:(NSDictionary *)dict
{
	if (self = [self initWithDictionary:dict error:nil]) {
		PluginList_PluginsItem *item = [[PluginList_PluginsItem alloc]init];
		item.name	= @"全部插件";
		item.icon	= @"c_0";
		NSMutableArray	*array	= [NSMutableArray array];
		NSMutableArray	*dirs	= [NSMutableArray array];

		NSInteger index = 1;

		for (PluginList_PluginsItem *i in self.plugins) {
			[array addObjectsFromArray:i.pluginitems];

			for (PluginList_PluginitemsItem *p in i.pluginitems) {
				[dirs addObject:p.foldername];
			}

			i.icon = strFormat(@"c_%ld", index % 10);

			index++;
		}

		item.pluginitems = (NSArray <PluginList_PluginitemsItem> *)array;

		NSMutableArray *temp = [NSMutableArray array];
		[temp addObject:item];
		[temp addObjectsFromArray:self.plugins];
		self.plugins		= (NSArray <PluginList_PluginsItem> *)temp;
		self.allPluginDirs	= dirs;
	}

	return self;
}

@end

@implementation PluginList_PluginsItem

@end

@implementation PluginList_PluginitemsItem

- (NSString *)toString
{
	return strFormat(@"名称:%@\t目录:%@\n作者:%@\n描述:%@", self.name, self.foldername, self.author, self.descript);
}

- (NSAttributedString *)attributedDescript
{
    NSString *des = self.descript;
    des = [des stringByReplacingOccurrencesOfString:@"|C" withString:@"|c"];
    des = [des stringByReplacingOccurrencesOfString:@"|R" withString:@"|r"];
    des = [des stringByReplacingOccurrencesOfString:@"|N" withString:@"|n"];
    des = [des stringByReplacingOccurrencesOfString:@"|r" withString:@"\r"];
    des = [des stringByReplacingOccurrencesOfString:@"|n" withString:@"\n"];

	NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:des];

	[str addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, des.length)];
	BOOL complete = NO;

	while (!complete) {
		NSRange range = [str.string rangeOfString:@"|c"];

		if (range.location == NSNotFound) {
			complete = YES;
		} else {
			NSString *colorStr = [str.string substringWithRange:NSMakeRange(range.location + range.length, 8)];
			colorStr = [NSString stringWithFormat:@"0x%@", colorStr];
			NSColor *color = NSColorFromString(colorStr);

			[str deleteCharactersInRange:NSMakeRange(range.location, range.length + 8)];
			NSRange r = NSMakeRange(range.location, str.length - range.location);
			[str addAttribute:NSForegroundColorAttributeName value:color range:r];
            [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:13] range:r];
			[str fixAttributesInRange:r];
		}
	}

	return str;
}

- (float)heightForCell
{
	NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 473, 1000)];

	textField.font			= [NSFont systemFontOfSize:13];
    [textField.cell setLineBreakMode:NSLineBreakByWordWrapping];
	textField.attributedStringValue = self.attributedDescript;
	NSSize size = [textField.cell cellSizeForBounds:textField.frame];

    float height = 26 + size.height + 4;
	return height;
}

@end

