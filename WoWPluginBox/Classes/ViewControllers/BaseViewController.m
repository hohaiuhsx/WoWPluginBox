//
//  BaseViewController.m
//  WoWPluginBox
//
//  Created by 黄 时欣 on 14-11-15.
//  Copyright (c) 2014年 黄 时欣. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)init
{
	if (self = [super init]) {
		[self registerRequestManagerObserver];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[self registerRequestManagerObserver];
	}

	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self  registerRequestManagerObserver];
	}

	return self;
}

- (void)loadView
{
	[super loadView];
}

- (void)dealloc
{
	[self unregisterRequestManagerObserver];
}

- (void)onSelected{
    
}

@end

