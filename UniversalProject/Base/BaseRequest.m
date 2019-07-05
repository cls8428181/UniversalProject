//
//  BaseRequest.m
//  KenuoTraining
//
//  Created by Robert on 16/3/12.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "BaseRequest.h"
#import "BaseRequestAccessory.h"
#import "KNBMainConfigModel.h"
#import "NSString+MD5.h"
#import "LocationManager.h"
#import "HeaderModel.h"
#import "AESCipher.h"

@interface BaseRequest ()

@property (nonatomic, strong) BaseRequestAccessory *accessory;


@end


@implementation BaseRequest

- (instancetype)init {
    if (self = [super init]) {
        [self addAccessory:self.accessory];
    }
    return self;
}

- (NSInteger)getRequestStatuCode {
    NSDictionary *jsonDic = self.responseJSONObject;
    return [[jsonDic objectForKey:@"code"] integerValue];
}

- (NSString *)message {
    if (self.error) {
        return self.error.localizedDescription;
    }
    NSString *message = [NSString stringWithFormat:@"%@",self.result[@"msg"]];
    return message;
}

- (NSString *)code {
    NSString *code = [NSString stringWithFormat:@"%@",self.result[@"code"]];
    return code;
}

- (BOOL)requestSuccess {
    
    NSInteger code = [self getRequestStatuCode];
    
    BOOL isSuccess = NO;
    
    if (code == 1) {
        isSuccess = YES;
    } else if (code == 1023) {
        //账号被顶掉
        [[kAppDelegate getCurrentUIVC] AlertWithTitle:nil message:self.message andOthers:@[@"确定"] animated:YES action:nil];
        KPostNotification(KNotificationOnKick, nil);
    }else if(code == 1039){
        //token过期
        [[kAppDelegate getCurrentUIVC] AlertWithTitle:nil message:self.message andOthers:@[@"确定"] animated:YES action:nil];
        KPostNotification(KNotificationOnKick, nil);
    }
    
    return  isSuccess;
    
}

- (NSString *)errMessage {
    NSDictionary *jsonDic = self.responseJSONObject;
    return [jsonDic objectForKey:@"msg"];
}

- (NSTimeInterval)requestTimeoutInterval {
    return 15;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (YTKResponseSerializerType)responseSerializerType {
    if (self.isOpenAES) {
        return YTKResponseSerializerTypeHTTP;
    }
    return YTKResponseSerializerTypeJSON;
}

#pragma mark ————— 请求失败过滤器 —————
-(void)requestFailedFilter{
    //失败处理器
}
#pragma mark ————— 请求成功过滤器 —————
-(void)requestCompleteFilter{
    //解密
    if (self.isOpenAES) {
        self.result = aesDecryptWithData(self.responseData);
    }else{
        self.result = self.responseJSONObject;
    }
    //    NSLog(@"请求处理器%@",self.result);
}

#pragma mark ————— 如果是加密方式传输，自定义request —————
-(NSURLRequest *)buildCustomUrlRequest{
    
    if (!_isOpenAES) {
        return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_main,self.requestUrl]]];
    
    //加密header部分
    NSString *headerContentStr = [[HeaderModel new] modelToJSONString];
    NSString *headerAESStr = aesEncrypt(headerContentStr);
    [request setValue:headerAESStr forHTTPHeaderField:@"header-encrypt-code"];
    
    NSString *contentStr = [self.requestArgument jsonStringEncoded];
    NSString *AESStr = aesEncrypt(contentStr);
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"text/encode" forHTTPHeaderField:@"Content-Type"];
    
    
    NSData *bodyData = [AESStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:bodyData];
    return request;
    
}

- (id)requestArgument {
    return self.baseMuDic;
}

//baseMuDic
//- (NSDictionary *)appendSecretDic {
//    NSString *jsonStr = [BaseRequest changeJsonStr:self.baseMuDic];
////    NSString *saltKey = [[KNBMainConfigModel shareInstance] getRequestUrlWithKey:KNB_SecretSalt];
////    NSString *saltStr = [NSString stringWithFormat:@"%@%@%@", saltKey, jsonStr, saltKey];
////    NSString *sign = [saltStr MD5];
////    NSDictionary *dic = @{ @"sign" : sign,
////                           @"jsonStr" : [NSString stringWithFormat:@"train%@", jsonStr] };
//    return dic;
//}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 3;
}

- (NSMutableDictionary *)baseMuDic {
    if (!_baseMuDic) {
        _baseMuDic = [NSMutableDictionary dictionary];
    }
    NSString *userToken = curUser.token;
    NSInteger user_id = [curUser.userId integerValue];
    NSDictionary *dic = nil;
    if (isNullStr(userToken)) {
        dic = @{
                @"user_id" : @(user_id) ?: @(0),
                };
    } else {
        dic = @{
                @"token" : userToken ?: @"",
                @"user_id" : @(user_id) ?: @(0),
                };
    }

    [_baseMuDic addEntriesFromDictionary:dic];
    return _baseMuDic;
}

+ (NSString *)changeJsonStr:(NSDictionary *)dic {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

#pragma mark - Getter&Setter
- (BaseRequestAccessory *)accessory {
    if (!_accessory) {
        _accessory = [[BaseRequestAccessory alloc] init];
    }
    return _accessory;
}

- (NSString *)hudString {
    return _hudString ? _hudString : nil;
}

#pragma mark -- 数据缓存
//根据url和参数创建路径
- (NSString *)cacheFilePath{
    NSString *cacheFileName = [[NSString stringWithFormat:@"%@",self.requestUrl] MD5];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

//创建根路径 -文件夹
- (NSString *)cacheBasePath {
    //放入cash文件夹下,为了让手机自动清理缓存文件,避免产生垃圾
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"KNBServiceApiCache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }
    return path;
}


@end
