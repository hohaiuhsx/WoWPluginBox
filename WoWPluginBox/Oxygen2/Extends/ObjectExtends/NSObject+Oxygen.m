//
//  NSObject+Oxygen.m
//  Oxygen
//
//  Created by 黄 时欣 on 13-7-2.
//  Copyright (c) 2013年 zhang cheng. All rights reserved.
//

#import "NSObject+Oxygen.h"

@implementation NSObject (Oxygen)

- (void)scheduleBlock:(void (^)())block afterDelay:(NSTimeInterval)ti
{
	[self performSelector:@selector(callBlock:) withObject:[block copy] afterDelay:ti];
}

- (void)performBlockInBackground:(void (^)())block
{
	[self performSelectorInBackground:@selector(callBlock:) withObject:[block copy]];
}

- (void)performBlockOnMainThread:(void (^)())block
{
	[self performSelectorOnMainThread:@selector(callBlock:) withObject:[block copy] waitUntilDone:[NSThread isMainThread]];
}

- (void)performBlockOnMainThread:(void (^)())block waitUntilDone:(BOOL)done
{
	[self performSelectorOnMainThread:@selector(callBlock:) withObject:[block copy] waitUntilDone:[NSThread isMainThread] || done];
}

- (void)callBlock:(void (^)())block
{
	block();
}

@end

