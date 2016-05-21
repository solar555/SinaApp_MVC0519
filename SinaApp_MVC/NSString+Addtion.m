//
//  NSString+Addtion.m
//  SinaApp_MVC
//
//  Created by solar on 16/5/19.
//  Copyright © 2016年 SuperWang. All rights reserved.
//

#import "NSString+Addtion.h"
#import <UIKit/UIKit.h>
#import "UIColor+Hex.h"

@implementation NSString (Addtion)
//截取字符串
//<a>新浪</a>
- (NSString *)sinaSourceString{
    //1.获得>的range
    NSRange signRange = [self rangeOfString:@">"];
    if (signRange.location != NSNotFound) {
        //获取signRange的范围大小
        NSMaxRange(signRange);
        //根据范围大小，作为要截取的字符串的起点
        //要截取的Range
        NSRange sourceRange = NSMakeRange(NSMaxRange(signRange), self.length - NSMaxRange(signRange) - 4);
        //根据算出来的范围截取字符串
        NSString *sourceString = [self substringWithRange:sourceRange];
        return sourceString;
    }
    return nil;
}
//
- (NSString *)timeString{
    //eee mmm d HH:mm:ss Z yyyy
    //将服务器返回的字符串转换成NSDate，需要用到时间格式化对象
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //设置格式化的显示样式
    [formatter setDateFormat:@"eee MMM d HH:mm:ss Z yyyy"];
    //将时间字符串转换成NSDate
    NSDate *timeDate = [formatter dateFromString:self];
    //只有转化成NSDate对象，才可以和当前的事件进行对比
    //已经发布多久
    //方法1：
    //    NSTimeInterval timeInterval = [timeDate timeIntervalSinceNow];
    //方法2：
    //先获取当前时间
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:timeDate];
    //将得到的秒数进行转换
    //一小时之内
    NSString *timeString = nil;
    if (timeInterval < 60) {
        timeString = @"刚刚";
    }
    if (timeInterval < 60*60) {
        timeString = [NSString stringWithFormat:@"%.f分钟前",timeInterval/60];
    }else{
        //HH:mm:ss
        [formatter setDateFormat:@"HH:mm:ss"];
        timeString = [formatter stringFromDate:timeDate];
    }
    NSLog(@"");
    return timeString;
}

#pragma mark 使用这侧表达式检索字符串中符合规则的字符
- (NSArray<NSTextCheckingResult *> *)matchStringWithPattern:(NSString *)pattern{
    NSError *error = nil;
    //正则表达式的对象
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (regularExpression) {
        //根据正则表达式检索字符串
        NSArray<NSTextCheckingResult *> *resultArrary = [regularExpression matchesInString:self options:0 range:NSMakeRange(0, self.length)];
        return resultArrary;
    }
    return nil;
}
#pragma mark 将NSString变换成富文本
- (NSAttributedString *)sinaString{
    //1.先根据原有的字符串创建富文本
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc]initWithString:self];
    //2.使用正则表达式过滤字符串，得到字符串的位置信息
    //过滤：@，#，http
    NSString *pattern = @"(@\\w+)|(#\\w+#)|(http(s)?://([A-Za-z0-9._-]+(/)?)*)";
    NSArray *resArray = [self matchStringWithPattern:pattern];
    //遍历结果数组
    [resArray enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //获取检索出来的字符串的Range
        NSRange resultRange = obj.range;
        
        [attributString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4f7cae"] range:resultRange];
    }];
    return attributString;
}
//重载
- (void)sinaString:(TTTAttributedLabel *)label{
    //1.先根据原有的字符串创建富文本
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc]initWithString:self];
    //关键************************
    label.text = attributString;
    //2.使用正则表达式过滤字符串，得到字符串的位置信息
    //过滤：@，#，http
    NSString *pattern = @"(@\\w+)|(#\\w+#)|(http(s)?://([A-Za-z0-9._-]+(/)?)*)";
    NSArray *resArray = [self matchStringWithPattern:pattern];
    //遍历结果数组
    [resArray enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //获取检索出来的字符串的Range
        NSRange resultRange = obj.range;
        [attributString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4f7cae"] range:resultRange];
        //添加链接
        //1.@user 2.#话题#
        [self demoStringWithString:attributString label:label range:resultRange];
    }];
}

//重载
- (TTTAttributedLabel *)sinaStringWithLabel:(TTTAttributedLabel *)label{
    //1.先根据原有的字符串创建富文本
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc]initWithString:self];
    //关键************************
    label.text = attributString;
    //2.使用正则表达式过滤字符串，得到字符串的位置信息
    //过滤：@，#，http
    NSString *pattern = @"(@\\w+)|(#\\w+#)|(http(s)?://([A-Za-z0-9._-]+(/)?)*)";
    NSArray *resArray = [self matchStringWithPattern:pattern];
    //遍历结果数组
    [resArray enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //获取检索出来的字符串的Range
        NSRange resultRange = obj.range;
        [attributString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4f7cae"] range:resultRange];
        //添加链接
        //1.@user 2.#话题#
        [self demoStringWithString:attributString label:label range:resultRange];
    }];
    return label;
}
#pragma mark 为富文本添加链接
- (void)demoStringWithString:(NSMutableAttributedString *)attributString label:(TTTAttributedLabel *)label range:(NSRange)range{
    //获得子字符串
    //1.@string 2.#string#
    NSString *myString = [attributString.string substringWithRange:range];
    //判断首个字符是'@'还是'#'
    NSString *firstChar = [myString substringToIndex:1];
    if ([firstChar isEqualToString:@"@"]) {//@用户
        NSString *name = [myString substringFromIndex:1];
        NSString *urlString = [NSString stringWithFormat:@"https://weibo.com/n/%@?from=feed&loc=at",name];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        [label addLinkToURL:[NSURL URLWithString:urlString] withRange:range];
    }else if ([firstChar isEqualToString:@"#"]){//#话题#
        //取出##中间的字符串
        //即话题名称
        NSString *title = [myString substringFromIndex:1];
        NSRange range = NSMakeRange(0, title.length - 1);
        title = [title substringWithRange:range];
        //生成url
        NSString *urlString = [NSString stringWithFormat:@"http://huati.weibo.com/k/%@?from=501",title];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        [label addLinkToURL:[NSURL URLWithString:urlString] withRange:range];
    }
}
@end























