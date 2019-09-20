//
//  OFMutableDictionary.h
//  Demo
//
//  Created by 黄 时欣 on 14-4-4.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OFMutableDictionary : NSObject

+ (OFMutableDictionary *)dictionary;

- (NSMutableDictionary *)realDictionary;

- (void)addChangedObserver:(NSObject *)observer context:(void *)context;

- (id)valueForKey:(NSString *)key;

- (void)setValue:(id)value forKey:(NSString *)key;

- (void)removeObjectForKey:(id)aKey;

- (void)removeAllObjects;

@end

