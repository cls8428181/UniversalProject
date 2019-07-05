//
//  BaseViewController.m
//  KenuoTraining
//
//  Created by 吴申超 on 16/2/26.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "BaseViewController.h"
#import "NSString+HTML.h"

@interface BaseViewController ()

@property (nonatomic, copy) KNMJFooterLoadCompleteBlock footerCompleteBlock;
@property (nonatomic,strong) UIImageView* noDataView;

@end


@implementation BaseViewController

- (void)dealloc {
    [self cancelRequest];
    NSLog(@"delloc=====%@", self.class);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    self.view.backgroundColor = [UIColor knBgColor];
    self.requestPage = 1;
    //是否显示返回按钮
    self.isShowLiftBack = YES;
    self.isHidenNaviBar = YES;
    self.StatusBarStyle = UIStatusBarStyleLightContent;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    if (@available(iOS 11.0, *)) {
        _groupTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _groupTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _groupTableView.scrollIndicatorInsets = _groupTableView.contentInset;
        
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return _StatusBarStyle;
}
//动态更新状态栏颜色
-(void)setStatusBarStyle:(UIStatusBarStyle)StatusBarStyle{
    _StatusBarStyle=StatusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showLoadingAnimation
{
    
}

- (void)stopLoadingAnimation
{
    
}

-(void)showNoDataImage
{
    kWeakSelf(weakSelf);
    _noDataView=[[UIImageView alloc] init];
    [_noDataView setImage:[UIImage imageNamed:@"generl_nodata"]];
    [self.view.subviews enumerateObjectsUsingBlock:^(UITableView* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UITableView class]]) {
            [weakSelf.noDataView setFrame:CGRectMake(0, 0,obj.frame.size.width, obj.frame.size.height)];
            [obj addSubview:weakSelf.noDataView];
        }
    }];
}

-(void)removeNoDataImage{
    if (_noDataView) {
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
}

/**
 *  是否显示返回按钮
 */
- (void)setIsShowLiftBack:(BOOL)isShowLiftBack
{
    _isShowLiftBack = isShowLiftBack;
    NSInteger VCCount = self.navigationController.viewControllers.count;
    //下面判断的意义是 当VC所在的导航控制器中的VC个数大于1 或者 是present出来的VC时，才展示返回按钮，其他情况不展示
    if (isShowLiftBack && ( VCCount > 1 || self.navigationController.presentingViewController != nil)) {
        [self.naviView addLeftBarItemImageName:@"knb_back_black" target:self sel:@selector(backAction)];
    } else {
        [self.naviView removeLeftBarItem];
    }
}

//取消请求
- (void)cancelRequest
{
    
}

#pragma mark - UIBarButtonItemAction
- (void)backAction
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)headerRereshing{
    
}

-(void)footerRereshing{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - Getting
- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame = CGRectMake(0, kNavBarHeight, KScreenWidth, KScreenHeight - kNavBarHeight);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor knBgColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        //头部刷新
//        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
//        header.automaticallyChangeAlpha = YES;
//        header.lastUpdatedTimeLabel.hidden = YES;
//        _tableView.mj_header = header;
//
//        //底部刷新
//        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
    }
    return _tableView;
}

- (UITableView *)groupTableView { // group
    if (!_groupTableView) {
        CGRect frame = CGRectMake(0, kNavBarHeight, KScreenWidth, KScreenHeight - kNavBarHeight);
        _groupTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _groupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _groupTableView.backgroundColor = [UIColor knBgColor];
        _groupTableView.delegate = self;
        _groupTableView.dataSource = self;
        _groupTableView.sectionFooterHeight = 0.1;
        _groupTableView.sectionHeaderHeight = 0.1;
//        //头部刷新
//        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
//        header.automaticallyChangeAlpha = YES;
//        header.lastUpdatedTimeLabel.hidden = YES;
//        _tableView.mj_header = header;
//
//        //底部刷新
//        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
    }
    return _groupTableView;
}

/**
 *  懒加载collectionView
 *
 *  @return collectionView
 */
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth , KScreenHeight - kTopHeight - kTabBarHeight) collectionViewLayout:flow];
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
        header.automaticallyChangeAlpha = YES;
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        _collectionView.mj_header = header;
        
        //底部刷新
        _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
        
        //#ifdef kiOS11Before
        //
        //#else
        //        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        //        _collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
        //        _collectionView.scrollIndicatorInsets = _collectionView.contentInset;
        //#endif
        
        _collectionView.backgroundColor=CViewBgColor;
        _collectionView.scrollsToTop = YES;
    }
    return _collectionView;
}

- (KNBNavigationView *)naviView {
    if (!_naviView) {
        _naviView = [[KNBNavigationView alloc] init];
    }
    return _naviView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark -  MJRefresh
- (void)addMJRefreshFootView:(KNMJFooterLoadCompleteBlock)completeBlock {
    self.groupTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.footerCompleteBlock = completeBlock;
}

- (void)loadMoreData {
    self.requestPage += 1;
    if (self.footerCompleteBlock) {
        self.footerCompleteBlock(self.requestPage);
    }
}

- (void)requestSuccess:(BOOL)success requestEnd:(BOOL)end {
    [self.groupTableView.mj_header endRefreshing];
    [self.groupTableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];

    if (end) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        [self.groupTableView.mj_footer endRefreshingWithNoMoreData];
        [self.groupTableView reloadData];
        [self.tableView reloadData];
        return;
    }
    if (!success && self.requestPage > 1) {
        self.requestPage -= 1;
    } else {
        [self.groupTableView reloadData];
        [self.tableView reloadData];
    }
}

- (void)addMJRefreshHeadView:(KNMJHeaderLoadCompleteBlock)completeBlock {
    kWeakSelf(weakSelf);
    MJRefreshNormalHeader *tableViewHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.tableView.mj_footer resetNoMoreData];
        weakSelf.requestPage = 1;
        if (completeBlock) {
            completeBlock(1);
        }
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableViewHeader.automaticallyChangeAlpha = YES;
    // 隐藏时间
    tableViewHeader.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = tableViewHeader;

    MJRefreshNormalHeader *groupTableViewHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.groupTableView.mj_footer resetNoMoreData];
        weakSelf.requestPage = 1;
        if (completeBlock) {
            completeBlock(1);
        }
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    groupTableViewHeader.automaticallyChangeAlpha = YES;
    // 隐藏时间
    groupTableViewHeader.lastUpdatedTimeLabel.hidden = YES;
    self.groupTableView.mj_header = groupTableViewHeader;
}

- (void)shareMessages:(NSArray *)messages shareButtonBlock:(void (^)(NSInteger platformType, BOOL success))shareButtonBlock {
    if (messages.count == 3) {
        NSString *sharTitle = [messages[0] stringByConvertingHTMLToPlainText];
        NSString *shareContent = [messages[1] stringByDecodingHTMLEntities];
        NSString *shareUrl = [messages[2] stringByConvertingHTMLToPlainText];

        [UMShareManager showShareViewWithShareInfoTitle:sharTitle shareImageName:@"" desc:shareContent shareUrl:shareUrl currentViewController:self];
    }
}

- (void)shareImageWithMessages:(NSArray *)messages image:(UIImage *)image shareButtonBlock:(void (^)(NSInteger platformType, BOOL success))shareButtonBlock {
    if (messages.count == 2) {
        NSString *sharTitle = [messages[0] stringByConvertingHTMLToPlainText];
        NSString *shareContent = [messages[1] stringByDecodingHTMLEntities];
        
        [UMShareManager showShareViewWithShareInfoTitle:sharTitle shareImage:image desc:shareContent currentViewController:self];
    }
}

#pragma mark -  屏幕旋转
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //当前支持的旋转类型
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    // 是否支持旋转
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    // 默认进去类型
    return   UIInterfaceOrientationPortrait;
}

@end
