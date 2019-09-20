//
//  NSAlert+Oxygen.m
//  Oxygen
//
//  Created by 黄 时欣 on 13-5-23.
//
//

#import "NSAlert+Oxygen.h"
#import <objc/runtime.h>

@interface NSAlert () <NSAlertDelegate>

@end
@implementation NSAlert (Oxygen)

static char alertViewDidDismissBlokKey;

- (void)setDidDismissBlok:(NSAlertDidDismissBlok)block
{
	self.delegate = self;
	[self willChangeValueForKey:@"AlertViewDidDismissBlok"];
	objc_setAssociatedObject(self, &alertViewDidDismissBlokKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
	[self didChangeValueForKey:@"AlertViewDidDismissBlok"];
}

- (NSAlertDidDismissBlok)didDismissBlok
{
	id block = objc_getAssociatedObject(self, &alertViewDidDismissBlokKey);

	return block;
}

+ (NSAlert *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message block:(NSAlertDidDismissBlok)block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
	NSAlert *alertView =

		[NSAlert alertWithMessageText:title defaultButton:cancelButtonTitle alternateButton:nil otherButton:nil informativeTextWithFormat:message, nil];

	va_list args;
	va_start(args, otherButtonTitles);

	for (NSString *title = otherButtonTitles; title != nil; title = va_arg(args, NSString *)) {
		[alertView addButtonWithTitle:title];
	}

	va_end(args);

	[alertView setDidDismissBlok:block];

	[alertView beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];
	return alertView;
}

+ (NSAlert *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    NSAlert *alertView = [NSAlert alertWithMessageText:title defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:message,nil];

	[alertView beginSheetModalForWindow:nil modalDelegate:self didEndSelector:nil contextInfo:nil];
	return alertView;
}

+ (NSAlert *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message block:(void (^)(NSAlert *alertView))block
{
	return [NSAlert showAlertViewWithTitle:title message:message block:^(NSAlert *alertView, NSInteger buttonIndex) {
			   block(alertView);
		   } cancelButtonTitle:@"确定" otherButtonTitles:nil];
}

- (void)alertView:(NSAlert *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	self.didDismissBlok(alertView, buttonIndex);
}

@end

