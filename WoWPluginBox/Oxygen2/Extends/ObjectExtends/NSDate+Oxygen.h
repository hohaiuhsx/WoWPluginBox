//
//  NSDate+Oxygen.h
//  Oxygen
//
//  Created by 黄 时欣 on 13-4-27.
//  Copyright (c) 2013年 Jiang Su Nanyi Digital Dna Science & Technology CO.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Oxygen)

// 获取当前UTC时间
+ (NSString *)getCurrentTime;
+ (NSString *)getTimestamp;

- (NSDateComponents *)components;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)second;
- (NSInteger)week;

// 一下内容来自  NSDate+Helpers

/**
 * Returns current (self) date without time components. Effectively, it's just a beginning of a day.
 */
- (NSDate *)dateWithoutTime;

/**
 * Returns a date object shifted by a given number of days from the current (self) date.
 */
- (NSDate *)dateByAddingDays:(NSInteger)days;

/**
 * Returns a date object shifted by a given number of months from the current (self) date.
 */
- (NSDate *)dateByAddingMonths:(NSInteger)months;

/**
 * Returns a date object shifted by a given number of years from the current (self) date.
 */
- (NSDate *)dateByAddingYears:(NSInteger)years;

/**
 * Returns a date object shifted by a given number of days, months and years from the current (self) date.
 */
- (NSDate *)dateByAddingDays:(NSInteger)days months:(NSInteger)months years:(NSInteger)years;

/**
 * Returns start of month for the current (self) date.
 */
- (NSDate *)monthStartDate;
- (NSDate *)weekStartDate;

/**
 * Returns the number of days in the current (self) month.
 */
- (NSUInteger)numberOfDaysInMonth;

- (NSUInteger)numberOfWeeksInYear;

/**
 * Returns the weekday of the current (self) date.
 *
 * Returns 1 for Sunday, 2 for Monday ... 7 for Saturday
 */
- (NSUInteger)weekday;

/**
 * Returns string representation of the current (self) date formatted with given format.
 *
 * i.e. "dd-MM-yyyy" will return "14-07-2012"
 */
- (NSString *)dateStringWithFormat:(NSString *)format;

- (NSUInteger)daysSinceDate:(NSDate *)from;

@end

