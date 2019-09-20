//
//  NSObject+Oxygen.h
//  Oxygen
//
//  Created by 黄 时欣 on 13-7-2.
//  Copyright (c) 2013年 zhang cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Oxygen)

- (void)scheduleBlock:(void (^)())block afterDelay:(NSTimeInterval)ti;

- (void)performBlockInBackground:(void (^)())block;
- (void)performBlockOnMainThread:(void (^)())block;
- (void)performBlockOnMainThread:(void (^)())block waitUntilDone:(BOOL)done;

@end

