//
//  MainTabBarViewController.h
//  Concubine
//
//  Created by ... on 16/5/31.
//  Copyright © 2016年 dengyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

typedef void (^KNTabBarViewCurrentSelectIndexBlock)(NSInteger index);


@interface MainTabBarViewController : UITabBarController

//底部工具条
@property (nonatomic, strong) UIView *tabBarView;
//首页
@property (nonatomic, strong) HomeViewController *homeVC;

@property (nonatomic, copy) KNTabBarViewCurrentSelectIndexBlock selectBlock;

@property (nonatomic, assign) NSInteger lastSelectIndex;

- (void)turnToControllerIndex:(NSInteger)index;

/**
 *  显示未读角标
 */
- (void)showUnread;

/**
 * 刷新数据
 */
- (void)reloadData;

@end
