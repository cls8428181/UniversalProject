//
//  UserInfo.h
//  MiAiApp
//
//  Created by 徐阳 on 2017/5/23.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

/**
 是否第一次登录
 */
@property (nonatomic, assign, readonly) BOOL isLogin;

/**
 是否首次登录（true：是；false：否）
 */
@property (nonatomic, assign, readonly) BOOL isFirst;

/**
 *  用户信息
 */
@property (nonatomic, strong, readonly) NSDictionary *userInfo;

/**
 用户id
 */
@property (nonatomic, copy, readonly) NSString *userId;

/**
 用户姓名
 */
@property (nonatomic, copy, readonly) NSString *userName;

/**
 昵称
 */
@property (nonatomic, copy, readonly) NSString *nickName;

/**
 密码
 */
@property (nonatomic, copy, readonly) NSString *password;

/**
 头像
 */
@property (nonatomic, copy, readonly) NSString *portrait;

/**
 性别
 */
@property (nonatomic, copy, readonly) NSString *sex;

/**
 生日
 */
@property (nonatomic, copy, readonly) NSString *birthday;

/**
 QQ
 */
@property (nonatomic, copy, readonly) NSString *qq;

/**
 email
 */
@property (nonatomic, copy, readonly) NSString *email;

/**
 电话
 */
@property (nonatomic, copy, readonly) NSString *mobile;

/**
 注册时间
 */
@property (nonatomic, copy, readonly) NSString *registerTime;

/**
 注册ip
 */
@property (nonatomic, copy, readonly) NSString *registerIP;

/**
 最后登录时间
 */
@property (nonatomic, copy, readonly) NSString *lastLoginTime;

/**
 最后登录ip
 */
@property (nonatomic, copy, readonly) NSString *lastLoginIP;

/**
 更新
 */
@property (nonatomic, copy, readonly) NSString *updatedAt;

/**
 状态
 */
@property (nonatomic, copy, readonly) NSString *status;

/**
 状态
 */
@property (nonatomic, copy, readonly) NSString *authStatus;

/**
 可用
 */
@property (nonatomic, copy, readonly) NSString *enable;

/**
 用户登录标识
 */
@property (nonatomic, copy, readonly) NSString *token;

/**
 用户登录标识超时时间
 */
@property (nonatomic, copy, readonly) NSString *tokenOutTime;

/**
 标识
 */
@property (nonatomic, copy, readonly) NSString *openId;

/**
 注册类型
 */
@property (nonatomic, copy, readonly) NSString *registerType;

/**
 极光推送 ID
 */
@property (nonatomic, copy, readonly) NSString *registrationID;

@end
