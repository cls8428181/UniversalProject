//
//  BaseRequestAccessory.m
//  KenuoTraining
//
//  Created by Robert on 16/3/17.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "BaseRequestAccessory.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "BaseRequest.h"
#import "KNBLoginViewController.h"


@implementation BaseRequestAccessory

- (void)requestWillStart:(id)request {
    BaseRequest *baseRequest = (BaseRequest *)request;
    if (baseRequest.needHud || !isNullStr(baseRequest.hudString) || baseRequest.hudString != nil) {
        KNB_PerformOnMainThread(^{
            NSString *hudStirng = baseRequest.hudString != nil ? baseRequest.hudString : @"加载中";
            [LCProgressHUD showLoading:hudStirng];
        });
    }
}

- (void)requestWillStop:(id)request {
    
}

- (void)requestDidStop:(id)request {
    BaseRequest *baseRequest = (BaseRequest *)request;
    if (curUser && baseRequest.getRequestStatuCode == KNTraingError_token && [baseRequest.errMessage containsString:@"请重新登录"]) {
        
        [LCProgressHUD hide];
        [userManager logout:^(BOOL success, NSString *des) {
            [kAppDelegate.navController popToRootViewControllerAnimated:NO];
            [kMainTabBarVC turnToControllerIndex:kAppDelegate.tabBarController.lastSelectIndex];
            KNBLoginViewController *logInVC = [[KNBLoginViewController alloc] init];
            UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:logInVC];
            [kAppDelegate.navController presentViewController:navigationVC animated:YES completion:nil];
            //        [AlertRemind alterWithTitle:@"提示" message:@"登录信息已失效,请重新登录" buttonTitles:@[ @"知道了" ] handler:^(NSInteger index, NSString *title){
            //
            //        }];
            return;
        }];

    }

    if (baseRequest.needHud || !isNullStr(baseRequest.hudString) || baseRequest.hudString != nil) {
        //请求失败
        if (baseRequest.error || baseRequest.responseStatusCode != 200) {
            if ([AFNetworkReachabilityManager sharedManager].reachable) {
                KNB_PerformOnMainThread(^{
                    [LCProgressHUD showFailure:@"请求失败"];
                });
            } else {
                KNB_PerformOnMainThread(^{
                    [LCProgressHUD showInfoMsg:@"网络异常，请检查网络后重试"];
                });
            }
        } else {
            KNB_PerformOnMainThread(^{
                if (baseRequest.requestSuccess ||
                    baseRequest.getRequestStatuCode == KNTraingError_update) {
                    [LCProgressHUD hide];
                } else {
                    [LCProgressHUD showFailure:baseRequest.errMessage ?: @"出错啦!"];
                }
            });
        }
    }
}

@end
