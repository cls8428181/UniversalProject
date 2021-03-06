//
//  MainTabBarViewController.m
//  Concubine
//
//  Created by ... on 16/5/31.
//  Copyright © 2016年 dengyun. All rights reserved.
//

#import "MainTabBarViewController.h"

const NSInteger KNTabBarButtonTag = 999;
const NSInteger KNTabBarButtonTitleLabelTag = 666;


@interface MainTabBarViewController ()

@property (nonatomic, strong) NSArray *selectImgArray;
@property (nonatomic, strong) NSArray *unSelectImgArray;
@property (nonatomic, strong) NSArray *titlesArray;
@property (nonatomic, strong) NSArray *vcs;
@property (nonatomic, strong) NSMutableArray *buttonsArray;
@property (nonatomic, strong) UIColor *titleSelectColor;
@property (nonatomic, strong) UIColor *titleDefaultColor;

@end


@implementation MainTabBarViewController

- (void)dealloc {
    [self.view removeObserver:self forKeyPath:@"frame"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    self.view.autoresizesSubviews = NO;

    self.titleDefaultColor = [UIColor kn808080Color];
    self.titleSelectColor = [UIColor knMainColor];

    [self creatViewControllers];
    [self.view addSubview:self.tabBarView];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (kSystemVersion < 9.0 && kSystemVersion > 7.9) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:animated];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } else {
        self.navigationController.navigationBar.hidden = YES;
    }
}
#pragma clang diagnostic pop

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        self.tabBarView.frame = CGRectMake(0, self.view.frame.size.height - kTabBarHeight, KScreenWidth, kTabBarHeight);
    }
}


- (void)turnToControllerIndex:(NSInteger)index {
    if (index < _buttonsArray.count) {
        [self tabBarPressed:_buttonsArray[index]];
    }
}

- (void)showUnread {
    NSString *unreadString;
    NSInteger unreadCount = 0;
//    if ([KNBUserInfo shareInstance].isLogin) {
//        unreadCount = [[KNBPushManager shareInstance] unReadMessageCount];
//    } else {
//        unreadCount = 0;
//    }

    if (unreadCount > 99) {
        unreadString = @"99+";
    } else {
        unreadString = [NSString stringWithFormat:@"%ld", (long)unreadCount];
    }
//    self.unreadLabel.text = unreadString;
}

- (void)reloadData {
//    [self.workBenchVC reloadData];
}

#pragma mark - Private Method
- (void)creatViewControllers {
    self.homeVC = [[HomeViewController alloc] init];
    self.viewControllers = self.vcs;

    NSInteger selectImgCount = self.selectImgArray.count;
    for (int i = 0; i < selectImgCount; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i + KNTabBarButtonTag;
        [button addTarget:self action:@selector(tabBarPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:self.unSelectImgArray[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:self.selectImgArray[i]] forState:UIControlStateSelected];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, kTabImageMargin, 0);
        CGFloat buttonWith = KScreenWidth / selectImgCount;
        button.adjustsImageWhenHighlighted = NO;
        CGRect titleLabelFrame = CGRectMake(0, 30, buttonWith, 20);
//        if (i == 2) {
//            CGFloat plusX = buttonWith * i;
//            CGFloat plusY = - 15;
//            button.frame = CGRectMake(plusX, plusY, buttonWith, kTabBarHeight + 15);
//            titleLabelFrame = CGRectMake(0, 45, buttonWith, 20);
//        } else {
//            button.frame = CGRectMake(buttonWith * i, 0, buttonWith, kTabBarHeight);
//        }
        button.frame = CGRectMake(buttonWith * i, 0, buttonWith, kTabBarHeight);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        titleLabel.tag = KNTabBarButtonTitleLabelTag;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = self.titlesArray[i];
        titleLabel.textColor = self.titleDefaultColor;
        titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button addSubview:titleLabel];

//        if (i == [KNBUserInfo shareInstance].userInterestPageSelectIndex) {
//            titleLabel.textColor = self.titleSelectColor;
//            self.lastSelectIndex = i;
//            [self tabBarPressed:button];
//            button.selected = YES;
//        }
        if (i == 0) {
            button.selected = YES;
        }
        [self.tabBarView insertSubview:button atIndex:i];
        [self.buttonsArray addObject:button];
    }
}

- (void)tabBarPressed:(UIButton *)button {
    if (button.isSelected) {
        return;
    }
    NSUInteger index = button.tag - KNTabBarButtonTag;

    //    if (index == 2) {
    //        if (![KNBUserInfo shareInstance].isLogin || [[KNBUserInfo shareInstance].userId isEqualToString:@"-1"]) {
    //            KNBLoginViewController *logInVC = [[KNBLoginViewController alloc] init];
    //            UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:logInVC];
    //            [self presentViewController:navigationVC animated:YES completion:nil];
    //            return;
    //        }
    //    }

    self.selectedIndex = index;
    self.lastSelectIndex = self.selectedIndex;
    if (self.selectBlock) {
        self.selectBlock(index);
    }
    for (UIButton *tabButton in _buttonsArray) {
        BOOL buttonSelect = [tabButton isEqual:button];
        tabButton.selected = buttonSelect;
        UILabel *titleLabel = [tabButton viewWithTag:KNTabBarButtonTitleLabelTag];
        titleLabel.textColor = buttonSelect ? self.titleSelectColor : self.titleDefaultColor;
    }
}

#pragma mark - Getter
- (UIView *)tabBarView {
    if (!_tabBarView) {
        CGRect tabBarFrame = CGRectMake(0, KScreenHeight - kTabBarHeight, KScreenWidth, kTabBarHeight);
        _tabBarView = [[UIView alloc] initWithFrame:tabBarFrame];
        _tabBarView.backgroundColor = [UIColor whiteColor];
        _tabBarView.layer.shadowColor = kRGB(230, 230, 230).CGColor;
        _tabBarView.layer.shadowRadius = 0.5;
        _tabBarView.layer.shadowOffset = CGSizeMake(0, -0.5); //偏移量
        _tabBarView.layer.shadowOpacity = 1;                  //阴影透明度
    }
    return _tabBarView;
}

- (NSMutableArray *)buttonsArray {
    if (!_buttonsArray) {
        _buttonsArray = [NSMutableArray array];
    }
    return _buttonsArray;
}

- (NSArray *)titlesArray {
    if (!_titlesArray) {
        _titlesArray = @[ @"首页", @"我的" ];
    }
    return _titlesArray;
}

- (NSArray *)unSelectImgArray {
    if (!_unSelectImgArray) {
        _unSelectImgArray = @[ @"icon_home", @"icon_my" ];
    }
    return _unSelectImgArray;
}

- (NSArray *)selectImgArray {
    if (!_selectImgArray) {
        _selectImgArray = @[ @"icon_home_hover", @"icon_my_hover" ];
    }
    return _selectImgArray;
}

- (NSArray *)vcs {
    if (!_vcs) {
        _vcs = @[ self.homeVC ,self.homeVC ];
    }
    return _vcs;
}

@end
