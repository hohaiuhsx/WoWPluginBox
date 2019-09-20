//
//  UIAlertView+Oxygen.h
//  Oxygen
//
//  Created by 黄 时欣 on 13-5-23.
//
//

typedef void (^ NSAlertDidDismissBlok)(NSAlert *alertView, NSInteger buttonIndex);

@interface NSAlert (Oxygen)

// 添加dismissBlock
+ (NSAlert *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message block:(NSAlertDidDismissBlok)block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;

+ (NSAlert *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message block:(void (^)(NSAlert *alert))block;

+ (NSAlert *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

- (void)setDidDismissBlok:(NSAlertDidDismissBlok)block;
@end

