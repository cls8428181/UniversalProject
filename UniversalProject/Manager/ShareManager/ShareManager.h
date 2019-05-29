//
//  ShareManager.h
//  MiAiApp
//
//  Created by 徐阳 on 2017/6/1.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KNUMManagerShare) {
    KNUMManagerShareWeibo = 99,
    KNUMManagerShareWeChat,
    KNUMManagerShareWeChatTimeline,
    KNUMManagerShareQQ,
    KNUMManagerShareQZone
};

typedef void (^KNUMManagerCompleteBlock)(BOOL success);

#define UMShareManager [ShareManager sharedShareManager]

/**
 分享 相关服务
 */
@interface ShareManager : NSObject

//单例
SINGLETON_FOR_HEADER(ShareManager)

@property (nonatomic, copy) KNUMManagerCompleteBlock completeBlock;
/**
 * 自定义面板友盟网页分享
 * @parame shareImageName 传nil时 为本地默认图 传其它时为网络图片
 */
- (void)showShareViewWithShareInfoTitle:(NSString *)title
                         shareImageName:(NSString *)shareImageName
                                   desc:(NSString *)desc
                               shareUrl:(NSString *)shareUrl
                  currentViewController:(UIViewController *)currentViewController;

/**
 原生面板友盟网页分享
 @param shareImage 分享图片
 */
- (void)showShareViewWithShareInfoTitle:(NSString *)title
                             shareImage:(UIImage *)shareImage
                                   desc:(NSString *)desc
                               shareUrl:(NSString *)shareUrl
                  currentViewController:(UIViewController *)currentViewController;

/**
 图片分享
 */
- (void)showShareViewWithShareInfoTitle:(NSString *)title
                             shareImage:(UIImage *)shareImage
                                   desc:(NSString *)desc
                  currentViewController:(UIViewController *)currentViewController;
/**
 展示分享页面
 */
-(void)showShareView;

// 是否安装qq
+ (BOOL)isQQInstalled;

// 是否安装微信
+ (BOOL)isWeChatInstalled;
@end
