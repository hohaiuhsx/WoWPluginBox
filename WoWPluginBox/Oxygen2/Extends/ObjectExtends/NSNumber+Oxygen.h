//
//  NSNumber+Oxygen.h
//  Oxygen
//
//  Created by 黄 时欣 on 13-6-7.
//  Copyright (c) 2013年 zhang cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Oxygen)

-(NSString *)intString;
-(NSString *)floatString;
-(NSString *)doubleString;
-(NSString *)floatStringWithFormat:(NSString *)format;
-(NSString *)doubleStringWithFormat:(NSString *)format;

-(NSNumber *)addInt:(NSInteger)i;
-(NSNumber *)addFloat:(float)f;
-(NSNumber *)addDouble:(double)d;

@end
