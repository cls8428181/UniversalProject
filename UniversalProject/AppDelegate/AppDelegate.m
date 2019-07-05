//
//  AppDelegate.m
//  UniversalProject
//
//  Created by apple on 2019/5/28.
//  Copyright © 2019 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "KNBWelcomeViewController.h"
#import "KNBLoginViewController.h"
#import "CALayer+Transition.h"
#import "KNPaypp.h"
#import "KNBWelcomeViewController.h"

@interface AppDelegate ()<KNBWelcomeVCDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //初始化window
    [self initWindow];
    
    //引导页
    [self showPageGuideView];
    
    //初始化网络请求配置
    [self NetWorkConfig];
    
    //UMeng初始化
    [self initUMeng];
    
    //初始化app服务
    [self initService];
    
    //初始化IM
    [[IMManager sharedIMManager] initIM];
    
    //配置极光推送
//    [self configureJPush:launchOptions];
    
    // 配置微信支付
    [KNPaypp registerWxApp:KN_WeixinAppId];
    
    // 定位
    [userLocationManager startLocation];
    
    //配置友盟分享
    [ShareManager sharedShareManager];
    
    //配置高德地图
//    [AMapServices sharedServices].apiKey = AMapKey;
    
    //初始化用户系统
    [self initUserManager];
    
    //网络监听
    [self monitorNetworkStatus];
    
    //广告页
//    [AppManager appStart];
    
    //开启键盘控制
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    return YES;
}

/**
 *  登陆页面
 */
- (void)presentLoginViewController {
    UIViewController *visibleVC = self.navController.visibleViewController;
    if ([visibleVC isKindOfClass:[KNBLoginViewController class]]) {
        return;
    }
    [kAppDelegate.tabBarController turnToControllerIndex:0]; //跳转到首页
    KNBLoginViewController *loginVC = [[KNBLoginViewController alloc] init];
    loginVC.vcType = KNBLoginTypeLogin;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self.navController presentViewController:nav animated:NO completion:nil];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self handleRemoteNotification:userInfo];
    // Required, iOS 7 Support
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL payResult = [KNPaypp handleOpenURL:url withCompletion:^(NSString *result, KNPayppError *error) {
        
    }];
    BOOL umResult = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (payResult || umResult) {
        return YES;
    }
    return NO;
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL payResult = [KNPaypp handleOpenURL:url withCompletion:nil];
    BOOL umResult = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (payResult || umResult) {
        return YES;
    }
    return NO;
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"UniversalProject"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end

