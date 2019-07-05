//
//  KNBMainConfigModel.m
//  KenuoTraining
//
//  Created by Robert on 16/2/29.
//  Copyright © 2016年 Robert. All rights reserved.
//


#import "KNBMainConfigModel.h"

@interface KNBMainConfigModel ()

@property (nonatomic, strong) NSDictionary *mainConfigDic;
//主配置接口dict
@property (nonatomic, strong) NSDictionary *interfaceListDic;
//主配置启动广告dict
@property (nonatomic, strong) NSDictionary *launchAdDict;

@end


@implementation KNBMainConfigModel

SINGLETON_FOR_DEFAULT(KNBMainConfigModel);

- (NSString *)getRequestUrlWithKey:(NSString *)key {
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_main,key];;
    if (!isNullStr(url)) {
        //除去地址两端的空格
        return [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return @"";
}
//
//- (NSDictionary *)interfaceListDic {
//    return [[self mainConfigDic] objectForKey:KNB_InterfaceList];
//}
//
//- (NSDictionary *)launchAdDict {
//    return [[self mainConfigDic] objectForKey:KNB_ADvertising];
//}
//
//- (NSString *)launch_adPhotoUrl {
//    return [self.launchAdDict objectForKey:KNB_ADPhotoUrl] ?: @"";
//}
//
//- (NSString *)launch_adJumpUrl {
//    return [self.launchAdDict objectForKey:KNB_ADJumpUrl] ?: @"";
//}
//
//- (NSString *)launch_adName {
//    return [self.launchAdDict objectForKey:KNB_ADname] ?: @"";
//}
//
//- (NSDictionary *)mainConfigDic {
//    return [[NSUserDefaults standardUserDefaults] objectForKey:KNB_MainConfigKey];
//}
//
//- (void)regestMainConfig:(id)request {
//    if ([request[KNB_InterfaceList] isKindOfClass:[NSString class]] ||
//        [request[KNB_InterfaceList] isKindOfClass:[NSNull class]]) {
//        return;
//    }
//    NSLog(@"-------------主配置:%@",request);
//    [[NSUserDefaults standardUserDefaults] setObject:request forKey:KNB_MainConfigKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//
//// 是否需要提示更新版本
//- (NSString *)newVersion {
//    NSString *envelope = [self getRequestUrlWithKey:KN_Version];
//    if (isNullStr(envelope)) {
//        return kAPP_VERSION;
//    }
//    return envelope;
//}


@end
