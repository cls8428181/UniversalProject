//
//  AppDelegate.h
//  UniversalProject
//
//  Created by apple on 2019/5/28.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "KNBNavgationController.h"
#import "MainTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainTabBarViewController *tabBarController;
@property (strong, nonatomic) KNBNavgationController *navController;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

/**
 *  跳转登陆页面
 */
- (void)presentLoginViewController;
@end

