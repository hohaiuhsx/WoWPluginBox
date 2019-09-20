//
//  NSDictionary+Oxygen.m
//  Oxygen
//
//  Created by 黄 时欣 on 12-12-24.
//
//

#import "NSDictionary+Oxygen.h"

@implementation NSDictionary (Oxygen)

-(NSArray *)allKeysSortedByKey{
    NSArray *keys = [self allKeys];
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 localizedStandardCompare:obj2];
    }];
    return keys;
}

-(NSArray *)allKeysSortedByKeyDesc{
    NSArray *keys = [self allKeys];
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return -1 * [obj1 localizedStandardCompare:obj2];
    }];
    return keys;
}

- (NSData *)toJsonDataWithOptions:(NSJSONWritingOptions)opt error:(NSError **)err{
    return [NSJSONSerialization dataWithJSONObject:self options:opt error:err];
}

- (NSData *)toJsonDataError:(NSError **)err{
    return [self toJsonDataWithOptions:NSJSONWritingPrettyPrinted error:err];
}


- (NSString *)toJsonStringWithOptions:(NSJSONWritingOptions)opt error:(NSError **)err encoding:(NSStringEncoding)encoding{
    return [[NSString alloc]initWithData:[self toJsonDataWithOptions:opt error:err] encoding:encoding];
}
- (NSString *)toJsonUTF8StringError:(NSError **)err{
    return [self toJsonStringWithOptions:NSJSONWritingPrettyPrinted error:err encoding:NSUTF8StringEncoding];
}

@end
