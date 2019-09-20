//
//  NSString+Oxygen.h
//  Oxygen
//
//  Created by 黄 时欣 on 13-3-12.
//  Copyright (c) 2013年 zhang cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+Oxygen.h"

@interface NSString (Oxygen)

// 判断字符串是否为空
+ (BOOL)isStringEmpty:(NSString *)str;
// 过滤“ ”空格后判断是否为空
+ (BOOL)isStringEmptyOrBlank:(NSString *)str;

/*正则表达式匹配*/
- (BOOL)matchRegExp:(NSString *)regex;
/*手机号码验证*/
- (BOOL)validateMobile;
/*车牌号验证*/
- (BOOL)validateLicensePlateNo;
/*Email地址验证*/
- (BOOL)validateEmail;
/*URL地址验证*/
- (BOOL)validateURL;
/*邮政编码验证*/
- (BOOL)validateZipCode;
/*帐号是否合法(字母开头，允许5-16字节，允许字母数字下划线)*/
- (BOOL)validateAccountNo;
/*国内电话号码验证*/
- (BOOL)validatePhoneNo;
/*腾讯QQ号验证(腾讯QQ号从10000开始)*/
- (BOOL)validateTencentQQ;
/*身份证验证*/
- (BOOL)validateIDCard;
/*ip地址验证*/
- (BOOL)validateIPAddress;
/*n位英文字母组成的字符串*/
- (BOOL)validateLetter:(int)n;
/*n位大写英文字母组成的字符串*/
- (BOOL)validateUppercaseLetter:(int)n;
/*n位小写英文字母组成的字符串*/
- (BOOL)validateLowercaseLetter:(int)n;
/*密码验证（以字母开头，长度在6-18之间，只能包含字符、数字和下划线）*/
- (BOOL)validatePassword;
/*车架号校验 17位数字字母*/
- (BOOL)validateVIN;

/*String 转 NSDate*/
- (NSDate *)stringDateWithFormat:(NSString *)format;

/* md5 */
- (NSString *)md5Encrypt;
/* url encode*/
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
/* java的urlencode，可能不对+号编码 直接转成%20*/
- (NSString *)URLDecodedJavaString;
/* base64 编码 */
- (NSString *)Base64EncodedString;
- (NSString *)Base64DecodedString;

- (NSDictionary *)toJsonDictWithEncoding:(NSStringEncoding)enc error:(NSError **)err;
- (NSDictionary *)toUTF8JsonDictError:(NSError **)err;

- (NSString *)stringForPrivacyDefault;
- (NSString *)stringForPrivacyWith:(unichar)placeholder first:(int)first last:(int)last;

- (BOOL)startWith:(NSString *)prefix;
- (BOOL)endWith:(NSString *)suffix;
- (BOOL)contains:(NSString *)string;
@end

