//
//  AppDelegate+PushService.h
//  MiAiApp
//
//  Created by 徐阳 on 2017/5/25.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "AppDelegate.h"

/**
 推送相关在这里处理
 */
@interface AppDelegate (PushService)

/**
 配置极光推送
 */
- (void)configureJPush:(NSDictionary *)launchOptions;

/**
 注册 DeviceToken
 */
- (void)registerDeviceToken:(NSData *)deviceToken;

/**
 设置 RegistrationID
 */
- (void)settingRegistrationID;

/**
 处理远程通知
 */
- (void)handleRemoteNotification:(NSDictionary *)userInfo;
@end
