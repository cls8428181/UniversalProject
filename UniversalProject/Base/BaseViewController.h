//
//  BaseViewController.h
//  KenuoTraining
//
//  Created by 吴申超 on 16/2/26.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "KNBNavigationView.h"

typedef void (^KNMJFooterLoadCompleteBlock)(NSInteger page);
typedef void (^KNMJHeaderLoadCompleteBlock)(NSInteger page);

/**
 VC 基类
 */
@interface BaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
/**
 *  修改状态栏颜色
 */
@property (nonatomic, assign) UIStatusBarStyle StatusBarStyle;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UITableView *groupTableView;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger requestPage; //加载页数
@property (nonatomic, strong) KNBNavigationView *naviView;
/**
 *  显示没有数据页面
 */
-(void)showNoDataImage;

/**
 *  移除无数据页面
 */
-(void)removeNoDataImage;

/**
 *  加载视图
 */
- (void)showLoadingAnimation;

/**
 *  停止加载
 */
- (void)stopLoadingAnimation;

/**
 *  是否显示返回按钮,默认情况是YES
 */
@property (nonatomic, assign) BOOL isShowLiftBack;

/**
 是否隐藏导航栏
 */
@property (nonatomic, assign) BOOL isHidenNaviBar;

/**
 *  默认返回按钮的点击事件，默认是返回，子类可重写
 */
- (void)backAction;

//取消网络请求
- (void)cancelRequest;

/**
 *  添加下拉加载更多
 */
- (void)addMJRefreshHeadView:(KNMJHeaderLoadCompleteBlock)completeBlock;

/**
 *  添加上拉加载更多
 */
- (void)addMJRefreshFootView:(KNMJFooterLoadCompleteBlock)completeBlock;

/**
 上下拉请求结果回掉
 
 @param success 成功／失败
 @param end 是否请求结束
 */
- (void)requestSuccess:(BOOL)success requestEnd:(BOOL)end;

/**
 分享的信息
 
 @param messages @[@"标题"，@“简介”，@“链接”]
 @param shareButtonBlock 分享成功需要跳转
 
 */
- (void)shareMessages:(NSArray *)messages shareButtonBlock:(void (^)(NSInteger platformType, BOOL success))shareButtonBlock;

/**
 分享图片
 */
- (void)shareImageWithMessages:(NSArray *)messages image:(UIImage *)image shareButtonBlock:(void (^)(NSInteger platformType, BOOL success))shareButtonBlock;

@end
