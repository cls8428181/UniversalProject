//
//  ShareManager.m
//  MiAiApp
//
//  Created by 徐阳 on 2017/6/1.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "ShareManager.h"
#import <UMAnalytics/MobClick.h>
#import <UShareUI/UShareUI.h>
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialWechatHandler.h"
#import "ShareView.h"

@implementation ShareManager

SINGLETON_FOR_CLASS(ShareManager);

- (instancetype)init {
    if (self = [super init]) {
        [self configuraUM];
    }
    return self;
}

/**
 *  友盟配置
 */
- (void)configuraUM {
    //友盟平台统一配置AppKey
    
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:UMengKey];
    
//    [UMConfigure initWithAppkey:KN_UMAppKey channel:@"App Store"];
    
    //友盟统计
    //开启Crash收集
    [MobClick setCrashReportEnabled:YES];
    //统计场景
    [MobClick setScenarioType:E_UM_NORMAL];
    
    //打开图片水印
    [UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kAppKey_Wechat appSecret:kSecret_Wechat redirectURL:@"http://mobile.umeng.com/social"];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kAppKey_Tencent appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    
    /* 设置新浪微博的appKey和 url */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:KN_WeiboAppId appSecret:nil redirectURL:@"http://www.sina.com"];
    
    /*
     * 移除相应平台的分享，如微信收藏
     */
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[ @(UMSocialPlatformType_WechatFavorite)]];
    
    [UMSocialUIManager setPreDefinePlatforms:@[ @(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_WechatTimeLine), @(UMSocialPlatformType_QQ) , @(UMSocialPlatformType_Qzone) ,@(UMSocialPlatformType_Sina)]];
}

-(void)showShareView{
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        [self shareWebPageToPlatformType:platformType];
    }];
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    NSString* thumbURL =  @"https://mobile.umeng.com/images/pic/home/social/img-1.png";
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"欢迎使用【友盟+】社会化组件U-Share" descr:@"欢迎使用【友盟+】社会化组件U-Share，SDK包最小，集成成本最低，助力您的产品开发、运营与推广！" thumImage:thumbURL];
    //设置网页地址
    shareObject.webpageUrl = @"http://mobile.umeng.com/social";
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        [self alertWithError:error];
    }];
}

- (void)alertWithError:(NSError *)error
{
    NSString *result = nil;
    if (!error) {
        result = [NSString stringWithFormat:@"Share succeed"];
    }
    else{
        NSMutableString *str = [NSMutableString string];
        if (error.userInfo) {
            for (NSString *key in error.userInfo) {
                [str appendFormat:@"%@ = %@\n", key, error.userInfo[key]];
            }
        }
        if (error) {
            result = [NSString stringWithFormat:@"Share fail with error code: %d\n%@",(int)error.code, str];
        }
        else{
            result = [NSString stringWithFormat:@"Share fail"];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"share"
                                                    message:result
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"sure", @"确定")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - 自定义面板分享
- (void)showShareViewWithShareInfoTitle:(NSString *)title
                         shareImageName:(NSString *)shareImageName
                                   desc:(NSString *)desc
                               shareUrl:(NSString *)shareUrl
                  currentViewController:(UIViewController *)currentViewController {
    kWeakSelf(weakSelf);
    //更改成对应的跳转方式
    BOOL hadInstalledWeixin = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
    BOOL hadInstalledQQ = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
    
    NSMutableArray *titlearr     = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *imageArr     = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *typeArr     = [NSMutableArray arrayWithCapacity:5];
    
    if (hadInstalledWeixin) {
        [titlearr addObjectsFromArray:@[@"微信", @"微信朋友圈"]];
        [imageArr addObjectsFromArray:@[@"knb_share_wechat",@"knb_share_wechattimeline"]];
        [typeArr addObjectsFromArray:@[@(KNUMManagerShareWeChat), @(KNUMManagerShareWeChatTimeline)]];
    }
    if (hadInstalledQQ) {
        [titlearr addObjectsFromArray:@[@"QQ", @"QQ空间"]];
        [imageArr addObjectsFromArray:@[@"knb_share_qq",@"knb_share_qzone"]];
        [typeArr addObjectsFromArray:@[@(KNUMManagerShareQQ), @(KNUMManagerShareQZone)]];
    }
    [titlearr addObjectsFromArray:@[@"微博"]];
    [imageArr addObjectsFromArray:@[@"knb_share_sina"]];
    [typeArr addObject:@(KNUMManagerShareWeibo)];
    
    ShareView *shareView = [[ShareView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:nil];
    [shareView setBtnClick:^(NSInteger btnTag) {
        NSLog(@"\n点击第几个====%d\n当前选中的按钮title====%@",(int)btnTag,titlearr[btnTag]);
        [weakSelf shareToPlatform:[typeArr[btnTag] integerValue] title:title url:shareUrl descr:desc shareImageName:shareImageName currentVC:currentViewController];
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
}

- (void)shareToPlatform:(UShareWXMiniProgramType)type title:(NSString *)title url:(NSString *)shareUrl descr:(NSString *)desc shareImageName:(NSString *)shareImageName currentVC:(UIViewController *)currentVC {
    
    switch (type) {
        case KNUMManagerShareWeChat:
            NSLog(@"分享至微信");
            [self shareWebPage:currentVC toPlatformType:UMSocialPlatformType_WechatSession withTitle:title url:shareUrl descr:desc shareImageName:shareImageName withTransmit:NO];
            break;
        case KNUMManagerShareWeChatTimeline:
            NSLog(@"分享至朋友圈");
            [self shareWebPage:currentVC toPlatformType:UMSocialPlatformType_WechatTimeLine withTitle:title url:shareUrl descr:desc shareImageName:shareImageName withTransmit:NO];
            break;
        case KNUMManagerShareQQ:
            NSLog(@"分享至QQ");
            [self shareWebPage:currentVC toPlatformType:UMSocialPlatformType_QQ withTitle:title url:shareUrl descr:desc shareImageName:shareImageName withTransmit:NO];
            break;
        case KNUMManagerShareQZone:
            NSLog(@"分享至QQ空间");
            [self shareWebPage:currentVC toPlatformType:UMSocialPlatformType_Qzone withTitle:title url:shareUrl descr:desc shareImageName:shareImageName withTransmit:NO];
            break;
        case KNUMManagerShareWeibo:
            NSLog(@"分享至微博");
            [self shareWebPage:currentVC toPlatformType:UMSocialPlatformType_Sina withTitle:title url:shareUrl descr:desc shareImageName:shareImageName withTransmit:NO];
            break;
        default:
            break;
    }
}

//网页分享
- (void)shareWebPage:(UIViewController *)controller toPlatformType:(UMSocialPlatformType)platformType withTitle:(NSString *)title url:(NSString *)url descr:(NSString *)desc shareImageName:(NSString *)shareImageName withTransmit:(BOOL)transmit {
    UIImage *shareImage;
    if (isNullStr(shareImageName)) {
        shareImage = [UIImage imageNamed:@"shareIcon"];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:shareImageName]];
        shareImage = [UIImage imageWithData:imageData];
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:shareImage];
    //设置网页地址
    shareObject.webpageUrl = url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    kWeakSelf(weakSelf);
    [[UMSocialManager defaultManager] shareToPlatform:platformType
                                        messageObject:messageObject
                                currentViewController:controller
                                           completion:^(id data, NSError *error) {
                                               if (error) {
                                                   if (transmit) {
                                                       [MBProgressHUD showTopTipMessage:@"转发取消!"];
                                                   } else {
                                                       [MBProgressHUD showTopTipMessage:@"分享取消!"];
                                                   }
                                               } else {
                                                   if (transmit) {
                                                       [MBProgressHUD showTopTipMessage:@"转发成功!"];
                                                   } else {
                                                       [MBProgressHUD showTopTipMessage:@"分享取消!"];
                                                   }
                                                   if (weakSelf.completeBlock) {
                                                       weakSelf.completeBlock(YES);
                                                   }
                                                   if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                                                       UMSocialShareResponse *resp = data;
                                                       //分享结果消息
                                                       NSLog(@"response message is %@", resp.message);
                                                       //第三方原始返回的数据
                                                       NSLog(@"response originalResponse data is %@", resp.originalResponse);
                                                       
                                                   } else {
                                                       NSLog(@"response data is %@", data);
                                                   }
                                               }
                                           }];
}



#pragma mark - 原生分享
- (void)showShareViewWithShareInfoTitle:(NSString *)title
                             shareImage:(UIImage *)shareImage
                                   desc:(NSString *)desc
                               shareUrl:(NSString *)shareUrl
                  currentViewController:(UIViewController *)currentViewController {
    kWeakSelf(weakSelf)
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [weakSelf shareWebPage:currentViewController toPlatformType:platformType withTitle:title url:shareUrl descr:desc shareImage:shareImage];
    }];
}

//网页分享
- (void)shareWebPage:(UIViewController *)controller toPlatformType:(UMSocialPlatformType)platformType withTitle:(NSString *)title url:(NSString *)url descr:(NSString *)desc shareImage:(UIImage *)shareImage {
    if (!shareImage) {
        shareImage = [UIImage imageNamed:@"shareIcon"];
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:shareImage];
    //设置网页地址
    shareObject.webpageUrl = url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    kWeakSelf(weakSelf);
    [[UMSocialManager defaultManager] shareToPlatform:platformType
                                        messageObject:messageObject
                                currentViewController:controller
                                           completion:^(id data, NSError *error) {
                                               if (error) {
                                                   NSLog(@"---------失败原因--%@", error.userInfo);
                                                   [MBProgressHUD showTopTipMessage:@"分享取消!"];
                                               } else {
                                                   [MBProgressHUD showTopTipMessage:@"分享成功!"];
                                                   if (weakSelf.completeBlock) {
                                                       weakSelf.completeBlock(YES);
                                                   }
                                                   if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                                                       UMSocialShareResponse *resp = data;
                                                       //分享结果消息
                                                       NSLog(@"response message is %@", resp.message);
                                                       //第三方原始返回的数据
                                                       NSLog(@"response originalResponse data is %@", resp.originalResponse);
                                                       
                                                   } else {
                                                       NSLog(@"response data is %@", data);
                                                   }
                                               }
                                           }];
}

#pragma mark - 图片分享
- (void)showShareViewWithShareInfoTitle:(NSString *)title
                             shareImage:(UIImage *)shareImage
                                   desc:(NSString *)desc
                  currentViewController:(UIViewController *)currentViewController {
    kWeakSelf(weakSelf);
    //更改成对应的跳转方式
    BOOL hadInstalledWeixin = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
    BOOL hadInstalledQQ = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
    
    NSMutableArray *titlearr     = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *imageArr     = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *typeArr     = [NSMutableArray arrayWithCapacity:5];
    
    if (hadInstalledWeixin) {
        [titlearr addObjectsFromArray:@[@"微信", @"微信朋友圈"]];
        [imageArr addObjectsFromArray:@[@"knb_share_wechat",@"knb_share_wechattimeline"]];
        [typeArr addObjectsFromArray:@[@(KNUMManagerShareWeChat), @(KNUMManagerShareWeChatTimeline)]];
    }
    if (hadInstalledQQ) {
        [titlearr addObjectsFromArray:@[@"QQ", @"QQ空间"]];
        [imageArr addObjectsFromArray:@[@"knb_share_qq",@"knb_share_qzone"]];
        [typeArr addObjectsFromArray:@[@(KNUMManagerShareQQ), @(KNUMManagerShareQZone)]];
    }
    [titlearr addObjectsFromArray:@[@"微博"]];
    [imageArr addObjectsFromArray:@[@"knb_share_sina"]];
    [typeArr addObject:@(KNUMManagerShareWeibo)];
    
    ShareView *shareView = [[ShareView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:nil];
    [shareView setBtnClick:^(NSInteger btnTag) {
        NSLog(@"\n点击第几个====%d\n当前选中的按钮title====%@",(int)btnTag,titlearr[btnTag]);
        [weakSelf shareToPlatform:[typeArr[btnTag] integerValue] title:title descr:desc shareImage:shareImage currentVC:currentViewController];
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
}

- (void)shareToPlatform:(UShareWXMiniProgramType)type title:(NSString *)title descr:(NSString *)desc shareImage:(UIImage *)shareImage currentVC:(UIViewController *)currentVC {
    
    switch (type) {
        case KNUMManagerShareWeChat:
            NSLog(@"分享至微信");
            [self shareImagePage:currentVC toPlatformType:UMSocialPlatformType_WechatSession withTitle:title descr:desc shareImage:shareImage];
            break;
        case KNUMManagerShareWeChatTimeline:
            NSLog(@"分享至朋友圈");
            [self shareImagePage:currentVC toPlatformType:UMSocialPlatformType_WechatTimeLine withTitle:title descr:desc shareImage:shareImage];
            break;
        case KNUMManagerShareQQ:
            NSLog(@"分享至QQ");
            [self shareImagePage:currentVC toPlatformType:UMSocialPlatformType_QQ withTitle:title descr:desc shareImage:shareImage];
            break;
        case KNUMManagerShareQZone:
            NSLog(@"分享至QQ空间");
            [self shareImagePage:currentVC toPlatformType:UMSocialPlatformType_Qzone withTitle:title descr:desc shareImage:shareImage];
            break;
        case KNUMManagerShareWeibo:
            NSLog(@"分享至微博");
            [self shareImagePage:currentVC toPlatformType:UMSocialPlatformType_Sina withTitle:title descr:desc shareImage:shareImage];
            break;
        default:
            break;
    }
}

//图片分享
- (void)shareImagePage:(UIViewController *)controller toPlatformType:(UMSocialPlatformType)platformType withTitle:(NSString *)title descr:(NSString *)desc shareImage:(UIImage *)shareImage {
    if (!shareImage) {
        shareImage = [UIImage imageNamed:@"shareIcon"];
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:desc thumImage:shareImage];
    //设置网页地址
    shareObject.shareImage = shareImage;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    kWeakSelf(weakSelf);
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
        
        if (error) {
            NSLog(@"---------失败原因--%@", error.userInfo);
            [LCProgressHUD showMessage:@"分享取消!"];
        } else {
            [LCProgressHUD showMessage:@"分享成功!"];
            if (weakSelf.completeBlock) {
                weakSelf.completeBlock(YES);
            }
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                NSLog(@"response message is %@", resp.message);
                //第三方原始返回的数据
                NSLog(@"response originalResponse data is %@", resp.originalResponse);
                
            } else {
                NSLog(@"response data is %@", data);
            }
        }
    }];
}

+ (BOOL)isQQInstalled {
    return [[UMSocialQQHandler defaultManager] umSocial_isInstall];
}

+ (BOOL)isWeChatInstalled {
    return [[UMSocialWechatHandler defaultManager] umSocial_isInstall];
}

@end
