//
//  SinaCustomTableViewCell.m
//  SinaApp_MVC
//
//  Created by SuperWang on 16/5/19.
//  Copyright © 2016年 SuperWang. All rights reserved.
//
#define SCREEN_BOUNDS [[UIScreen mainScreen]bounds]

#import "SinaCustomTableViewCell.h"
#import "UIColor+Hex.h"

@implementation SinaCustomTableViewCell
//重写初始化方法
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //头像
        _headImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _headImgButton.frame  = CGRectMake(10, 10, 35, 35);
        [self.contentView addSubview:_headImgButton];
        //切圆角
        _headImgButton.layer.cornerRadius = 17.5;
        //方法1：切
        _headImgButton.clipsToBounds = YES;
        //方法2：layer
//        _headImgButton.layer.masksToBounds = YES;
        //设置颜色
//        _headImgButton.layer.borderColor = [UIColor whiteColor].CGColor;
//        _headImgButton.layer.borderWidth = 1;
        
        //title
        CGRect titleFrame = CGRectMake(CGRectGetMaxX(_headImgButton.frame)+10, CGRectGetMinY(_headImgButton.frame), CGRectGetWidth(SCREEN_BOUNDS)-CGRectGetWidth(_headImgButton.frame)-30, 20);
        _titleLabel = [[TTTAttributedLabel alloc]initWithFrame:titleFrame];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#f57723"];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_titleLabel];
        
        //time
        
        
        //source
        CGRect sourceFrame = CGRectMake(CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(_titleLabel.frame), CGRectGetWidth(_titleLabel.frame), CGRectGetHeight(_titleLabel.frame));
        _sourceLabel = [[TTTAttributedLabel alloc]initWithFrame:sourceFrame];
        _sourceLabel.font = [UIFont systemFontOfSize:10];
        _sourceLabel.textColor = [UIColor colorWithHexString:@"#939393"];
        [self.contentView addSubview:_sourceLabel];
        
        //content
        CGRect contentFrame = CGRectMake(CGRectGetMinX(_headImgButton.frame), CGRectGetMaxY(_headImgButton.frame)+10, CGRectGetWidth(SCREEN_BOUNDS)-20, 30);
        _contentLabel = [[TTTAttributedLabel alloc]initWithFrame:contentFrame];
        _contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_contentLabel];
        
        //contentImageViews
        CGRect contentImageViewFrame = CGRectMake(0, CGRectGetMaxY(_contentLabel.frame)+10, CGRectGetWidth(SCREEN_BOUNDS), 117);
        _contentImageViews = [[UIView alloc]initWithFrame:contentImageViewFrame];
        [self.contentView addSubview:_contentImageViews];
    }
    return self;
}

//根据动态文字的大小获得cell的高度
-(CGFloat)getCellHeightWithTextHeight:(NSNumber*)textH
{
    CGFloat maxY = CGRectGetMaxY(self.sourceLabel.frame)+10+textH.floatValue;
    return maxY;
}




@end











