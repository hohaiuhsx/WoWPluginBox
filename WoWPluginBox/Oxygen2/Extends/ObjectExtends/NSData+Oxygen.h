// http://www.cocoadev.com/index.pl?BaseSixtyFour

#import <Foundation/Foundation.h>
@interface NSData (Oxygen)

//base64String 转 NSData
+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
//对NSData进行Base64编码
- (NSString *)base64Encoding;

- (NSDictionary *)toJsonDictWithOptions:(NSJSONReadingOptions)opt error:(NSError **)err;
- (NSDictionary *)toJsonDictError:(NSError **)err;

- (unsigned long)crc32Value;
@end
