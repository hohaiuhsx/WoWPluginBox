//
//  OFMacro.h
//  Oxygen2
//
//  Created by 黄 时欣 on 13-11-5.
//  Copyright (c) 2013年 黄 时欣. All rights reserved.
//

// 日志宏
//#ifndef __OPTIMIZE__
//  #define NSLog(...)	DDLogVerbose(__VA_ARGS__)
//#else
//  #define NSLog(...)	{}
//#endif

#define NSLogTrace			NSLog(@"\n**************************************\n%s\n**************************************\n", __func__)

// 常用APP属性
#define FONT_SIZE			14
#define APP_DELEGATE		((AppDelegate *)[NSApplication sharedApplication].delegate)
#define APP_IDENTIFIER		[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define APP_NAME			[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]
#define APP_VERSION			[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_BUILD			[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define APP_DISPLAY_NAME	[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

// 屏幕尺寸及机型
#define isRetina			([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) | CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)
#define iPhone5				([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

// 定义宏，判断ios7
#define iOS7				([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0)

// 友盟统计
#define umengAnalytics(appKey) [MobClick startWithAppkey : appKey]
// iVersion
#define iVersionInit	+(void)initialize {[iVersion sharedInstance].applicationBundleID = APP_IDENTIFIER; }

// 常用变量 工具方法
#define viewWidth		self.view.frame.size.width
#define viewHeight		self.view.frame.size.height

#define colorWithImageName(name)						[UIColor colorWithPatternImage :[UIImage imageNamed:name]]
#define colorWithHex(colorString)						[UIColor colorWithHexString : colorString]
#define imageWithHex(colorString)						[UIImage imageWithColor : colorWithHex(colorString)]
#define rgbColor(r, g, b)								[UIColor colorWithRed : (r) / 255.0f green : (g) / 255.0f blue : (b) / 255.0f alpha : 1]
#define rgbaColor(r, g, b, a)							[UIColor colorWithRed : (r) / 255.0f green : (g) / 255.0f blue : (b) / 255.0f alpha : (a)]

// 拨打电话
#define callPhone(number)								{																					 \
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", number]];											 \
		if ([[UIApplication sharedApplication] canOpenURL:url]) {																			 \
			[[UIApplication sharedApplication] openURL:url];																				 \
		} else {																															 \
			[[[UIAlertView alloc]initWithTitle:@"" message:@"您的设备不支持拨打电话" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show]; \
		}																																	 \
}

// button click事件
#define addBtnAction(btn, sel)							[btn addTarget : self action : sel forControlEvents : UIControlEventTouchUpInside]

// 读取plist文件
#define arrayWithPlistFile(fileName)					[NSArray arrayWithContentsOfFile :[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];
#define dictWithPlistFile(fileName)						[NSDictionary dictionaryWithContentsOfFile :[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];

// 字符串格式化
#define strFormat(format, ...)							([NSString stringWithFormat:format, __VA_ARGS__])
// 日期时间格式化
#define date2String(format, date)						[date dateStringWithFormat : format]
#define date2StringFormatYMDHMS(date)					[date dateStringWithFormat : @"yyyy-MM-dd HH:mm:ss"]
#define date2StringFormatYMDHM(date)					[date dateStringWithFormat : @"yyyy-MM-dd HH:mm"]
#define date2StringFormatYMD(date)						[date dateStringWithFormat : @"yyyy-MM-dd"]
#define date2StringFormatYM(date)						[date dateStringWithFormat : @"yyyy-MM"]
#define date2StringFormatMD(date)						[date dateStringWithFormat : @"MM-dd"]
#define date2StringFormatMDHM(date)						[date dateStringWithFormat : @"MM-dd HH:mm"]
#define date2StringFormatHM(date)						[date dateStringWithFormat : @"HH:mm"]
#define date2StringFormatHMS(date)						[date dateStringWithFormat : @"HH:mm:ss"]
#define date2StringFormatCEMD(date)						[date dateStringWithFormat : @"EEE M月d日"]

#define string2Date(format, str)						[str stringDateWithFormat : format];
#define string2DateFormatYMDHMS(str)					[str stringDateWithFormat : @"yyyy-MM-dd HH:mm:ss"]
#define string2DateFormatYMDHM(str)						[str stringDateWithFormat : @"yyyy-MM-dd HH:mm"]
#define string2DateFormatYMD(str)						[str stringDateWithFormat : @"yyyy-MM-dd"]
#define string2DateFormatYM(str)						[str stringDateWithFormat : @"yyyy-MM"]
#define string2DateFormatMD(str)						[str stringDateWithFormat : @"MM-dd"]
#define string2DateFormatMDHM(str)						[str stringDateWithFormat : @"MM-dd HH:mm"]
#define string2DateFormatHM(str)						[str stringDateWithFormat : @"HH:mm"]
#define string2DateFormatHMS(str)						[str stringDateWithFormat : @"HH:mm:ss"]
#define string2DateFormatCEMD(str)						[str stringDateWithFormat : @"EEE M月d日"]

// 通知
#define postNotification(actionName, obj)				{											\
		NSNotification *notification = [NSNotification notificationWithName:actionName object:obj];	\
		[[NSNotificationCenter defaultCenter]postNotification:notification];						\
}

#define addSelfAsNotificationObserver(actionName, SEL)	{												\
		[[NSNotificationCenter defaultCenter]addObserver:self selector:SEL name:actionName object:nil];	\
}

#define removeSelfNofificationObserver(actionName)		{									   \
		[[NSNotificationCenter defaultCenter] removeObserver:self name:actionName object:nil]; \
}

#define removeSelfNofificationObservers {							\
		[[NSNotificationCenter defaultCenter] removeObserver:self];	\
}

#define OFCurrentLanguage				[[NSLocale preferredLanguages]objectAtIndex:0]

// 单例宏
#define SYNTHESIZE_SINGLETON_FOR_CLASS_H(classname)	\
	+ (classname *)shared##classname;

#define SYNTHESIZE_SINGLETON_FOR_CLASS_M(classname)				\
																\
	static classname * shared##classname = nil;					\
																\
	+ (classname *)shared##classname							\
	{															\
		@synchronized(self) {									\
			if (shared##classname == nil) {						\
				shared##classname = [[self alloc] init];		\
			}													\
		}														\
																\
		return shared##classname;								\
	}															\
																\
	+ (id)allocWithZone:(NSZone *)zone							\
	{															\
		@synchronized(self) {									\
			if (shared##classname == nil) {						\
				shared##classname = [super allocWithZone:zone];	\
				return shared##classname;						\
			}													\
		}														\
																\
		return nil;												\
	}															\
																\
	- (id)copyWithZone:(NSZone *)zone							\
	{															\
		return self;											\
	}

// tip
#define showTip(tip)				[APP_DELEGATE.window makeToast : tip duration : 2 position : @"center"]

// 静态类库  纯category bug
#define OF_FIX_CATEGORY_BUG(name)	@interface OF_FIX_CATEGORY_BUG_##name @end \
	@implementation OF_FIX_CATEGORY_BUG_##name @end

// 给NSObject对象添加临时属性
#import <objc/runtime.h>
#define ADD_TEMP_ATTRIBUTE_FOR_OBJECT(className, attrName, objc_AssociationPolicy)			  \
	@interface className (attrName)															  \
	- (void)set##attrName:(id)attribute;													  \
	- (id)get##attrName;																	  \
	@end																					  \
	@implementation className (attrName)													  \
	static char key_##attrName;																  \
	- (void)set##attrName:(id)attribute														  \
	{																						  \
		NSString *key = [@"attribute_" stringByAppendingString : NSStringFromSelector(_cmd)]; \
		[self willChangeValueForKey:key];													  \
		objc_setAssociatedObject(self, &key_##attrName, attribute, objc_AssociationPolicy);	  \
		[self didChangeValueForKey:key];													  \
	}																						  \
																							  \
	- (id)get##attrName																		  \
	{																						  \
		id attribute = objc_getAssociatedObject(self, &key_##attrName);						  \
		return attribute;																	  \
	}																						  \
	@end																					  \

// 沙盒路径
#define SandBoxDocumentPath (NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0])
#define SandBoxCachePath	(NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0])
#define SandBoxTempPath		(NSTemporaryDirectory())

// block
#define weakObj(x)	__weak typeof(x) b##x	= x
#define blockObj(x)     __block typeof(x) b##x	= x

