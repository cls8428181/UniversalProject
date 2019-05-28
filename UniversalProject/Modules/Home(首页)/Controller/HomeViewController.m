//
//  HomeViewController.m
//  MiAiApp
//
//  Created by 徐阳 on 2017/5/18.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"粒子";
    
//    self.isShowLiftBack = NO;

//    [self addNavigationItemWithTitles
//     :@[@"pre登录"] isLeft:NO target:self action:@selector(naviBtnClick:) tags:@[@1000]];
//    [self addNavigationItemWithTitles:@[@"pre网页"] isLeft:NO target:self action:@selector(naviBtnClick:) tags:@[@1002,@1003]];

}

#pragma mark -  屏幕旋转
//在需要旋转的页面重写以下三个方法 默认不可旋转

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //当前支持的旋转类型
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    // 是否支持旋转
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    // 默认进去类型
    return   UIInterfaceOrientationPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
