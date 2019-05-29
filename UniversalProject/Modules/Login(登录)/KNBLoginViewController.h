//
//  KNBLoginViewController.h
//  FishFinishing
//
//  Created by 常立山 on 2019/3/27.
//  Copyright © 2019 常立山. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, KNBLoginVCType) {
    KNBLoginTypeLogin = 0,    //登录
    KNBLoginTypeFindPassword, //找回密码
    KNBLoginTypeRegister      //注册
};

NS_ASSUME_NONNULL_BEGIN

@interface KNBLoginViewController : BaseViewController
/**
 视图类型
 */
@property (nonatomic, assign) KNBLoginVCType vcType;

/**
 登录成功之后的回调
 */
- (void)setLoginSuccess:(void (^)(void))loginSuccess;
@end

NS_ASSUME_NONNULL_END
