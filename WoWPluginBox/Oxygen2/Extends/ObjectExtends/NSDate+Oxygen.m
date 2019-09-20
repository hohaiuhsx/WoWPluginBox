//
//  NSDate+Oxygen.m
//  Oxygen
//
//  Created by 黄 时欣 on 13-4-27.
//  Copyright (c) 2013年 Jiang Su Nanyi Digital Dna Science & Technology CO.LTD. All rights reserved.
//

#import "NSDate+Oxygen.h"
#import "OFMacro.h"

@implementation NSDate (Oxygen)

+ (NSString *)getCurrentTime
{
	NSDate			*nowUTC			= [NSDate date];
	NSDateFormatter *dateFormatter	= [[NSDateFormatter alloc] init];

	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:nowUTC];
}

+ (NSString *)getTimestamp
{
	NSDate *now = [NSDate date];

	return date2String(@"yyyyMMddHHmmssSSS", now);
}

- (NSInteger)year
{
	return [self.components year];
}

- (NSInteger)month
{
	return [self.components month];
}

- (NSInteger)day
{
	return [self.components day];
}

- (NSInteger)hour
{
	return [self.components hour];
}

- (NSInteger)minute
{
	return [self.components minute];
}

- (NSInteger)second
{
	return [self.components second];
}

- (NSInteger)week
{
	return [self.components week];
}

- (NSDateComponents *)components
{
	return [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self];
}

- (NSDate *)dateWithoutTime
{
	NSCalendar			*calendar	= [NSCalendar currentCalendar];
	NSDateComponents	*components = [calendar components:(NSYearCalendarUnit
		| NSMonthCalendarUnit
		| NSDayCalendarUnit)
		fromDate:self];

	return [calendar dateFromComponents:components];
}

- (NSDate *)dateByAddingDays:(NSInteger)days months:(NSInteger)months years:(NSInteger)years
{
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];

	dateComponents.day		= days;
	dateComponents.month	= months;
	dateComponents.year		= years;

	return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
			toDate	:self
			options :0];
}

- (NSDate *)dateByAddingDays:(NSInteger)days
{
	return [self dateByAddingDays:days months:0 years:0];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months
{
	return [self dateByAddingDays:0 months:months years:0];
}

- (NSDate *)dateByAddingYears:(NSInteger)years
{
	return [self dateByAddingDays:0 months:0 years:years];
}

- (NSDate *)monthStartDate
{
	NSDate *monthStartDate = nil;

	[[NSCalendar currentCalendar] rangeOfUnit:NSMonthCalendarUnit
	startDate	:&monthStartDate
	interval	:NULL
	forDate		:self];

	return monthStartDate;
}

- (NSDate *)weekStartDate
{
	NSDate *weekStartDate = nil;

	[[NSCalendar currentCalendar] rangeOfUnit:NSWeekOfYearCalendarUnit
	startDate	:&weekStartDate
	interval	:NULL
	forDate		:self];

	return weekStartDate;
}

- (NSUInteger)numberOfDaysInMonth
{
	return [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
			inUnit									:NSMonthCalendarUnit
			forDate									:self].length;
}

- (NSUInteger)numberOfWeeksInYear
{
	return [[NSCalendar currentCalendar] rangeOfUnit:NSWeekOfYearCalendarUnit
			inUnit									:NSYearCalendarUnit
			forDate									:self].length;
}

- (NSUInteger)weekday
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:self];

	return [weekdayComponents weekday];
}

- (NSString *)dateStringWithFormat:(NSString *)format
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

	[formatter setDateFormat:format];

	return [formatter stringFromDate:self];
}

- (NSUInteger)daysSinceDate:(NSDate *)from
{
	NSCalendar			*calendar	= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int		unitFlag	= NSDayCalendarUnit;
	NSDateComponents	*components = [calendar components:unitFlag fromDate:from toDate:self options:0];
	NSInteger			days		= [components day];

	return days;
}

@end

