//
//  KNWebViewController.h
//  Concubine
//
//  Created by ... on 16/7/15.
//  Copyright © 2016年 dengyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLWebViewController.h"

@interface BaseWebViewController : XLWebViewController
// default 返回是是否需要清除缓存
@property (nonatomic, assign) BOOL needGoBack;
//在多级跳转后，是否在返回按钮右侧展示关闭按钮
@property(nonatomic,assign) BOOL isShowCloseBtn;

- (void)leftBarButtonItemAction:(UIBarButtonItem *)item;

/**
 *  下拉重新加载
 */
- (void)addMJRefreshHeadView;

@end
