//
//  RootNavgationController.h
//  KenuoTraining
//
//  Created by 吴申超 on 16/2/25.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 导航控制器基类
 */
@interface RootNavgationController : UINavigationController

/*!
 *  返回到指定的类视图
 *
 *  @param ClassName 类名
 *  @param animated  是否动画
 */
-(BOOL)popToAppointViewController:(NSString *)ClassName animated:(BOOL)animated;
@end
