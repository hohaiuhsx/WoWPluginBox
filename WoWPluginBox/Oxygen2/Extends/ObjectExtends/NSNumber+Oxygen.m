//
//  NSNumber+Oxygen.m
//  Oxygen
//
//  Created by 黄 时欣 on 13-6-7.
//  Copyright (c) 2013年 zhang cheng. All rights reserved.
//

#import "NSNumber+Oxygen.h"

@implementation NSNumber (Oxygen)

- (NSString *)intString
{
	return [NSString stringWithFormat:@"%d", self.intValue];
}

- (NSString *)floatString
{
	return [NSString stringWithFormat:@"%f", self.floatValue];
}

- (NSString *)doubleString
{
	return [NSString stringWithFormat:@"%f", self.doubleValue];
}

- (NSString *)floatStringWithFormat:(NSString *)format
{
	return [NSString stringWithFormat:format, self.floatValue];
}

- (NSString *)doubleStringWithFormat:(NSString *)format
{
	return [NSString stringWithFormat:format, self.doubleValue];
}

- (NSNumber *)addInt:(NSInteger)i
{
	return [NSNumber numberWithInteger:self.intValue + i];
}

- (NSNumber *)addFloat:(float)f
{
	return [NSNumber numberWithFloat:self.floatValue + f];
}

- (NSNumber *)addDouble:(double)d
{
	return [NSNumber numberWithFloat:self.doubleValue + d];
}

@end

