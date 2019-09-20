//
//  OFMutableDictionary.m
//  Demo
//
//  Created by 黄 时欣 on 14-4-4.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "OFMutableDictionary.h"

#define WILL_CHANGE_PROPERTIES	[self willChangeValueForKey:@"Properties"]
#define DID_CHANGE_PROPERTIES	[self didChangeValueForKey:@"Properties"]

@interface OFMutableDictionary ()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation OFMutableDictionary

+ (OFMutableDictionary *)dictionary
{
	return [[OFMutableDictionary alloc]init];
}

- (id)init
{
	self = [super init];

	if (self) {
		self.dict = [NSMutableDictionary dictionary];
	}

	return self;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary
{
    self = [super init];
    
	if (self) {
		self.dict = [NSMutableDictionary dictionaryWithDictionary:otherDictionary];
	}
    
	return self;
}

-(NSMutableDictionary *)realDictionary
{
    return self.dict;
}

-(id)valueForKey:(NSString *)key
{
    return [self.dict valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	BOOL change = value && value != [_dict objectForKey:key];

	if (change) {
		WILL_CHANGE_PROPERTIES;
	}

	[_dict setValue:value forKey:key];

	if (change) {
		DID_CHANGE_PROPERTIES;
	}
}

- (void)removeAllObjects
{
	BOOL change = _dict.count > 0;

	if (change) {
		WILL_CHANGE_PROPERTIES;
	}

	[_dict removeAllObjects];

	if (change) {
		DID_CHANGE_PROPERTIES;
	}
}

- (void)removeObjectForKey:(id)aKey
{
	BOOL change = [_dict objectForKey:aKey] != nil;

	if (change) {
		WILL_CHANGE_PROPERTIES;
	}

	[_dict removeObjectForKey:aKey];

	if (change) {
		DID_CHANGE_PROPERTIES;
	}
}

- (void)addChangedObserver:(NSObject *)observer context:(void *)context
{
	[self addObserver:observer forKeyPath:@"Properties" options:0 context:context];
}

- (NSString *)description
{
	return self.dict.description;
}

@end

