//
//  NSString+Addtion.h
//  SinaApp_MVC
//
//  Created by solar on 16/5/19.
//  Copyright © 2016年 SuperWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTAttributedLabel.h"

@interface NSString (Addtion)
- (NSString *)sinaSourceString;
- (NSString *)timeString;
- (NSArray<NSTextCheckingResult *> *)matchStringWithPattern:(NSString *)pattern;
- (NSAttributedString *)sinaString;
- (void)sinaString:(TTTAttributedLabel *)label;
- (TTTAttributedLabel *)sinaStringWithLabel:(TTTAttributedLabel *)label;
@end
