//
//  SinaCustomTableViewCell.h
//  SinaApp_MVC
//
//  Created by SuperWang on 16/5/19.
//  Copyright © 2016年 SuperWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface SinaCustomTableViewCell : UITableViewCell<TTTAttributedLabelDelegate>
//头像
@property(strong,nonatomic) UIButton *headImgButton;
//标题
@property(strong,nonatomic) TTTAttributedLabel *titleLabel;
//来源+时间
@property(strong,nonatomic) TTTAttributedLabel *sourceLabel;
//内容
@property(strong,nonatomic) TTTAttributedLabel *contentLabel;
/** 缩略图容器View*/
@property(strong,nonatomic) UIView *contentImageViews;
/** 缩略图*/
@property(strong,nonatomic) UIImageView *contentImageView;
/** 内容页缩略图集*/
@property(strong,nonatomic) NSMutableArray *contentImageViewArray;

//计算cell的高度
-(CGFloat)getCellHeightWithTextHeight:(NSNumber*)textH;
@end










