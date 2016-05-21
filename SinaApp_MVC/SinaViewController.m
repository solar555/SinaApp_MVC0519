//
//  SinaViewController.m
//  SinaApp_MVC
//
//  Created by SuperWang on 16/5/18.
//  Copyright © 2016年 SuperWang. All rights reserved.
//

#import "SinaViewController.h"
#import "SinaLoginView.h"
#import "SinaTool.h"
#import "DataModels.h"
#import "UIButton+WebCache.h"
#import "SinaCustomTableViewCell.h"
#import "NSString+Addtion.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"

@interface SinaViewController ()<SinaLoginViewDelegate,SinaToolDelegate,UITableViewDelegate,UITableViewDataSource,TTTAttributedLabelDelegate>
{
    SinaTool *_sinaTool;
    UITableView *_myTableView;
    
    SinaCustomTableViewCell *_sinaCell;
}
@property(strong,nonatomic)NSArray *homeLineArray;
@property(strong,nonatomic)NSMutableArray *textHightArray;
@end

@implementation SinaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.textHightArray = [[NSMutableArray alloc]init];
    
    _myTableView = [[UITableView alloc]init];
    _myTableView.frame = self.view.frame;
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    [self.view addSubview:_myTableView];
    
    [_myTableView registerClass:[SinaCustomTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    //1,先判断是否登录
    _sinaTool = [[SinaTool alloc]init];
    _sinaTool.delegate = self;
    
    //已经登录,并且token没过期
    if ([_sinaTool isLogin]&&[_sinaTool isValid]){
        NSLog(@"已经登录");
        //进度动画
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            //请求homeline,请求新浪api
            [_sinaTool getHomeTimeLineWithToken:[_sinaTool getToken]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
    else
    {
        NSLog(@"获取授权");
        self.tabBarController.tabBar.hidden = YES;
        //登录
        SinaLoginView *loginView = [[SinaLoginView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        //设置代理
        loginView.delegate = self;
        
        [self.view addSubview:loginView];
        
        //开始授权
        [loginView startOauthRequest:[_sinaTool oauthRequest]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//计算cell高度
-(CGFloat)cellHeightWithTextHeigth:(NSNumber*)textH
{
    if (!_sinaCell) {
        _sinaCell = [[SinaCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
    }
    CGFloat cellHeght = [_sinaCell getCellHeightWithTextHeight:textH];
    return cellHeght;
}
#pragma mark -
#pragma mark - UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell 当前的高度 = cellSubView maxY
    NSMutableArray *textAndImageRectArray = self.textHightArray[indexPath.row];
    CGFloat cellHeight = [self cellHeightWithTextHeigth:[textAndImageRectArray lastObject]];
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.homeLineArray.count;
}

- (SinaCustomTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SinaCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SinaStatuses *statuesesModel = self.homeLineArray[indexPath.row];
    
    [cell.headImgButton sd_setBackgroundImageWithURL:[NSURL URLWithString:statuesesModel.user.profileImageUrl] forState:UIControlStateNormal];
    cell.titleLabel.text = statuesesModel.user.name;

    NSString *timeString = [statuesesModel.createdAt timeString];
    NSString *sourceString = [NSString stringWithFormat:@"%@ 来自%@",timeString,[statuesesModel.source sinaSourceString]];
    //使用类别中封装的截取方法，截取标签中的字符串
    cell.sourceLabel.text = sourceString;
    //将@String、#String#、http等，变为高亮
    [statuesesModel.text sinaStringWithLabel:cell.contentLabel];
    cell.contentLabel.delegate = self;
    //修改contentLabel的高度
    CGRect contentRect = cell.contentLabel.frame;
    NSMutableArray *textAndImageRectArray = self.textHightArray[indexPath.row];
    contentRect.size.height = ((NSNumber*)[textAndImageRectArray firstObject]).floatValue;
    cell.contentLabel.frame = contentRect;
    
    //设置图片
    //修改Views的Frame
    CGRect viewRect = cell.contentImageViews.frame;
    viewRect.size.height = ((NSNumber*)[textAndImageRectArray objectAtIndex:1]).floatValue;
    viewRect.origin.y = CGRectGetMaxY(contentRect) + 10;
    cell.contentImageViews.frame = viewRect;
    
    [self addImageViewsWithUrlArray:statuesesModel.picUrls contentView:cell.contentImageViews];
    
    return cell;
}
#pragma mark 添加图片集
- (void)addImageViewsWithUrlArray:(NSArray *)urlArray contentView:(UIView *)contentView{
    if (urlArray.count == 0) {
        NSArray *array = contentView.subviews;
        for (UIView *item in array) {
            [item removeFromSuperview];
        }
        return;
    }
    for (int i = 0; i < urlArray.count; i++) {
        int row = i / 3;
        int col = i % 3;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10 + col*(97+10), 10 + row*(97+10), 97, 97)];
        NSDictionary *urlDic = [urlArray objectAtIndex:i];
        NSURL *imageUrl = [NSURL URLWithString:[urlDic objectForKey:@"thumbnail_pic"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        imageView.image = [UIImage imageWithData:imageData];
        [contentView addSubview:imageView];
    }
}

#pragma mark - **************** TTTAttributedLabel协议方法
-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    DetailViewController *vc = [[DetailViewController alloc]init];
    vc.myUrl = url;
    NSLog(@"%@",url);
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate

#pragma mark - SinaLoginViewDelegate
//获得codeStirng
-(void)loginView:(SinaLoginView*)loginView didGetCodeString:(NSString*)codeString
{
    //获得code之后,移除loginView
    [loginView removeFromSuperview];
    self.tabBarController.tabBar.hidden = NO;
    //获取授权
    [_sinaTool getAccessTokenWithCode:codeString];
}

//获得请求Error
-(void)loginView:(SinaLoginView*)loginView didFailWithError:(NSError*)error
{
    NSLog(@"%@",error);
}

#pragma mark - SinaToolDelegate
//获得token
-(void)sinaTool:(SinaTool*)sinaTool didGetToken:(NSString*)token;
{
    NSLog(@"Token:%@",token);
    //第一次获得token的时候,请求timeline
    [sinaTool getHomeTimeLineWithToken:token];
}
//获得数据
-(void)sinaTool:(SinaTool *)sinaTool didGetHomeLine:(NSArray *)array
{
    //跟新数据源
    self.homeLineArray = array;
    //得到数据之后对text的高度进行计算
    for (SinaStatuses *model in array){
        if (model.text.length >0){
            //存放高度（text/image/text+image）
            NSMutableArray *totalRectArray = [[NSMutableArray alloc]init];
            //微博text的高度
            CGRect textRect =
            [model.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.frame)-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
            NSNumber *textRectNumber = @(CGRectGetHeight(textRect));
            [totalRectArray addObject:textRectNumber];
            //微博view（存放图片）的高度
            NSNumber *viewHeightNumber = [NSNumber numberWithFloat:0];
            if (model.picUrls.count > 0) {
                //计算图片显示行数
                float rowCountFloat = ((float)model.picUrls.count / 3.0f);
                int rowCountInt = (int)model.picUrls.count / 3;
                rowCountFloat = (rowCountFloat > rowCountInt)?rowCountInt + 1 : rowCountInt;
                //根据行数计算View的高度
                float viewHeight = 10 + rowCountFloat * (97 + 10);
                viewHeightNumber = [NSNumber numberWithFloat:viewHeight];
            }
            [totalRectArray addObject:viewHeightNumber];
            //text+view(存放图片)的高度
            NSNumber *totalHeightNumber = [NSNumber numberWithFloat:textRectNumber.floatValue + viewHeightNumber.floatValue];
            [totalRectArray addObject:totalHeightNumber];
            //@{} 字典
            //@[] 数组
            //@() number
            [self.textHightArray addObject:totalRectArray];
        }else{
            
            NSLog(@"微博内容为空");
        }
    }
    
    [_myTableView reloadData];
}

//获得error
-(void)sinaTool:(SinaTool*)sinaTool didFailedWithError:(NSError*)error;
{
    NSLog(@"%@",error);
}


@end


















