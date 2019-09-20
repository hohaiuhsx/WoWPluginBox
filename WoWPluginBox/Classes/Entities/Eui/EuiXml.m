//
//  EuiXml.m
//  HuangShixin
//
//  Created by HuangShixin on 14-11-7.
//  Copyright HuangShixin 2014年. All rights reserved.
//

#import "EuiXml.h"

@implementation EuiXml

@end

@implementation EuiXml_Status

@end

@implementation EuiXml_AddOns
- (NSString *)addOnsUrl:(NSUInteger)index
{
	switch (index) {
		case 0:
			return self.devUrl;

			break;

		case 1:
			return self.normalUrl;

		case 2:
			return self.ptrUrl;

		case 3:
			return self.betaUrl;

		default:
			return self.gfUrl;
	}
}

@end

@implementation EuiXml_App

@end

@implementation EuiXml_OtherAddOns

@end

@implementation EuiXml_AItem

- (NSString *)toString
{
	return strFormat(@"%@\t%@\n%@", self.name, self.ver, self.desc);
}

- (float)heightForCell
{
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 473, 1000)];
    
    textField.font			= [NSFont systemFontOfSize:13];
    [textField.cell setLineBreakMode:NSLineBreakByWordWrapping];
    textField.stringValue = self.desc;
    NSSize size = [textField.cell cellSizeForBounds:textField.frame];
    
    float height = 26 + size.height + 4;
    return height;
}

- (BOOL)hasUpdate
{
    return !(self.installed && [self.ver isEqualToString:self.localVer]);
}

@end

@implementation EuiXml_Module

@end

@implementation EuiXml_AAItem
- (NSString *)toString
{
	return strFormat(@"%@\n%@", self.name, self.desc);
}

- (float)heightForCell
{
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 473, 1000)];
    
    textField.font			= [NSFont systemFontOfSize:13];
    [textField.cell setLineBreakMode:NSLineBreakByWordWrapping];
    textField.stringValue = self.desc;
    NSSize size = [textField.cell cellSizeForBounds:textField.frame];
    
    float height = 26 + size.height + 4;
    return height;
}

@end

@implementation EuiXml_Server
- (NSString *)server:(NSUInteger)index
{
	switch (index) {
		case 0:
			return self.s1;

			break;

		case 1:
			return self.s2;

		case 2:
			return self.s3;

		case 3:
			return self.s4;

		default:
			return nil;
	}
}

@end

