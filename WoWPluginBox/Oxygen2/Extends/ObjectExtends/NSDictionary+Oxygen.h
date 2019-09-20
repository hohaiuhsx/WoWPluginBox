//
//  NSDictionary+Oxygen.h
//  Oxygen
//
//  Created by 黄 时欣 on 12-12-24.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Oxygen)

// 取dictionary的所有key的集合 并正向排序（升序）
- (NSArray *)allKeysSortedByKey;
// 取dictionary的所有key的集合 并反向排序（降序）
- (NSArray *)allKeysSortedByKeyDesc;

- (NSData *)toJsonDataWithOptions:(NSJSONWritingOptions)opt error:(NSError **)err;
- (NSData *)toJsonDataError:(NSError **)err;
- (NSString *)toJsonStringWithOptions:(NSJSONWritingOptions)opt error:(NSError **)err encoding:(NSStringEncoding)encoding;
- (NSString *)toJsonUTF8StringError:(NSError **)err;

@end
